//
//  PathRepresentableTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 11/18/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class PathRepresentableTests: XCTestCase {
    private let testCases: [PathRepresentable] = [
        kPathString,  // String
        PathEnum.yml, // RawRepresentable: String
        PathClass()   // class with protocol conformance
    ]

    func testBasePath() {
        testCases.forEach {
            XCTAssertEqual($0.pathValue, kPathString)
        }
    }
}

let kPathString = "https://yml.co"

enum PathEnum: String, PathRepresentable {
    case yml = "https://yml.co"
}

final class PathClass: PathRepresentable {
    var pathValue: String { "https://yml.co" }
}
