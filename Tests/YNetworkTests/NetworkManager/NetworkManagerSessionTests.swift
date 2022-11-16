//
//  NetworkManagerSessionTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 9/9/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class NetworkManagerSessionTests: XCTestCase {
    private var sut: NetworkManager!
    private var configuration: NetworkManagerConfiguration!
    private var request: NetworkRequest!

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

    func testRefresh() async throws {
        // Given
        let session = DemoSessionManager()
        sut.configure(with: configuration, sessionManager: session)
        URLProtocolStub.appendStub(withData: Data(), statusCode: 401)
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)

        // When
        let retValue: TriviaResponse = try await(sut.submit(request))

        // Then
        XCTAssertTrue(session.applied)
        XCTAssertEqual(session.refreshCount, 1)
        XCTAssertEqual(session.errorCount, 0)
        XCTAssertEqual(retValue.results.count, 2)
    }

    func testNoRefresh() async {
        // Given
        let session = DemoSessionManager()
        session.canRefresh = false
        sut.configure(with: configuration, sessionManager: session)
        var retValue: EmptyNetworkResponse?
        var errorValue: Error?
        URLProtocolStub.appendStub(withData: Data(), statusCode: 401)
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)

        // When
        do {
            retValue = try await(sut.submit(request))
        } catch {
            errorValue = error
        }

        // Then
        XCTAssertTrue(session.applied)
        XCTAssertEqual(session.refreshCount, 0)
        XCTAssertEqual(session.errorCount, 1)
        XCTAssertNil(retValue)
        XCTAssertNotNil(errorValue)
        if case .unauthenticated = errorValue as? NetworkError {
            print("Unexpected response")
        } else {
            XCTFail("Did not get unauthenticated error")
        }
    }

    func testOneRefreshMultipleCalls() async throws {
        // Given
        let session = DemoSessionManager()
        sut.configure(with: configuration, sessionManager: session)
        URLProtocolStub.appendStub(withData: Data(), statusCode: 401)
        URLProtocolStub.appendStub(withData: Data(), statusCode: 401)
        URLProtocolStub.appendStub(withData: Data(), statusCode: 401)
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)

        // When
        async let retValue1: TriviaResponse = try sut.submit(request)
        async let retValue2: TriviaResponse = try sut.submit(request)
        async let retValue3: TriviaResponse = try sut.submit(request)
        let count = try await (retValue1.results.count + retValue2.results.count + retValue3.results.count)

        // Then
        XCTAssertTrue(session.applied)
        XCTAssertEqual(session.refreshCount, 1)
        XCTAssertEqual(session.errorCount, 0)
        XCTAssertEqual(count, 6)
    }

    func testOneFailedRefreshMultipleCalls() async {
        // Given
        let session = DemoSessionManager()
        session.canRefresh = false
        sut.configure(with: configuration, sessionManager: session)
        var count: Int = 0
        var errorValue: Error?
        URLProtocolStub.appendStub(withData: Data(), statusCode: 401)
        URLProtocolStub.appendStub(withData: Data(), statusCode: 401)
        URLProtocolStub.appendStub(withData: Data(), statusCode: 401)

        // When
        do {
            async let retValue1: TriviaResponse = try sut.submit(request)
            async let retValue2: TriviaResponse = try sut.submit(request)
            async let retValue3: TriviaResponse = try sut.submit(request)
            count = try await (retValue1.results.count + retValue2.results.count + retValue3.results.count)
        } catch {
            errorValue = error
        }

        // Then
        XCTAssertTrue(session.applied)
        XCTAssertEqual(session.refreshCount, 0)
        XCTAssertEqual(session.errorCount, 1)
        XCTAssertNotNil(errorValue)
        XCTAssertEqual(count, 0)
        if case .unauthenticated = errorValue as? NetworkError {
            print("Unexpected response")
        } else {
            XCTFail("Did not get unauthenticated error")
        }
    }
}

final class DemoSessionManager {
    var applied = false
    var refreshCount: Int = 0
    var errorCount: Int = 0
    var canRefresh = true
}

extension DemoSessionManager: SessionManager {
    func apply(_ request: inout URLRequest) {
        applied = true
    }

    func refresh(networkManager: NetworkManager) async -> Bool {
        // Wait for 5 ms
        try? await Task<Never, Never>.sleep(nanoseconds: 5_000_000)

        if canRefresh {
            refreshCount += 1
            return true
        } else {
            errorCount += 1
            return false
        }
    }
}
