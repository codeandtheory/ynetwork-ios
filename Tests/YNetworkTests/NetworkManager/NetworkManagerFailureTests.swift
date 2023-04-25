//
//  NetworkManagerFailureTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 10/15/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

// swiftlint:disable identifier_name

final class NetworkManagerFailureTests: XCTestCase {
    private var sut: NetworkManager!
    private var payload: ParametersBuilder!
    private var mockEngine: MockURLNetworkEngine!
    private var url: URL!
    private var request: NetworkRequest!
    private var jsonData: Data!
    
    override func setUp() {
        mockEngine = MockURLNetworkEngine()
        let configuration = NetworkManagerConfiguration(
            networkEngine: mockEngine
        )
        sut = NetworkManager()
        sut.configure(with: configuration)

        payload = CheckContrastPayload(foregroundColor: "767E98", backgroundColor: "E7F3FE")
        request = CheckContrastRequest(queryParameters: payload.parameters)

        url = URL(string: "https://webaim.org/resources/contrastchecker")
        jsonData = """
           {
             "ratio":"3.58",
             "AA":"fail",
             "AALarge":"pass",
             "AAA":"fail",
             "AAALarge":"fail"
           }
           """.data(using: .utf8)
    }

    override func tearDown() {
        sut = nil
        mockEngine = nil
        payload = nil
        request = nil
        url = nil
        jsonData = nil
    }

    func testSuccess() {
        // Given a 200 response together with valid JSON Data
        let httpResponse = makeHTTPURLResponse(url: url, statusCode: 200)
        mockEngine.nextResponse = .success((jsonData, httpResponse))
        var output: CheckContrastResponse?
        var caught: Error?
        
        submitRequest(response: &output, error: &caught)
        
        // we expect no error
        XCTAssertNil(caught)
        // but we do expect an object
        XCTAssertNotNil(output)
        XCTAssertEqual(output, CheckContrastResponse.mock)
    }

    func testEmptyResponseSuccess() {
        // Given a 200 response with empty data
        // and a request that isn't expecting an object back

        let noneRequest = CheckContrastRequest(responseType: .none, queryParameters: payload)
        let httpResponse = makeHTTPURLResponse(url: url, statusCode: 200)
        mockEngine.nextResponse = .success((jsonData, httpResponse))
        var output: EmptyNetworkResponse?
        var caught: Error?
        
        submit(request: noneRequest, response: &output, error: &caught)
        
        // we expect no error
        XCTAssertNil(caught)
        // but we do expect an object
        XCTAssertNotNil(output)
    }

    func testErrorResponse() {
        // Given a hard-coded error response
        mockEngine.nextResponse = .failure(MockError.somethingWicked)
        var output: CheckContrastResponse?
        var caught: Error?

        submitRequest(response: &output, error: &caught)

        // we expect no model object
        XCTAssertNil(output)
        // but we expect the error returned
        XCTAssertEqual(caught as? MockError, MockError.somethingWicked)
    }

    func testInvalidResponse() {
        // Given a non http response but no error
        let urlResponse = URLResponse(url: url, mimeType: "candy", expectedContentLength: 256, textEncodingName: "utf8")
        mockEngine.nextResponse = .success((Data(), urlResponse))

        var output: CheckContrastResponse?
        var caught: Error?

        submitRequest(response: &output, error: &caught)

        // we expect no model object
        XCTAssertNil(output)
        // but we expect an invalid response error
        XCTAssertEqual(caught as? NetworkError, NetworkError.invalidResponse)
    }

    func testEmptyResponse() {
        // Given a hard-coded 200 http response
        let httpResponse = makeHTTPURLResponse(url: url, statusCode: 200)
        mockEngine.nextResponse = .success((Data(), httpResponse))
        var output: CheckContrastResponse?
        var caught: Error?

        submitRequest(response: &output, error: &caught)

        // we expect no model object
        XCTAssertNil(output)
        // but we expect a no data error
        XCTAssertEqual(caught as? NetworkError, NetworkError.noData)
    }

