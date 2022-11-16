//
//  JWTDecodeErrorTests.swift
//  YNetworkTests
//
//  Created by Sanjib Chakraborty on 09/02/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class JWTDecodeErrorTests: XCTestCase {
    func testEquals() {
        // given two separate arrays of various error cases
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

private extension JWTDecodeErrorTests {
    func buildTestCases() -> [JWTDecodeError] {
        [
            .invalidJSON("YNETWORK"),
            .invalidJSON("YNETWORK.NETWORK_LIBRARY"),
            .invalidPartCount("YNETWORK", 1),
            .invalidPartCount("YNETWORK", 2),
            .invalidPartCount("YNETWORK.NETWORK_LIBRARY", 1),
            .invalidPartCount("YNETWORK.NETWORK_LIBRARY", 2),
            .invalidBase64("YNETWORK"),
            .invalidBase64("YNETWORK.NETWORK_LIBRARY")
        ]
    }
}
