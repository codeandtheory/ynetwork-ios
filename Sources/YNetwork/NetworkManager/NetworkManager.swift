//
//  NetworkManager.swift
//  YNetwork
//
//  Created by Sanjib Chakraborty on 05/10/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation
import os

/// Network manager for making API calls.
///
/// NetworkManager will be your app's main point of contact with the networking layer.
/// You are strongly discouraged from declaring an instance as a singleton.
/// Instead we recommend that you use dependency injection to pass a NetworkManager instance
/// to the places in your code where network calls need to be made (Hint: not from your Views, please!)
/// NetworkManager is designed to be highly configurable and extendable. This configuration takes place
/// via the NetworkManagerConfiguration object.
open class NetworkManager: NSObject {
    private var _logger: Any?

    /// Opt-in logger (iOS 14+ only).
    ///
    /// Set a logger to have all submitted network requests and JSON responses logged at the debug level.
    /// Default behavior is `nil` (no logging).
    ///
    /// **Important:** network requests and responses can contain sensitive information, so you should
    /// not set a logger for production builds.
    @available(iOS 14.0, tvOS 14.0, *)
    open var logger: Logger? {
        get {
            return _logger as? Logger
        } set {
            _logger = newValue
        }
    }

    /// Optional session manager to handle access and refresh tokens
    public private(set) var sessionManager: SessionManager?
    internal var refreshTask: Task<Bool, Never>?

    internal var configuration: NetworkManagerConfiguration!

    /// File upload progress
    internal let fileUpload = FileUploadProgress()
    
    /// File download progress
    internal let fileDownload = FileDownloadProgress()

    /// Initializes a network manager in an unconfigured state
    public override init() { }

    /// Configure the network manager. This must be called once prior to calling `submit` or `submitDownload`.
    /// It may be called multiple times, but should only be done if the configuration has changed.
    /// - Parameters:
    ///   - configuration: configuration to use
    ///   - sessionManager: optional session manager (defaults to `nil`)
    public func configure(
        with configuration: NetworkManagerConfiguration,
        sessionManager: SessionManager? = nil
    ) {
        var cached = configuration
        if cached.sessionDelegate == nil {
            // NetworkManager sets itself as session delegate (default behavior) if no delegate is specified
            cached.sessionDelegate = self
        }
        self.configuration = cached
        self.sessionManager = sessionManager
        // configure the session on the network engine
        configuration.networkEngine.configure(with: cached.engineConfiguration)
    }
    
