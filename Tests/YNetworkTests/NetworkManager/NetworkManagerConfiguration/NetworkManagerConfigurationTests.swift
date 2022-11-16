//
//  NetworkManagerConfigurationTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 9/21/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class NetworkManagerConfigurationTests: XCTestCase {
    private var sut: NetworkManagerConfiguration!
    
    override func setUp() {
        super.setUp()
        sut = NetworkManagerConfiguration()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testDefaultParams() {
        XCTAssertNil(sut.basePath)
        XCTAssertNil(sut.headers)
        XCTAssert(sut.parserFactory is JSONDataParserFactory)
        XCTAssertEqual(sut.timeoutInterval, 0)
        XCTAssertNil(sut.cachePolicy)
        XCTAssert(sut.networkEngine is URLNetworkEngine)
    }
}
