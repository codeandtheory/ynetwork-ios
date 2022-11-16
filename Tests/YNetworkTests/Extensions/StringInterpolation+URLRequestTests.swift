//
//  StringInterpolation+URLRequestTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 1/10/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class StringInterpolationURLRequestTests: XCTestCase {
    private let mockPath = "https://fakesite.com/api/endpoint"
    private var sut: NetworkManager!
    private var engine: CopyRequestNetworkEngine!

    override func setUp() {
        engine = CopyRequestNetworkEngine()
        let configuration = NetworkManagerConfiguration(networkEngine: engine)
        sut = NetworkManager()
        sut.configure(with: configuration)
    }

    override func tearDown() {
        sut = nil
        engine = nil
    }

    func testPrintMethod() {
        HttpMethod.allCases.forEach {
            // Given requests with a fixed path but a variety of different Http Methods
            let request = MockRequest(path: mockPath, method: $0, requestType: .none)
            // We expect them to print as `%METHOD%<tab>fixedPath`
            _testRequest(request, expected: "\($0)\t\(mockPath)")
        }
    }

    func testPrintPath() {
        let paths: [PathRepresentable] = [
            UnitTestPath.google,
            UnitTestPath.webaim,
            UnitTestPath.openTriviaDb,
            UnitTestPath.yml
        ]

        paths.forEach {
            // Given GET requests with a variety of different paths
            let request = MockRequest(path: $0, requestType: .none)
            // We expect them to print as `GET<tab>%PATH%`
            _testRequest(request, expected: "GET\t\($0.pathValue)")
        }
    }

    func testPrintHeaders() {
        let headers: HttpHeaders = [
            "language": "en_US"
        ]

        // Given a GET request with a header
        let request = MockRequest(path: mockPath, headers: headers, requestType: .none)
        // We expect it to print as `GET<tab>%PATH%<tab>Headers: [%KEY%: %VALUE%]`
        _testRequest(request, expected: "GET\t\(mockPath)\tHeaders: [\"language\": \"en_US\"]")
    }

    func testPrintContentLength() {
        let data: Data! = "This is not JSON.".data(using: .utf8)
        XCTAssertNotNil(data)
        XCTAssertFalse(data.isEmpty)
        
        // Given a POST request with non-JSON body
        let request = MockRequest(path: mockPath, method: .POST, requestType: .binary, body: data)
        // We expect it to print as `POST<tab>%PATH%<tab>Content-Length: %COUNT% bytes`
        _testRequest(request, expected: "POST\t\(mockPath)\tContent-Length: \(data.count) bytes")
    }

    func testPrintRequestWithJSONBody() {
        let body =  DetectLanguageBody(q: "English is hard, but detectably so")

        // Given a POST request with JSON body
        let request = MockRequest(path: mockPath, method: .POST, body: body)
        let prefix = "POST\t\(mockPath)\tHeaders: [\"Content-Type\": \"application/json\"]"
        let json = "{\n  \"q\" : \"English is hard, but detectably so\"\n}"
        // We expect it to print as
        // `POST<tab>%PATH%<tab>Headers: ["Content-Type": "application/json"]<tab>%JSONBODY%`
        // (The Content-Type header is automatically inserted for JSON-type requests.)
        _testRequest(request, expected: "\(prefix)\t\(json)")
    }
}

private extension StringInterpolationURLRequestTests {
    func _testRequest(_ request: NetworkRequest, expected: String) {
        let exp = expectation(description: "Wait for completion")
        sut.submit(request) { [weak self] (_: Result<Data, Error>) in
            guard let request = self?.engine.request else {
                XCTFail("Expected URL request to be captured.")
                return
            }

            let output = "\(request: request)"
            XCTAssertEqual(output, expected)

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}

// This engine does nothing but store the generated URLRequest as a property
final class CopyRequestNetworkEngine: URLNetworkEngine {
    private(set) var request: URLRequest?

    override func submit(_ request: URLRequest) async throws -> (Data, URLResponse) {
        self.request = request
        return (Data(), URLResponse())
    }
}
