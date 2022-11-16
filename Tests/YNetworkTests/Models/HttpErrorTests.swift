//
//  HttpErrorTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 9/27/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class HttpErrorTests: XCTestCase {
    var url: URL!

    override func setUp() {
        super.setUp()
        url = URL(string: "https://webaim.org/resources/contrastchecker")
    }

    override func tearDown() {
        super.tearDown()
        url = nil
    }

    func testInit() {
        _testHttpError(code: 200, headers: ["language": "en_US"])
    }

    func testDefaultParams() {
        _testHttpError(code: 401, headers: [:])
    }

    func testNone() {
        let code = 405
        let inData = Data() // 0 length
        XCTAssert(inData.isEmpty)

        guard let httpResponse = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil) else {
            XCTFail("Failed to generate HTTPURLResponse")
            return
        }

        let error = HttpError(response: httpResponse, data: inData)

        XCTAssertEqual(error.statusCode, code)
        guard case .none = error.body else {
            XCTFail("Expected none for body")
            return
        }
    }

    func testJSONDictionaryData() {
        let code = 422
        // swiftlint:disable line_length
        guard let jsonData = """
           {
               "success": false,
               "code": 422,
               "message": "This app is powered by LevelUp. You already have a LevelUp account that you created when registering for the following LevelUp-powered app: Sandbox Documentation v15. Please install LevelUp and log in with that account, then try again.",
               "data": [
                   {
                       "error": {
                           "code": "user_exists",
                           "message": "This app is powered by LevelUp. You already have a LevelUp account that you created when registering for the following LevelUp-powered app: Sandbox Documentation v15. Please install LevelUp and log in with that account, then try again.",
                           "object": "user",
                           "property": "base"
                       }
                   }
               ]
           }
           """.data(using: .utf8) else {
               XCTFail("Could not generate JSON Data for test")
               return
           }
        // swiftlint:enable line_length

        guard let httpResponse = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil) else {
            XCTFail("Failed to generate HTTPURLResponse")
            return
        }

        let error = HttpError(response: httpResponse, data: jsonData)

        XCTAssertEqual(error.statusCode, code)
        if case let .jsonDictionary(dictionary) = error.body {
            XCTAssertEqual(dictionary["success"] as? Bool, false)
            XCTAssertEqual(dictionary["code"] as? Int, 422)
        } else {
            XCTFail("Expected a JSON Dictionary in the response")
        }
    }

    func testJSONArray() {
        let code = 200
        // swiftlint:disable line_length
        guard let jsonData = """
            [
                {
                    "error": {
                        "code": "user_exists",
                        "message": "This app is powered by LevelUp. You already have a LevelUp account that you created when registering for the following LevelUp-powered app: Sandbox Documentation v15. Please install LevelUp and log in with that account, then try again.",
                        "object": "user",
                        "property": "base"
                    }
                }
            ]
            """.data(using: .utf8) else {
                XCTFail("Could not generate JSON Data for test")
                return
            }
        // swiftlint:enable line_length

        guard let httpResponse = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil) else {
            XCTFail("Failed to generate HTTPURLResponse")
            return
        }

        let error = HttpError(response: httpResponse, data: jsonData)

        XCTAssertEqual(error.statusCode, code)
        if case let .jsonArray(array) = error.body {
            XCTAssertEqual(array.count, 1)
            if let dictionary = array.first as? [String: Any] {
                XCTAssertNotNil(dictionary["error"])
                XCTAssertEqual(dictionary.count, 1)
            } else {
                XCTFail("Expected a dictionary as the first and only object in the array")
            }
        } else {
            XCTFail("Expected a JSON Array in the response")
        }
    }

    func testRaw() {
        let code = 200
        guard let inData = "This is not a JSON array or dictionary.".data(using: .utf8) else {
            XCTFail("Could not generate JSON Data for test")
            return
        }

        guard let httpResponse = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil) else {
            XCTFail("Failed to generate HTTPURLResponse")
            return
        }

        let error = HttpError(response: httpResponse, data: inData)

        XCTAssertEqual(error.statusCode, code)
        if case let .raw(outData) = error.body {
            XCTAssertEqual(outData, inData)
            XCTAssertEqual(String(data: outData, encoding: .utf8), "This is not a JSON array or dictionary.")
        } else {
            XCTFail("Expected raw data in the response")
        }
    }
}

private extension HttpErrorTests {
    func _testHttpError(code: Int, headers: [String: String]) {
        guard let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: code,
            httpVersion: nil,
            headerFields: headers
        ) else {
            XCTFail("Failed to generate HTTPURLResponse")
            return
        }

        let error = HttpError(response: httpResponse, data: nil)

        XCTAssertEqual(error.statusCode, code)
        XCTAssertNotNil(error.headers)
        XCTAssertEqual(error.headers as? [String: String], headers)
        guard case .none = error.body else {
            XCTFail("Expected none for body")
            return
        }
    }
}
