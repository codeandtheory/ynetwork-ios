//
//  NetworkRequestTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 9/21/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class NetworkRequestTests: XCTestCase {
    private static let path = "https://webaim.org/resources/contrastchecker/?fcolor=000000&bcolor=FFFFFF&api"
    
    private var sut: NetworkRequest!
    
    override func setUp() {
        super.setUp()

        sut = DefaultRequest(path: NetworkRequestTests.path)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testDefaultParams() {
        XCTAssertNil(sut.basePath)
        XCTAssertEqual(sut.path.pathValue, NetworkRequestTests.path)
        XCTAssertEqual(sut.method, .GET)
        XCTAssertNil(sut.headers)
        XCTAssertEqual(sut.requestType, .JSON)
        XCTAssertEqual(sut.responseType, .JSON)
        XCTAssertNil(sut.queryParameters)
        XCTAssertNil(sut.body)
        XCTAssertEqual(sut.timeoutInterval, 0)
        XCTAssertNil(sut.cachePolicy)
        XCTAssertNil(sut.parserFactory)
    }
}
