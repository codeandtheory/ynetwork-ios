//
//  RequestContentTypeTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 9/20/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class RequestContentTypeTests: XCTestCase {
    private var sut: [RequestContentType]!
    
    override func setUp() {
        super.setUp()
        sut = buildTestCases()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testValue() {
        sut.forEach {
            switch $0 {
            case .JSON:
                XCTAssertEqual($0.value, "application/json")
            case .formURLEncoded:
                XCTAssertEqual($0.value, "application/x-www-form-urlencoded; charset=utf-8")
            case .multipart(let boundary):
                XCTAssertEqual($0.value, "multipart/form-data; boundary=\(boundary)")
            case .none, .binary:
                XCTAssertNil($0.value)
            }
        }
    }

    func testContentTypeHeader() {
        sut.forEach {
            if let header = $0.header {
                XCTAssertTrue($0 != .none && $0 != .binary)
                XCTAssertEqual(header.field, "Content-Type")
                XCTAssertEqual($0.value, header.value)
            } else {
                XCTAssertTrue($0 == .none || $0 == .binary)
            }
        }
    }

    func testEquals() {
        // given two separate arrays of various enum cases
        // (We use two arrays to prevent confusing object identity with value identity)
        let lhCases = buildTestCases()
        let rhCases = buildTestCases()
        let count = lhCases.count

        // the two arrays should have the same size
        XCTAssertEqual(lhCases.count, rhCases.count)

        for i in 0..<count {
            // given a lefthand value
            let lhs = lhCases[i]
            for j in 0..<count {
                // ... and a righthand value
                let rhs = rhCases[j]

                // The two values should only be equal if their indices are equal
                XCTAssertEqual(lhs == rhs, i == j)
            }
        }
    }
}

private extension RequestContentTypeTests {
    func buildTestCases() -> [RequestContentType] {
        [
            .none,
            .JSON,
            .binary,
            .formURLEncoded,
            .multipart(boundary: "Mario"),
            .multipart(boundary: "Luigi")
        ]
    }
}
