//
//  MultipartBuilderTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 1/13/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class MultipartBuilderTests: XCTestCase {
    private var sut: MultipartBuilder!

    override func setUp() {
        super.setUp()
        sut = MockMultipart()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testBody() throws {
        let data = try sut.body(encoder: nil)
        let output = String(data: data, encoding: .utf8) ?? ""
        let expected = """
--Super Mario Bros. 3\r
Content-Disposition: form-data; name="firstName"\r
\r
Mario\r
--Super Mario Bros. 3\r
Content-Disposition: form-data; name="lastName"\r
\r
Plumber\r
--Super Mario Bros. 3\r
Content-Disposition: form-data; name="lives"\r
\r
3\r
--Super Mario Bros. 3--\r

"""
        XCTAssertEqual(output, expected)
    }
}

struct MockMultipart {
    let firstName = "Mario"
    let lastName = "Plumber"
    let lives = 3
}

extension MockMultipart: MultipartBuilder {
    var parts: [String: MultipartElement] {
        [
            "firstName": .formField(value: firstName),
            "lastName": .formField(value: lastName),
            "lives": .formField(value: lives)
        ]
    }

    var boundary: String { "Super Mario Bros. 3"}
}
