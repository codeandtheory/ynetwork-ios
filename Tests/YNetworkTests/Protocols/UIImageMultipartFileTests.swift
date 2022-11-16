//
//  UIImageMultipartFileTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 1/13/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class UIImageMultipartFileTests: XCTestCase {
    private let imageName = "Mario"
    private let fileName = UUID().uuidString

    private var image: UIImage!

    override func setUp() {
        super.setUp()
        image = UIImage(named: imageName, in: Bundle.module, with: nil)
    }

    override func tearDown() {
        super.tearDown()
        image = nil
    }

    func testJPG() {
        let jpg: UIImageMultipartFile = UIImageMultipartFileInfo(
            image: image,
            fileName: fileName,
            imageType: .jpg(compression: 0.70)
        )

        // Basics
        XCTAssertEqual(jpg.image, image)
        XCTAssertEqual(jpg.fileName, fileName)
        XCTAssertEqual(jpg.imageType, .jpg(compression: 0.70))

        // MIME type should be jpg
        XCTAssertEqual(jpg.mimeType, "image/jpg")
        // data should be non-zero
        XCTAssertGreaterThan(jpg.data?.count ?? 0, 1000)
    }

    func testJPEG() {
        let jpeg: UIImageMultipartFile = UIImageMultipartFileInfo(
            image: image,
            fileName: fileName,
            imageType: .jpeg(compression: 0.75)
        )

        // Basics
        XCTAssertEqual(jpeg.image, image)
        XCTAssertEqual(jpeg.fileName, fileName)
        XCTAssertEqual(jpeg.imageType, .jpeg(compression: 0.75))

        // MIME type should be jpeg
        XCTAssertEqual(jpeg.mimeType, "image/jpeg")
        // data should be non-zero
        XCTAssertGreaterThan(jpeg.data?.count ?? 0, 1000)
    }

    func testPNG() {
        let png: UIImageMultipartFile = UIImageMultipartFileInfo(
            image: image,
            fileName: fileName,
            imageType: .png
        )

        // Basics
        XCTAssertEqual(png.image, image)
        XCTAssertEqual(png.fileName, fileName)
        XCTAssertEqual(png.imageType, .png)

        // MIME type should be png
        XCTAssertEqual(png.mimeType, "image/png")
        // data should be non-zero
        XCTAssertGreaterThan(png.data?.count ?? 0, 1000)
    }

    func testNilData() {
        // Given an empty image
        let file: UIImageMultipartFile = UIImageMultipartFileInfo(
            image: UIImage(),
            fileName: fileName,
            imageType: .png
        )

        // data should be nil
        XCTAssertNil(file.data)
    }
}
