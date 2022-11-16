//
//  BodyBuilderTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 10/15/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class BodyBuilderTests: XCTestCase {
    private var jsonString: String!
    private var jsonData: Data!

    override func setUp() {
        super.setUp()
        jsonString = """
           {
             "name": "Durian",
             "points": 600,
             "description": "A fruit with a distinctive scent."
           }
           """
        jsonData = jsonString.data(using: .utf8)
    }
    
    override func tearDown() {
        super.tearDown()
        jsonString = nil
        jsonData = nil
    }

    func testDataNoEncoder() throws {
        // Given some data and no encoder
        let input: BodyBuilder = jsonData
        
        // Body should just return the data
        let output = try input.body(encoder: nil)
        XCTAssertEqual(input as? Data, output)
    }

    func testDataWithEncoder() throws {
        // Given some data and an encoder
        let input: BodyBuilder = jsonData
        let encoder = DataReverser()
        
        // Body should encode the data
        let output = try input.body(encoder: encoder)
        let expected = Data(jsonData.reversed())
        XCTAssertEqual(output, expected)
    }

    func testDataEncoderWithError() {
        // Given some data and an encoder
        let input = GroceryProduct.durian
        let encoder = DataReverser()
        var output: Data?
        var caught: Error?

        // Body should encode the data
        // When we try to encode a body from the object
        do {
            output = try input.body(encoder: encoder)
        } catch {
            caught = error
        }

        // We don't expect any data
        XCTAssertNil(output)
        // but we do expect a noEncoder error
        XCTAssertEqual(caught as? SerializationError, SerializationError.toBody)
    }
    
    func testEncodableNoEncoder() {
        // Given an encodable object and no encoder
        let input = GroceryProduct.durian
        var output: Data?
        var caught: Error?
        
        // When we try to encode a body from the object
        do {
            output = try input.body(encoder: nil)
        } catch {
            caught = error
        }
        
        // We don't expect any data
        XCTAssertNil(output)
        // but we do expect a noEncoder error
        XCTAssertEqual(caught as? NetworkError, NetworkError.noEncoder)
    }
    
    func testEncodableWithEncoder() throws {
        // Given a codable object and an encoder
        let input = GroceryProduct.durian
        let encoder = JSONEncoder()
        
        // When we try to encode a body from the object
        let data = try input.body(encoder: encoder)
        
        // We do expect to have data
        XCTAssertFalse(data.isEmpty)
        
        // that data should be decodable back to an object
        let decoder = JSONDecoder()
        let output = try decoder.decode(GroceryProduct.self, from: data)
        
        // The decoded object should match the original
        XCTAssertEqual(input, output)
    }
}

struct DataReverser: DataEncoder {
    func encode<T>(_ value: T) throws -> Data where T: Encodable {
        guard let data = value as? Data else {
            throw SerializationError.toBody
        }
        
        return Data(data.reversed())
    }
}