    func testBinaryNoEncoder() {
        let badRequest = CheckContrastRequest(responseType: .binary, queryParameters: payload)
        let httpResponse = makeHTTPURLResponse(url: url, statusCode: 200)
        mockEngine.nextResponse = .success((jsonData, httpResponse))
        var output: CheckContrastResponse?
        var caught: Error?

        submit(request: badRequest, response: &output, error: &caught)

        // we expect no model object
        XCTAssertNil(output)
        // but we expect a no encoder error
        XCTAssertEqual(caught as? NetworkError, NetworkError.noDecoder)
    }

    func testBodySerializationError() {
        let badRequest = CheckContrastRequest(method: .POST, requestType: .formURLEncoded, body: BodegaProduct.durian)
        let httpResponse = makeHTTPURLResponse(url: url, statusCode: 200)
        mockEngine.nextResponse = .success((jsonData, httpResponse))
        var output: CheckContrastResponse?
        var caught: Error?

        submit(request: badRequest, response: &output, error: &caught)

        // we expect no model object
        XCTAssertNil(output)
        // but we expect a no encoder error
        XCTAssertEqual(caught as? NetworkError, NetworkError.serialization(SerializationError.toParameters))
    }

    func test401() {
        // Given a hard-coded 401 http response
        let httpResponse = makeHTTPURLResponse(url: url, statusCode: 401)
        mockEngine.nextResponse = .success((Data(), httpResponse))
        var output: CheckContrastResponse?
        var caught: Error?

        submitRequest(response: &output, error: &caught)

        // we expect no model object
        XCTAssertNil(output)
        // but we expect an unauthenticated error
        XCTAssertEqual(caught as? NetworkError, NetworkError.unauthenticated)
    }

    func testNetworkErrors() {
        _testNetworkErrors(errorCode: NSURLErrorCannotFindHost)
        _testNetworkErrors(errorCode: NSURLErrorCannotConnectToHost)
        _testNetworkErrors(errorCode: NSURLErrorNetworkConnectionLost)
        _testNetworkErrors(errorCode: NSURLErrorNotConnectedToInternet)
        _testNetworkErrors(errorCode: NSURLErrorDNSLookupFailed)
    }

    func _testNetworkErrors(errorCode: Int) {
        let error = NSError(domain: NSURLErrorDomain, code: errorCode, userInfo: nil)
        mockEngine.nextResponse = .failure(error)
        var output: CheckContrastResponse?
        var caught: Error?

        submitRequest(response: &output, error: &caught)

        // we expect no model object
        XCTAssertNil(output)
        // but we expect a no internet error
        XCTAssertEqual(caught as? NetworkError, NetworkError.noInternet(error))
    }

    func testHttpErrors() {
        _testHttpError(statusCode: 300)
        _testHttpError(statusCode: 403)
        _testHttpError(statusCode: 500)
    }

    func _testHttpError(statusCode: Int) {
        // Given a hard-coded http response
        guard let data = """
            {
                "success": true,
                "code": 200,
                "message": "nothing"
            }
            """.data(using: .utf8) else {
            XCTFail("invalid data")
            return
        }

        let httpResponse = makeHTTPURLResponse(url: url, statusCode: statusCode)
        mockEngine.nextResponse = .success((data, httpResponse))
        var output: CheckContrastResponse?
        var caught: Error?

        submitRequest(response: &output, error: &caught)
        let httpError = caught as? HttpError

        // we expect no model object
        XCTAssertNil(output)
        // but we expect the error returned with matching http status code
        XCTAssertEqual(httpError?.statusCode, statusCode)
        // and we expect the error to be returned with the response body
        if case let .jsonDictionary(body) = httpError?.body {
            XCTAssertEqual(body["success"] as? Bool, true)
            XCTAssertEqual(body["code"] as? Int, 200)
            XCTAssertEqual(body["message"] as? String, "nothing")
        } else {
            XCTFail("Expected a JSON Dictionary in the response")
        }
    }

    func submitRequest<T: Decodable>(response: inout T?, error: inout Error?) {
        submit(request: request, response: &response, error: &error)
    }
    
    func submit<T: Decodable>(request: NetworkRequest, response: inout T?, error: inout Error?) {
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

    private func makeHTTPURLResponse(url: URL, statusCode: Int) -> HTTPURLResponse {
        guard let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        ) else {
            XCTFail("Invalid HTTPURLResponse")
            return HTTPURLResponse()
        }

        return httpResponse
    }
}

private enum MockError: Error {
    case somethingWicked
}
// swiftlint:enable identifier_name
