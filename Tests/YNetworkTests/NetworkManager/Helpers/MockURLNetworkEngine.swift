//
//  MockURLNetworkEngine.swift
//  YNetworkTests
//
//  Created by Sanjib Chakraborty on 30/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

typealias MockResponse = Result<(Data, URLResponse), Error>

final class MockURLNetworkEngine: URLNetworkEngine {
    var configuration: NetworkEngineConfiguration?
    var nextResponse: MockResponse?
    private var session: URLSession!
    
    override func configure(with configuration: NetworkEngineConfiguration) {
        self.configuration = configuration

        let sessionConfiguration = URLSessionConfiguration.default
        // In order to intercept custom `URLSession` requests.
        sessionConfiguration.protocolClasses = [URLProtocolStub.self]
        session = URLSession(
            configuration: sessionConfiguration,
            delegate: configuration.sessionDelegate,
            delegateQueue: nil
        )
        
        super.configure(with: configuration)
    }

    override func submit(_ request: URLRequest) async throws -> (Data, URLResponse) {
        guard let nextResponse = nextResponse else { throw NetworkError.notConfigured }
        return try nextResponse.get()
    }

    override func submitBackgroundDownload(_ request: URLRequest) throws -> Cancelable {
        return MockURLSessionTask()
    }

    override func submitBackgroundUpload(_ request: URLRequest, fileUrl: URL) throws -> Cancelable {
        return MockURLSessionTask()
    }
}

final class MockURLSessionTask: Cancelable {
    var isCancelled = false

    func cancel() {
         isCancelled = true
    }
}
