//
//  URLNetworkEngine.swift
//  YNetwork
//
//  Created by Sanjib Chakraborty on 28/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Default implementation of `NetworkEngine` protocol, which wraps a `URLSession` and
/// makes API calls using `URLSessionDataTask` and associated classes
public class URLNetworkEngine: NetworkEngine {
    private var session: URLSession!
    private var backgroundSession: URLSession!
    
    /// Initializes an URL Network Engine in an unconfigured state
    public init() { }
    
    /// Configure the network engine. This must be called once prior to calling `submit`.
    /// It may be called multiple times, but should only be done if the configuration has changed.
    /// - Parameter configuration: the configuration to use
    public func configure(with configuration: NetworkEngineConfiguration) {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.requestCachePolicy = configuration.cachePolicy ?? .useProtocolCachePolicy
        sessionConfiguration.timeoutIntervalForRequest = configuration.timeoutInterval
        sessionConfiguration.httpAdditionalHeaders = configuration.headers
        self.session = URLSession(
            configuration: sessionConfiguration,
            delegate: configuration.sessionDelegate,
            delegateQueue: nil
        )
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(
            withIdentifier: "ynetwork.background.\(UUID().uuidString)"
        )
        backgroundSessionConfiguration.requestCachePolicy = configuration.cachePolicy ?? .useProtocolCachePolicy
        backgroundSessionConfiguration.timeoutIntervalForRequest = configuration.timeoutInterval
        backgroundSessionConfiguration.httpAdditionalHeaders = configuration.headers
        
        self.backgroundSession = URLSession(
            configuration: backgroundSessionConfiguration,
            delegate: configuration.sessionDelegate,
            delegateQueue: nil
        )
    }

    /// Submit a network request using async/await
    /// - Throws: any error from handling the request
    /// - Parameter request: the request to submit
    /// - Returns: a tuple of the returned data and URL response
    public func submit(_ request: URLRequest) async throws -> (Data, URLResponse) {
        guard let session = session else {
            throw NetworkError.notConfigured
        }

        if #available(iOS 15.0, *) {
            return try await session.data(for: request)
        } else {
            // Bridge between synchronous and asynchronous code using continuation
            return try await withCheckedThrowingContinuation { continuation in
                let dataTask = session.dataTask(with: request) { data, response, error in
                    if let data = data,
                       let response = response {
                        continuation.resume(with: .success((data, response)))
                    } else {
                        continuation.resume(throwing: error ?? NetworkError.invalidResponse)
                    }
                }
                dataTask.resume()
            }
        }
    }

    /// Submit a download network request to be executed in a background session.
    ///
    /// Immediately throws an error if the engine has not been configured.
    /// Progress, completion, and failure callbacks will occur via session delegate.
    /// - Parameter request: the download request to submit
    /// - Returns: a cancelable download task
    @discardableResult public func submitBackgroundDownload(_ request: URLRequest) throws -> Cancelable {
        guard let backgroundSession = backgroundSession else {
            throw NetworkError.notConfigured
        }

        // make a URLSessionDownloadTask, resume it, then return it
        let downloadTask = backgroundSession.downloadTask(with: request)
        downloadTask.taskDescription = "\(request: request)"
        downloadTask.resume()
        return downloadTask
    }
    
    /// Submit a upload network request to be executed in a background session.
    ///
    /// Immediately throws an error if the engine has not been configured.
    /// Progress, completion, and failure callbacks will occur via session delegate.
    /// - Parameters:
    ///   - request: the upload request to submit
    ///   - fileUrl: the file to upload
    /// - Returns: a cancelable upload task
    @discardableResult public func submitBackgroundUpload(_ request: URLRequest, fileUrl: URL) throws -> Cancelable {
        guard let backgroundSession = backgroundSession else {
            throw NetworkError.notConfigured
        }
                
        // make a URLSessionUploadTask, resume it, then return it
        let uploadTask = backgroundSession.uploadTask(with: request, fromFile: fileUrl)
        uploadTask.resume()
        return uploadTask
    }
}

/// Declare `URLSessionTask`'s conformance to the `Cancelable` protocol
extension URLSessionTask: Cancelable { }
