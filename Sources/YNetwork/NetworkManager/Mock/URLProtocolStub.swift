//
//  URLProtocolStub.swift
//  MockApiDemoTests
//
//  Created by Karthik K Manoj on 13/03/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// `URLProtocol`is an abstract class. To intercept requests we need to create a subclass of `URLProtocol`.
/// Required methods when subclassing:
/// class func canInit(with request: URLRequest) -> Bool
/// class func canonicalRequest(for request: URLRequest) -> URLRequest
/// func startLoading()
/// func stopLoading()
final public class URLProtocolStub: URLProtocol {
    /// The type of task being stubbed
    public enum TaskType {
        /// Data task
        case data
        /// Download task
        case download
        /// Upload task
        case upload
    }

    struct Stub {
        let output: Result<(Data, URLResponse), Error>
        let type: TaskType
    }

    /// Captured objects to mock the network response.
    private(set) static var messages: [Stub] = []
    
    /// Adds a predefined request result which will be consumed by URL Loading System.
    /// - Parameters:
    ///   - result: the network request result, either `(Data, URLResponse)` upon success, or else `Error` upon failure.
    ///   - type: the task type being stubbed.
    public static func appendStub(
        _ result: Result<(Data, URLResponse), Error>,
        type: TaskType = .data
    ) {
        messages.append(Stub(output: result, type: type))
    }

    /// Adds a predefined request result which will be consumed by URL Loading System.
    /// - Parameters:
    ///   - obj: JSON object that will be injected as `Data` by `URLProtocolStub`
    ///   - statusCode: HTTP status code of the response that will be injected by `URLProtocolStub`.
    ///   - type: the task type being stubbed.
    public static func appendStub(
        withJSONObject obj: Any,
        statusCode: Int,
        type: TaskType = .data
    ) {
        guard let data = URLProtocolStub.makeData(withJSONObject: obj),
              let response = URLProtocolStub.makeHTTPURLResponse(
                statusCode: statusCode,
                expectedLength: data.count
              ) else {
            return
        }

        messages.append(
            Stub(output: .success((data, response)), type: type)
        )
    }

    /// Adds a predefined request result which will be consumed by URL Loading System.
    /// - Parameters:
    ///   - data: An object that will be injected as `Data` by `URLProtocolStub`
    ///   - statusCode: HTTP status code of the response that will be injected by `URLProtocolStub`.
    ///   - type: the task type being stubbed.
    public static func appendStub(
        withData data: Data,
        statusCode: Int,
        type: TaskType = .data
    ) {
        guard let response = URLProtocolStub.makeHTTPURLResponse(
            statusCode: statusCode,
            expectedLength: data.count
        ) else {
            return
        }

        messages.append(
            Stub(output: .success((data, response)), type: type)
        )
    }

    /// Reset class properties.
    public static func reset() {
        messages.removeAll()
    }
    
    /// Determines whether the protocol subclass can handle the specified request.
    /// - Parameter request: The request to be handled.
    /// - Returns: `true` if the protocol subclass can handle request, otherwise `false`.
    public override class func canInit(with request: URLRequest) -> Bool { true }
    
    /// Returns a canonical version of the specified request.
    /// - Parameter request: The request whose canonical version is desired.
    /// - Returns: The canonical form of request.
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    /// Instance method that starts protocol-specific loading of the request.
    public override func startLoading() {
        guard let message = getNextMessage() else {
            client?.urlProtocol(self, didFailWithError: NetworkError.invalidResponse)
            return
        }

        do {
            let (data, response) = try message.output.get()

            switch message.type {
            case .data:
                simulateDataTask(data: data, response: response)
            case .download:
                simulateDownloadTask(data: data, response: response)
            case .upload:
                simulateUploadTask(data: data, response: response)
            }
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    /// Instance method that stops protocol-specific loading of the request.
    /// Requires to be overridden with empty implementation.
    /// Failing to do so will throw run time error as `URLProtocol` is an abstract class.
    public override func stopLoading() { }
}

public extension URLProtocolStub {
    /// Make data from any JSON obejct
    static func makeData(withJSONObject obj: Any) -> Data? {
        try? JSONSerialization.data(withJSONObject: obj)
    }

    /// Make HTTP url response with status code for any request
    static func makeHTTPURLResponse(statusCode: Int, expectedLength: Int = 0) -> HTTPURLResponse? {
        let url: URL! = URL(string: "https://any-url.com")
        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Length": "\(expectedLength)"]
        )
    }
}

private extension URLProtocolStub {
    /// Remove first object from stack and prepare stub for next response
    func getNextMessage() -> Stub? {
        guard !URLProtocolStub.messages.isEmpty else { return nil }
        return URLProtocolStub.messages.removeFirst()
    }

    /// Simulate data task.
    func simulateDataTask(data: Data, response: URLResponse) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    /// Simulate download task.
    func simulateDownloadTask(data: Data, response: URLResponse) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        let chunkCount = Int.random(in: 2...6)
        let chunkSize = data.count / chunkCount
        if chunkSize > 0 {
            let chunks = stride(from: 0, through: data.count, by: chunkSize).map {
                data[$0 ..< min($0 + chunkSize, data.count)]
            }

            for chunk in chunks {
                client?.urlProtocol(self, didLoad: chunk)
            }
        } else {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    /// Simulate upload task.
    func simulateUploadTask(data: Data, response: URLResponse) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
}
