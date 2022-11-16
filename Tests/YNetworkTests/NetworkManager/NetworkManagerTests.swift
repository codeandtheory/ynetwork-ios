//
//  NetworkManagerTests.swift
//  YNetworkTests
//
//  Created by Sumit Goswami on 01/04/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
import os
@testable import YNetwork

final class NetworkManagerTests: XCTestCase {
    private var sut: NetworkManager!
    private var configuration: NetworkManagerConfiguration!
    private var request: NetworkRequest!

    // Open Trivia api
    // https://opentdb.com/api_config.php
    let path = UnitTestPath.openTriviaDb.pathValue
    let knownBadPath = UnitTestPath.knownBadPath.pathValue
    let urlParam: Parameters = [
        "amount": "2", // get 2 questions
        "category": "9",
        "difficulty": "medium",
        "type": "multiple"
    ]

    override func setUp() {
        super.setUp()

        configuration = NetworkManagerConfiguration(
            parserFactory: TriviaApi.makeTriviaFactory(),
            networkEngine: URLProtocolStubNetworkEngine()
        )
        sut = NetworkManager()
        request = TriviaApi.makeTriviaRequest()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        configuration = nil
        request = nil
        URLProtocolStub.reset()
    }

    // We have opentdb.com certificate pinned
    func testApiCall() {
        // Given
        if #available(iOS 14.0, tvOS 14.0, *) {
            sut.logger = Logger(subsystem: "co.yml.ynetwork", category: "unit tests")
        }

        sut.configure(with: configuration)
        addTeardownBlock {
            // clear out the logger
            if #available(iOS 14.0, tvOS 14.0, *) {
                self.sut?.logger = nil
            }
        }
        var retValue: TriviaResponse?
        var errorValue: Error?
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)

        // When
        submitRequest(response: &retValue, error: &errorValue)

        // Then
        XCTAssertNotNil(retValue)
        XCTAssertEqual(retValue?.results.count, 2)
    }

    func testSubmitWithoutConfiguration() {
        // Given
        var retValue: TriviaResponse?
        var errorValue: Error?

        // When
        submitRequest(response: &retValue, error: &errorValue)

        // Then
        XCTAssertNil(retValue)
        XCTAssertNotNil(errorValue)
        if case .notConfigured = errorValue as? NetworkError {
            print("Not configured")
        } else {
            XCTFail("Did not get not configured error")
        }
    }

    func testDeserializationError() {
        // Given
        sut.configure(with: configuration)
        var retValue: NotTriviaResponse?
        var errorValue: Error?
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)

        // When
        submit(request: request, response: &retValue, error: &errorValue)

        // Then
        XCTAssertNil(retValue)
        XCTAssertNotNil(errorValue)
        if case let .deserialization(error) = errorValue as? NetworkError {
            print("Internal error: \(error)")
        } else {
            XCTFail("Did not get deserialization error")
        }
    }

    func testInvalidSSLError() {
        // Given
        sut.configure(with: configuration)
        var retValue: EmptyNetworkResponse?
        var errorValue: Error?
        let error = NSError(domain: "NSURLErrorDomain", code: -1200)
        URLProtocolStub.appendStub(.failure(error))

        // When
        submit(request: request, response: &retValue, error: &errorValue)

        // But we expect an invalid SSL error
        // (because we purposely have the wrong public key pinned for yml.co)
        XCTAssertNotNil(errorValue)
        XCTAssertNil(retValue)
        if case let .invalidSSL(error) = errorValue as? NetworkError {
            print("Internal error: \(error)")
        } else {
            XCTFail("Did not get invalid SSL error")
        }
    }

    // tests an exception being throw within NetworkManager.submit
    func testInvalidURL() {
        // Given
        sut.configure(with: NetworkManagerConfiguration())
        let badRequest = MockRequest(path: knownBadPath, queryParameters: urlParam)
        var retValue: TriviaResponse?
        var errorValue: Error?

        // When
        submit(request: badRequest, response: &retValue, error: &errorValue)

        // Then
        XCTAssertNil(retValue)
        XCTAssertNotNil(errorValue)
        if case .invalidURL = errorValue as? NetworkError {
            print("Invalid URL")
        } else {
            XCTFail("Did not get invalid URL error")
        }
    }

    // tests an exception being thrown while parsing the response
    func testUnexpectedResponse() {
        // Given
        sut.configure(with: configuration)
        let badRequest = MockRequest(path: path, responseType: .none, queryParameters: urlParam)
        var retValue: TriviaResponse?
        var errorValue: Error?
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)

        // When
        submit(request: badRequest, response: &retValue, error: &errorValue)

        // Then
        XCTAssertNil(retValue)
        XCTAssertNotNil(errorValue)
        if case .unexpectedResponse = errorValue as? NetworkError {
            print("Unexpected response")
        } else {
            XCTFail("Did not get unexpected response error")
        }
    }

    func testPeekError() {
        // Given
        let sut = PeekNetworkManager()
        sut.configure(with: configuration)
        var retValue: EmptyNetworkResponse?
        var errorValue: Error?
        let error = NSError(domain: "NSURLErrorDomain", code: -1200)
        URLProtocolStub.appendStub(.failure(error))

        // When
        submit(sut, request: request, response: &retValue, error: &errorValue)

        // Then
        XCTAssertNil(sut.peekData)
        XCTAssertNil(sut.peekResponse)
        XCTAssertNotNil(sut.peekError)
    }

    func testPeekData() {
        // Given
        let sut = PeekNetworkManager()
        sut.configure(with: configuration)
        var retValue: TriviaResponse?
        var errorValue: Error?
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)

        // When
        submit(sut, request: request, response: &retValue, error: &errorValue)

        // Then
        XCTAssertNotNil(sut.peekData)
        XCTAssertNotNil(sut.peekResponse)
        XCTAssertNil(sut.peekError)
    }
}

private extension NetworkManagerTests {
    func submitRequest<T: Decodable>(response: inout T?, error: inout Error?) {
        submit(sut, request: request, response: &response, error: &error)
    }

    func submit<T: Decodable>(request: NetworkRequest, response: inout T?, error: inout Error?) {
        submit(sut, request: request, response: &response, error: &error)
    }

    func submit<T: Decodable>(_ sut: NetworkManager, request: NetworkRequest, response: inout T?, error: inout Error?) {
        // Given a hard-coded http response
        var output: T?
        var caught: Error?
        let expectation = self.expectation(description: "NetworkRequest")

        sut.submit(request) { (response: Result<T, Error>) in
            XCTAssertTrue(Thread.isMainThread)
            switch response {
            case .success(let data):
                output = data
            case .failure(let error):
                caught = error
            }
            expectation.fulfill()
        }

        // Give the network call 2 seconds to complete
        wait(for: [expectation], timeout: 2)

        // Copy over the extracted values (if any)
        response = output
        error = caught
    }
}

final class PeekNetworkManager: NetworkManager {
    var peekData: Data?
    var peekResponse: URLResponse?
    var peekError: Error?

    override func peekTaskResult(request: NetworkRequest, data: Data?, response: URLResponse?, error: Error?) {
        peekData = data
        peekResponse = response
        peekError = error
    }
}
