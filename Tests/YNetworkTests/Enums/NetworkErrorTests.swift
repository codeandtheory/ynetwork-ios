//
//  NetworkErrorTests.swift
//  YNetworkTests
//
//  Created by Sumit Goswami on 07/10/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class NetworkErrorTests: XCTestCase {
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

private enum MockError: Error {
    case anError
    case anotherError
}

private extension NetworkErrorTests {
    func buildTestCases() -> [NetworkError] {
        [
            .noBasePath,
            .invalidURL,
            .notConfigured,
            .invalidResponse,
            .noData,
            .unexpectedResponse(type: .JSON),
            .unexpectedResponse(type: .none),
            .unexpectedResponse(type: .binary),
            .deserialization(MockError.anError),
            .deserialization(MockError.anotherError),
            .serialization(MockError.anError),
            .serialization(MockError.anotherError),
            .noDecoder,
            .noEncoder,
            .unauthenticated,
            .invalidSSL(MockError.anError),
            .invalidSSL(MockError.anotherError),
            .noInternet(MockError.anError),
            .noInternet(MockError.anotherError)
        ]
    }
}
