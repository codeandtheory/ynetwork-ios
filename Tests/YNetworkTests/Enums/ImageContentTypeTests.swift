//
//  ImageContentTypeTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 1/11/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class ImageContentTypeTests: XCTestCase {
    func testValue() {
        ImageContentType.allCases.forEach {
            let suffix: String

            switch $0 {
            case .jpg: suffix = "jpg"
            case .jpeg: suffix = "jpeg"
            case .png: suffix = "png"
            case .gif: suffix = "gif"
            }

            XCTAssertEqual($0.value, "image/\(suffix)")
        }
    }
}
