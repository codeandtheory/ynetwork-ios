//
//  Error+CodeTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 11/29/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class ErrorCodeTests: XCTestCase {
    private var sut: Error!
    private let domain: String = "fakeDomain"
    private let code: Int = 123
    private let userInfo: [String: String] = ["system": "ios"]

    override func setUp() {
        super.setUp()
        sut = NSError(domain: domain, code: code, userInfo: userInfo)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testCode() {
        XCTAssertEqual(sut.code, code)
    }

    func testDomain() {
        XCTAssertEqual(sut.domain, domain)
    }

    func testUserInfo() {
        XCTAssertEqual(sut.userInfo as? [String: String], userInfo)
    }
}
