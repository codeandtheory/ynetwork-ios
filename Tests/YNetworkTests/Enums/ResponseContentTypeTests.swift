//
//  ResponseContentTypeTests.swift
//  YNetworkTests
//
//  Created by Sumit Goswami on 23/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class ResponseContentTypeTests: XCTestCase {
    private var sut: [ResponseContentType]!
    
    override func setUp() {
        super.setUp()
        sut = ResponseContentType.allCases
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
            case .none, .binary:
                XCTAssertNil($0.value)
            }
        }
    }
    
    func testAcceptTypeHeader() {
        sut.forEach {
            if let header = $0.header {
                XCTAssertTrue($0 == .JSON)
                XCTAssertEqual(header.field, "Accept")
                XCTAssertEqual($0.value, header.value)
            } else {
                XCTAssertTrue($0 == .none || $0 == .binary)
            }
        }
    }
}
