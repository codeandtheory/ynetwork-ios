//
//  CharacterSet+formUrlAllowedTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 9/23/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest

final class CharacterSetFormUrlAllowedTests: XCTestCase {
    private var sut: CharacterSet!
    
    override func setUp() {
        super.setUp()
        sut = .formUrlAllowed
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testUrlQueryParamerValueAllowed() {
        XCTAssertFalse(sut.contains("+"))
        XCTAssertFalse(sut.contains("&"))
        XCTAssertFalse(sut.contains("="))
    }
}
