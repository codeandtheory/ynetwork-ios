//
//  GifBuilderTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 1/11/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class GifBuilderTests: XCTestCase {
    private let fileName = "marioRunRight"
    private let boundary = UUID().uuidString
    private var sut: GifBuilder!

    override func setUp() {
        super.setUp()
        sut = GifBuilder(fileName: fileName, formFields: [:], boundary: boundary, bundle: .module)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testBasics() {
        XCTAssertEqual(sut.fileName, fileName)
        XCTAssertTrue(sut.formFields.isEmpty)
        XCTAssertEqual(sut.boundary, boundary)
    }

    func testDefaultParams() {
        let sut = GifBuilder(fileName: fileName, formFields: [:])
        
        // Boundary is different
        XCTAssertNotEqual(sut.boundary, boundary)
        // Boundary has correct length for UUID
        XCTAssertEqual(sut.boundary.count, boundary.count)
    }

    func testParts() {
        let parts = sut.parts
        XCTAssertEqual(parts.count, 1)

        let formFields = parts.filter({
            if case .formField = $0.value {
                return true
            } else {
                return false
            }
        })
        XCTAssertTrue(formFields.isEmpty)

        let files = parts.filter({
            if case .file = $0.value {
                return true
            } else {
                return false
            }
        })
        XCTAssertEqual(files.count, 1)

        XCTAssertNotNil(parts["file"])
    }

    func testFormField() {
        let parts = GifBuilder(fileName: fileName, formFields: ["apiKey": "secret"], boundary: boundary).parts
        XCTAssertEqual(parts.count, 2)

        let formFields = parts.filter({
            if case .formField = $0.value {
                return true
            } else {
                return false
            }
        })
        XCTAssertFalse(formFields.isEmpty)
    }

    func testMimeType() {
        // MIME type should be gif
        XCTAssertEqual(sut.mimeType, "image/gif")
    }

    func testData() {
        // Given a valid file name pointing to a GIF resource,
        // data should be non-zero
        XCTAssertGreaterThan(sut.data?.count ?? 0, 250)
    }

    func testNilData() {
        // Given a bad file name
        let badFileName = "luigiSwimLeft"
        let builder = GifBuilder(fileName: badFileName, formFields: [:])

        // data should be nil
        XCTAssertNil(builder.data)
    }
}