    /// Submit a network request.
    ///
    /// Immediately completes with an error if the engine has not been configured.
    /// - Parameters:
    ///   - request: the network request to submit
    ///   - completion: the expected business object upon success, otherwise an error upon failure
    open func submit<Response: Decodable>(
        _ request: NetworkRequest,
        completion: @escaping APICompletion<Response>
    ) {
        Task {
            let result: Result<Response, Error>

            do {
                result = .success(try await submit(request))
            } catch {
                result = .failure(error)
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    /// Submit a network request using async/await
    /// - Throws: any error from handling the request
    /// - Parameter request: the request to submit
    /// - Returns: the expected business object (decoded response)
    open func submit<Response: Decodable>(_ request: NetworkRequest) async throws -> Response {
        let urlRequest = try buildUrlRequest(request: request)
        let factory = request.parserFactory ?? configuration.parserFactory

        do {
            var (data, response) = try await configuration.networkEngine.submit(urlRequest)
            if request.usesSession {
                await refreshIfNeeded(urlRequest: urlRequest, data: &data, response: &response)
            }
            peekTaskResult(request: request, data: data, response: response, error: nil)

            return try processTaskResult(
                data: data,
                response: response,
                responseType: request.responseType,
                parser: factory
            )
        } catch {
            peekTaskResult(request: request, data: nil, response: nil, error: error)
            // we need to map our network errors
            throw mapError(error)
        }
    }

    /// Submit a background download network request.
    ///
    /// Immediately fails and returns nil if the engine has not been configured.
    ///
    /// Upon success completionHandler contains a file URL for the temporary file.
    /// Because the file is temporary, you must either open the file for reading or move it to
    /// a permanent location in your app’s sandbox container directory before returning from this delegate method.
    ///
    /// If you choose to open the file for reading, you should do the actual reading in another thread to avoid
    /// blocking the delegate queue.
    ///
    /// You would still need to handle the UIApplicationDelegate method for resuming URL session to handle
    /// restart across application lifecycles.
    ///
    /// - Parameters:
    ///   - request: the download network request to submit
    ///   - progress: progress handler (will be called back on main thread)
    ///   - completionHandler: file download handler (will be called back on URLSession background thread).
    /// - Returns: a cancelable download task if one was able to be created, otherwise nil if no task was issued
    @discardableResult open func submitBackgroundDownload(
        _ request: NetworkRequest,
        progress: ProgressHandler? = nil,
        completionHandler: @escaping FileDownloadHandler
    ) -> Cancelable? {
        guard let urlRequest = try? buildUrlRequest(request: request) else { return nil }

        let task = try? configuration?.networkEngine.submitBackgroundDownload(urlRequest)
        fileDownload.registerDownload(task, progress: progress, handler: completionHandler)
        return task
    }
    
    /// Submit a background Upload network request.
    ///
    /// Immediately fails and returns nil if the engine has not been configured.
    /// - Parameters:
    ///   - request: the upload network request to submit
    ///   - progress: progress handler (will be called back on main thread)
    /// - Returns: a cancelable upload task if one was able to be created, otherwise nil if no task was issued
    @discardableResult open func submitBackgroundUpload(
        _ request: NetworkRequest,
        progress: ProgressHandler? = nil
    ) -> Cancelable? {
        guard let urlRequest = try? buildUrlRequest(request: request) else { return nil }

        // write the data to a temporary local file
        guard let localURL = try? urlRequest.writeDataToFile() else { return nil }

        defer {
            // delete the temporary local file
            try? FileManager.default.removeItem(at: localURL)
        }

        // creating the upload task copies the file
        let task = try? configuration?.networkEngine.submitBackgroundUpload(urlRequest, fileUrl: localURL)
        fileUpload.register(task, progress: progress)
        return task
    }
    
    /// Peek at incoming (data, response, error) returned from the network engine before it gets processed.
    ///
    /// Subclass NetworkManager and override this method to get access to raw headers etc.
    /// - Parameters:
    ///   - request: request that was executed
    ///   - data: data from network engine
    ///   - response: response from network engine
    ///   - error: error from network engine
    open func peekTaskResult(
        request: NetworkRequest,
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) { }
}

private extension NetworkManager {
    func buildUrlRequest(request: NetworkRequest) throws -> URLRequest {
        let url = try URLBuilder().url(for: request, configuration: configuration)

        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = request.method.rawValue
        
        if let multipartRequest = request as? MultipartRequest {
            urlRequest.addValue(multipartRequest.multipart.boundary, forHTTPHeaderField: "Boundary")
        }
        
        // Set the request body (if any)
        if let body = request.body {
            let factory = request.parserFactory ?? configuration.parserFactory
            let encoder = factory.encoder(for: request.requestType)
            
            do {
                urlRequest.httpBody = try body.body(encoder: encoder)
            } catch {
                throw NetworkError.serialization(error)
            }
        }
        
        // set request content type
        if let contentType = request.requestType.value {
            urlRequest.addValue(contentType, forHTTPHeaderField: RequestContentType.field)
        }
        
        // add additional headers (if any)
        request.headers?.forEach {
            urlRequest.addValue($0.value, forHTTPHeaderField: $0.key)
        }

        // apply session information (if any)
        if request.usesSession {
            sessionManager?.apply(&urlRequest)
        }

        // optionally log the request
        log(request: urlRequest)

        return urlRequest
    }

    func mapError(_ error: Error) -> Error {
        switch (error.code, error.domain) {
        case (NSURLErrorSecureConnectionFailed, NSURLErrorDomain):
            return NetworkError.invalidSSL(error)
        case (NSURLErrorCannotFindHost, NSURLErrorDomain),
            (NSURLErrorCannotConnectToHost, NSURLErrorDomain),
            (NSURLErrorNetworkConnectionLost, NSURLErrorDomain),
            (NSURLErrorNotConnectedToInternet, NSURLErrorDomain),
            (NSURLErrorDNSLookupFailed, NSURLErrorDomain):
            return NetworkError.noInternet(error)
        default:
            return error
        }
    }

    func processTaskResult<T: Decodable>(
        data: Data,
        response: URLResponse,
        responseType: ResponseContentType,
        parser factory: DataParserFactory
    ) throws -> T {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch response.statusCode {
        case 200..<300:
            return try parse(data: data, responseType: responseType, parser: factory)
        case 401:
            throw NetworkError.unauthenticated
        default:
            throw HttpError(response: response, data: data)
        }
    }

    func parse<Response: Decodable>(
        data: Data,
        responseType: ResponseContentType,
        parser: DataParserFactory
    ) throws -> Response {
        let decoder = parser.decoder(for: responseType)

        switch responseType {
        case .none:
            if let response = EmptyNetworkResponse() as? Response {
                return response
            } else {
                // We received a response when we were not expecting one
                throw NetworkError.unexpectedResponse(type: responseType)
            }
        case .binary:
            if let response = data as? Response {
                // return binary Data directly
                return response
            }

            // otherwise we try to decode it
            fallthrough
        case .JSON:
            guard !data.isEmpty else {
                throw NetworkError.noData
            }

            log(json: data)

            guard let decoder = decoder else {
                throw NetworkError.noDecoder
            }

            do {
                return try decoder.decode(Response.self, from: data)
            } catch {
                throw NetworkError.deserialization(error)
            }
        }
    }
}
