//
//  MultipartImageBuilderTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 1/13/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class MultipartImageBuilderTests: XCTestCase {
    private let boundary = UUID().uuidString

    private var image1: UIImage!
    private var image2: UIImage!
    private var sut: MultiImageBuilder!

    override func setUp() {
        super.setUp()
        image1 = UIImage(named: "Mario", in: Bundle.module, with: nil)
        image2 = UIImage(named: "Luigi", in: Bundle.module, with: nil)

        let file1 = UIImageMultipartFileInfo(image: image1, fileName: "Mario.png", imageType: .png)
        let file2 = UIImageMultipartFileInfo(image: image2, fileName: "Luigi.png", imageType: .png)
        sut = MultiImageBuilder(
            images: [
                "Mario": file1,
                "Luigi": file2
            ],
            formFields: ["apiKey": "secret"],
            boundary: boundary
        )
    }

    override func tearDown() {
        super.tearDown()
        image1 = nil
        image2 = nil
        sut = nil
    }

    func testBasics() {
        XCTAssertEqual(sut.images.count, 2)

        let mario = sut.images["Mario"]
        XCTAssertEqual(mario?.image, image1)
        XCTAssertEqual(mario?.fileName, "Mario.png")
        XCTAssertEqual(mario?.imageType, .png)

        let luigi = sut.images["Luigi"]
        XCTAssertEqual(luigi?.image, image2)
        XCTAssertEqual(luigi?.fileName, "Luigi.png")
        XCTAssertEqual(luigi?.imageType, .png)

        XCTAssertEqual(sut.formFields.count, 1)
        XCTAssertEqual(sut.boundary, boundary)
    }

    func testDefaultParameters() {
        let sut = MultiImageBuilder(
            images: sut.images,
            formFields: sut.formFields
        )

        // Boundary is different
        XCTAssertNotEqual(sut.boundary, boundary)
        // Boundary has correct length for UUID
        XCTAssertEqual(sut.boundary.count, boundary.count)
    }

    func testParts() {
        let parts = sut.parts
        XCTAssertEqual(parts.count, 3)

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
        XCTAssertEqual(files.count, 2)

        XCTAssertNotNil(parts["apiKey"])
        XCTAssertNotNil(parts["Mario"])
        XCTAssertNotNil(parts["Luigi"])
    }
}
