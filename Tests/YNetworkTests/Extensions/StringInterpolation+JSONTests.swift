//
//  StringInterpolation+JSONTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 1/11/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest

final class StringInterpolationJSONTests: XCTestCase {
    func testNonPretty() {
        // Given data generated from non-pretty printed JSON string
        guard let data = """
           {"name": "Durian", "points": 600, "description": "A fruit with a distinctive scent."}
           """.data(using: .utf8) else {
            XCTFail("Failed to generate JSON data")
            return
        }

        let output = "\(json: data)"
        let expected = """
{
  "name" : "Durian",
  "points" : 600,
  "description" : "A fruit with a distinctive scent."
}
"""

        // It should be pretty printed as JSON
        XCTAssertEqual(output, expected)
    }

    func testBodyBuilder() throws {
        // Given an object that confirms to BodyBuilder
        let body =  DetectLanguageBody(q: "English is hard, but detectably so")

        // We should be able to encode it to Data
        let data = try body.body(encoder: JSONEncoder())
        let output = "\(json: data)"
        let expected = "{\n  \"q\" : \"English is hard, but detectably so\"\n}"
        // It should be pretty printed as JSON
        XCTAssertEqual(output, expected)
    }

    func testInvalid() {
        // Given string data that is not JSON
        guard let data = "This is not JSON.".data(using: .utf8) else {
            XCTFail("Failed to generate non-JSON data")
            return
        }

        // It should pretty print to an error message
        let output = "\(json: data)"
        let expected = "Invalid JSON data"
        XCTAssertEqual(output, expected)
    }
}
