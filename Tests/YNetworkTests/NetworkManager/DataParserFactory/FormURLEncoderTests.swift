//
//  FormURLEncoderTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 10/15/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class FormURLEncoderTests: XCTestCase {
    private var sut: FormURLEncoder!

    override func setUp() {
        super.setUp()
        sut = FormURLEncoder()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testEncode() throws {
        // Given an object that does conform to ParametersBuilder
        let input = GroceryProduct.durian
        
        // When we try to encode it
        let output = try sut.encode(input)
        
        // Encoding should succeed
        XCTAssertNotNil(output)
        XCTAssertFalse(output.isEmpty)
        
        let string = String(data: output, encoding: .utf8)
        
        // The string it produces should be form URL encoded
        // (url query format but with " " replaced by "+")
        XCTAssertEqual(string, "description=A+fruit+with+a+distinctive+scent.&name=Durian&points=600")
    }
    
    func testSerializationError() {
        // Given an object that does not conform to ParametersBuilder
        let input = BodegaProduct.durian
        var output: Data?
        var caught: Error?
        
        // When we try to encode it
        do {
            output = try sut.encode(input)
        } catch {
            caught = error
        }
        
        // Encoding should fail
        XCTAssertNil(output)
        // It should throw SerializationError.toParameters error
        XCTAssertEqual(caught as? SerializationError, SerializationError.toParameters)
    }
}
