//
//  URLProtocolStubNetworkEngine.swift.swift
//  YNetwork
//
//  Created by Sumit Goswami on 07/04/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// Makes mock API calls using `URLProtocolStub`
final public class URLProtocolStubNetworkEngine: NetworkEngine {
    private(set) var session: URLSession!
    internal let protocolClasses: [AnyClass]

    /// Initializes an URLProtocolStubNetworkEngine with protocolClasses
    /// - Parameter protocolClasses: URLProtocol class that need to be stub
    /// default class will be URLProtocolStub
    public init(protocolClasses: [AnyClass] = [URLProtocolStub.self]) {
        self.protocolClasses = protocolClasses
    }

    /// Configure the mock network engine. This must be called once prior to calling `submit`.
    /// It may be called multiple times, but should only be done if the configuration has changed.
    /// - Parameter configuration: the configuration to use
    public func configure(with configuration: NetworkEngineConfiguration) {
        let sessionConfiguration = URLSessionConfiguration.default
        // In order to intercept custom `URLSession` requests.
        sessionConfiguration.protocolClasses = protocolClasses
        session = URLSession(
            configuration: sessionConfiguration,
            delegate: configuration.sessionDelegate,
            delegateQueue: nil
        )
    }

    /// Submit a mock request using async/await
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

    /// Submit a download mock request to be executed in a background session.
    ///
    /// Immediately throws an error if the engine has not been configured.
    /// Progress, completion, and failure callbacks will occur via session delegate.
    /// - Parameter request: the download request to submit
    /// - Returns: a cancelable download task
    public func submitBackgroundDownload(_ request: URLRequest) throws -> Cancelable {
        guard session != nil else {
            throw NetworkError.notConfigured
        }

        // make a URLSessionDownloadTask, resume it, then return it
        let downloadTask = session.downloadTask(with: request)
        downloadTask.taskDescription = "\(request: request)"
        downloadTask.resume()
        return downloadTask
    }

    /// Submit a upload mock request to be executed in a background session.
    ///
    /// Immediately throws an error if the engine has not been configured.
    /// Progress, completion, and failure callbacks will occur via session delegate.
    /// - Parameters:
    ///   - request: the upload request to submit
    ///   - fileUrl: the file to upload
    /// - Returns: a cancelable upload task
    public func submitBackgroundUpload(_ request: URLRequest, fileUrl: URL) throws -> Cancelable {
        guard session != nil else {
            throw NetworkError.notConfigured
        }

        // The data to upload comes from the http body
        guard let data = request.httpBody else {
            throw NetworkError.noData
        }

        // make a URLSessionUploadTask, resume it, then return it
        let uploadTask = session.uploadTask(with: request, from: data)
        uploadTask.taskDescription = "\(request: request)"
        uploadTask.resume()
        return uploadTask
    }
}
