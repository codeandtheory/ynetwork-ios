//
//  XCTestCase+Await.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 9/1/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest

struct AwaitError: Error { }

extension XCTestCase {
    func await<T>(
        _ function: (@escaping (T) -> Void) -> Void,
        timeout: TimeInterval = 2
    ) throws -> T {
        let expectation = self.expectation(description: "Async call")
        var result: T?

        function { value in
            result = value
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)

        guard let unwrappedResult = result else {
            throw AwaitError()
        }

        return unwrappedResult
    }
}
