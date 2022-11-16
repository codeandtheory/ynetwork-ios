//
//  ImageBuilderTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 1/11/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class ImageBuilderTests: XCTestCase {
    private let imageName = "Mario"
    private let fileName = UUID().uuidString
    private let boundary = UUID().uuidString

    private var image: UIImage!
    private var sut: ImageBuilder!

    override func setUp() {
        super.setUp()
        image = UIImage(named: imageName, in: Bundle.module, with: nil)
        sut = ImageBuilder(
            image: image,
            fileName: fileName,
            imageType: .png,
            formFields: ["apiKey": "secret"],
            boundary: boundary
        )
    }

    override func tearDown() {
        super.tearDown()
        image = nil
        sut = nil
    }

    func testBasics() {
        XCTAssertEqual(sut.image, image)
        XCTAssertEqual(sut.fileName, fileName)
        XCTAssertEqual(sut.imageType, .png)
        XCTAssertEqual(sut.formFields.count, 1)
        XCTAssertEqual(sut.boundary, boundary)
    }

    func testDefaultParams() {
        let sut = ImageBuilder(
            image: image,
            fileName: fileName,
            imageType: .png,
            formFields: sut.formFields
        )
        
        // Boundary is different
        XCTAssertNotEqual(sut.boundary, boundary)
        // Boundary has correct length for UUID
        XCTAssertEqual(sut.boundary.count, boundary.count)
    }

    func testParts() {
        let parts = sut.parts
        XCTAssertEqual(parts.count, 2)

        let formFields = parts.filter({
            if case .formField = $0.value {
                return true
            } else {
                return false
            }
        })
        XCTAssertEqual(formFields.count, sut.formFields.count)

        let files = parts.filter({
            if case .file = $0.value {
                return true
            } else {
                return false
            }
        })
        XCTAssertEqual(files.count, 1)

        XCTAssertNotNil(parts["apiKey"])
        XCTAssertNotNil(parts["file"])
    }
}
