//
//  Data+AppendStringTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 1/11/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class DataAppendStringTests: XCTestCase {
    func testSimple() {
        // given a string we append as utf8 data
        var data = Data()
        data.appendString("Mario")
        // we expect to be able to extract it back
        XCTAssertFalse(data.isEmpty)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Mario")
    }

    func testMultiple() {
        // given strings that we append as utf8 data
        var data = Data()
        data.appendString("Mario")
        data.appendString(" & ")
        data.appendString("Luigi")

        // we expect to be able to extract it all back
        XCTAssertFalse(data.isEmpty)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Mario & Luigi")
    }

    func testNonUTF8() {
        var data = Data()
        // given a non-UTF8 string
        data.appendString("Mário")

        // we should still be able to extract it back
        XCTAssertFalse(data.isEmpty)
        XCTAssertEqual(String(data: data, encoding: .utf8), "Mário")
    }
}
