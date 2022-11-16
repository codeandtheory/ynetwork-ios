//
//  UrlRequest+FileSaverTests.swift
//  YNetworkTests
//
//  Created by Anand Kumar on 31/01/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class UrlRequestFileSaverTests: XCTestCase {
    private var url: URL!
    private var request: URLRequest!

    override func setUp() {
        super.setUp()
        url = URL(string: UnitTestPath.postImage.rawValue)
        request = URLRequest(url: url)
    }

    override func tearDown() {
        super.tearDown()
        url = nil
        request = nil
    }
    
    func testWriteDataToFile() throws {
        // Given a request with data
        let input = "This is a bad idea"
        request.httpBody = Data(input.utf8)

        // If we write it to a local file
        let url = try request.writeDataToFile()

        defer {
            // clean up the temporary file
            try? FileManager.default.removeItem(at: url)
        }

        // The data is as expected
        let data = try Data(contentsOf: url)
        let output = String(data: data, encoding: .utf8)
        XCTAssertEqual(input, output)
    }
    
    func testFetchLocalUrl() {
        // given two temporary URL's
        let url1 = request.fetchLocalUrl()
        let url2 = request.fetchLocalUrl()
        var pathComponents1 = url1.pathComponents
        var pathComponents2 = url2.pathComponents

        let last1 = pathComponents1.removeLast()
        let last2 = pathComponents2.removeLast()

        // the final component should be unique
        XCTAssertNotEqual(last1, last2)

        // the preceding components should be the temporary directory
        XCTAssertEqual(pathComponents1, FileManager.default.temporaryDirectory.pathComponents)
        XCTAssertEqual(pathComponents1, pathComponents2)
    }
}
