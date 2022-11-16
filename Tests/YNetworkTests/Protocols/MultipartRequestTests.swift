//
//  MultipartRequestTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 11/7/22.
//

import XCTest
@testable import YNetwork

final class MultipartRequestTests: XCTestCase {
    func testDefaults() {
        let sut = MockMultipartRequest()
        XCTAssertEqual(sut.method, .POST)
        XCTAssertEqual(sut.requestType, .multipart(boundary: sut.multipart.boundary))
        XCTAssertNotNil(sut.body as? MultipartBuilder)
    }
}

struct MockMultipartRequest: MultipartRequest {
    let multipart: MultipartBuilder = MockMultipart()

    var path: PathRepresentable { UnitTestPath.postImage }
}
