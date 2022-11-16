//
//  MultipartElementTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 1/13/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class MultipartElementTests: XCTestCase {
    func testFormField() {
        let field: MultipartElement = .formField(value: "Mario")

        var data = Data()
        XCTAssertTrue(data.isEmpty)

        field.encode(data: &data, name: "character")

        XCTAssertFalse(data.isEmpty)

        let output = String(data: data, encoding: .utf8)
        let expected = """
Content-Disposition: form-data; name="character"\r
\r
Mario\r

"""
        XCTAssertEqual(output, expected)
    }

    func testFile() {
        let dataString = "abad1dea"
        let file = MultipartFileInfo(fileName: "idea.txt", data: Data(dataString.utf8), mimeType: "text/plain")
        
        let field: MultipartElement = .file(info: file)

        var data = Data()
        XCTAssertTrue(data.isEmpty)

        field.encode(data: &data, name: "file")

        XCTAssertFalse(data.isEmpty)

        let output = String(data: data, encoding: .utf8)
        let expected = """
Content-Disposition: form-data; name="file"; filename="idea.txt"\r
Content-Type: text/plain\r
\r
abad1dea\r

"""
        XCTAssertEqual(output, expected)
    }
}
