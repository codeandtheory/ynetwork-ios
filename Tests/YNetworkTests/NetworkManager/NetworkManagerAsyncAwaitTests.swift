//
//  NetworkManagerAsyncAwaitTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 8/26/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class NetworkManagerAsyncAwaitTests: XCTestCase {
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

    func testApiCall() async throws {
        // Given
        sut.configure(with: configuration)
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)

        // When
        let retValue: TriviaResponse = try await(sut.submit(request))

        // Then
        XCTAssertFalse(Thread.isMainThread, "Expected callback on background thread")
        XCTAssertEqual(retValue.results.count, 2)
    }

    @MainActor func testMainActor() async throws {
        // Given
        sut.configure(with: configuration)
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)

        // When
        let retValue: TriviaResponse = try await(sut.submit(request))

        // Then
        XCTAssertTrue(Thread.isMainThread, "Expected callback on main thread")
        XCTAssertEqual(retValue.results.count, 2)
    }

    func testSubmitWithoutConfiguration() async {
        // Given
        var retValue: TriviaResponse?
        var errorValue: Error?

        // When
        do {
            retValue = try await(sut.submit(request))
        } catch {
            errorValue = error
        }

        // Then
        XCTAssertNil(retValue)
        XCTAssertNotNil(errorValue)
        if case .notConfigured = errorValue as? NetworkError {
            print("Not configured")
        } else {
            XCTFail("Did not get not configured error")
        }
    }

    func testDeserializationError() async {
        // Given
        sut.configure(with: configuration)
        var retValue: NotTriviaResponse?
        var errorValue: Error?
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)

        // When
        do {
            retValue = try await(sut.submit(request))
        } catch {
            errorValue = error
        }

        // Then
        XCTAssertNil(retValue)
        XCTAssertNotNil(errorValue)
        if case let .deserialization(error) = errorValue as? NetworkError {
            print("Internal error: \(error)")
        } else {
            XCTFail("Did not get deserialization error")
        }
    }

    func testInvalidSSLError() async {
        // Given
        sut.configure(with: configuration)
        var retValue: EmptyNetworkResponse?
        var errorValue: Error?
        let error = NSError(domain: "NSURLErrorDomain", code: -1200)
        URLProtocolStub.appendStub(.failure(error))

        // When
        do {
            retValue = try await(sut.submit(request))
        } catch {
            errorValue = error
        }

        // Then
        XCTAssertNotNil(errorValue)
        XCTAssertNil(retValue)
        if case let .invalidSSL(error) = errorValue as? NetworkError {
            print("Internal error: \(error)")
        } else {
            XCTFail("Did not get invalid SSL error")
        }
    }

    // tests an exception being throw within NetworkManager.submit
    func testInvalidURL() async {
        // Given
        let configuration = NetworkManagerConfiguration()
        sut.configure(with: configuration)
        let badRequest = MockRequest(path: knownBadPath, queryParameters: urlParam)
        var retValue: TriviaResponse?
        var errorValue: Error?

        // When
        do {
            retValue = try await(sut.submit(badRequest))
        } catch {
            errorValue = error
        }

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
    func testUnexpectedResponse() async {
        // Given
        sut.configure(with: configuration)
        let badRequest = MockRequest(path: path, responseType: .none, queryParameters: urlParam)
        var retValue: TriviaResponse?
        var errorValue: Error?
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)

        // When
        do {
            retValue = try await(sut.submit(badRequest))
        } catch {
            errorValue = error
        }

        // Then
        XCTAssertNil(retValue)
        XCTAssertNotNil(errorValue)
        if case .unexpectedResponse = errorValue as? NetworkError {
            print("Unexpected response")
        } else {
            XCTFail("Did not get unexpected response error")
        }
    }

    func testPeekError() async {
        // Given
        let sut = PeekNetworkManager()
        sut.configure(with: configuration)
        var retValue: EmptyNetworkResponse?
        var errorValue: Error?
        let error = NSError(domain: "NSURLErrorDomain", code: -1200)
        URLProtocolStub.appendStub(.failure(error))

        // When
        do {
            retValue = try await(sut.submit(request))
        } catch {
            errorValue = error
        }

        // Then
        XCTAssertNil(sut.peekData)
        XCTAssertNil(sut.peekResponse)
        XCTAssertNotNil(sut.peekError)
        XCTAssertNil(retValue)
        XCTAssertNotNil(errorValue)
    }

    func testPeekData() async {
        // Given
        let sut = PeekNetworkManager()
        sut.configure(with: configuration)
        var retValue: TriviaResponse?
        var errorValue: Error?
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)

        // When
        do {
            retValue = try await(sut.submit(request))
        } catch {
            errorValue = error
        }

        // Then
        XCTAssertNotNil(sut.peekData)
        XCTAssertNotNil(sut.peekResponse)
        XCTAssertNil(sut.peekError)
        XCTAssertNotNil(retValue)
        XCTAssertNil(errorValue)
    }
}
