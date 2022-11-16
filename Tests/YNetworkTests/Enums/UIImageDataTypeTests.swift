//
//  UIImageDataTypeTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 1/13/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class UIImageDataTypeTests: XCTestCase {
    func testValue() {
        buildTestCases().forEach {
            let suffix: String

            switch $0 {
            case .jpg: suffix = "jpg"
            case .jpeg: suffix = "jpeg"
            case .png: suffix = "png"
            }

            XCTAssertEqual($0.value, "image/\(suffix)")
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

private extension UIImageDataTypeTests {
    func buildTestCases() -> [UIImageDataType] {
        [
            .jpg(compression: 0.25),
            .jpg(compression: 0.50),
            .jpeg(compression: 0.25),
            .jpeg(compression: 0.50),
            .png
        ]
    }
}
