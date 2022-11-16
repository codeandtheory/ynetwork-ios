//
//  String+isAbsoluteURLPathTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 9/22/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest

final class StringIsAbsoluteURLPathTests: XCTestCase {
    private let absolutePaths: [String] = [
        "http://www.yml.co",
        "https://www.yml.co",
        "http://yml.co",
        "ftp://www.yml.co",
        "ftps://www.yml.co"
    ]
    
    private let relativePaths: [String] = [
        "mailto:mark.pospesel@ymedialabs.com",
        "htp://www.yml.co",
        "tttps://www.yml.co",
        "https:www.yml.co",
        "https:/www.yml.co",
        "https//www.yml.co",
        "www.yml.co",
        "/www.yml.co",
        "/company/structure",
        "company/structure",
        "api",
        ""
    ]
    
    func testAbsolutePaths() {
        absolutePaths.forEach {
            XCTAssertTrue($0.isAbsoluteURLPath, "Expected \($0) to be absolute path")
        }
    }

    func testRelativePaths() {
        relativePaths.forEach {
            XCTAssertFalse($0.isAbsoluteURLPath, "Expected \($0) to be relative path")
        }
    }
}
