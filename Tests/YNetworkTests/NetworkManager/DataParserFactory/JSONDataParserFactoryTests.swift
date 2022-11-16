//
//  JSONDataParserFactoryTests.swift
//  YNetworkTests
//
//  Created by Sumit Goswami on 22/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class JSONDataParserFactoryTests: XCTestCase {
    private var sut: JSONDataParserFactory!
    private var jsonData: Data!
    
    override func setUp() {
        super.setUp()
        sut = JSONDataParserFactory()
        jsonData = """
           {
             "name": "Durian",
             "points": 600,
             "description": "A fruit with a distinctive scent."
           }
           """.data(using: .utf8)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        jsonData = nil
    }
    
    func testInit() {
        XCTAssertNotNil(sut.decoder(for: .JSON))
        XCTAssertNotNil(sut.encoder(for: .JSON))
        XCTAssertNotNil(sut.encoder(for: .formURLEncoded))
        
        XCTAssertNil(sut.decoder(for: .none))
        XCTAssertNil(sut.decoder(for: .binary))
        XCTAssertNil(sut.encoder(for: .none))
        XCTAssertNil(sut.encoder(for: .binary))
    }
    
    func testInitWithDecoderEncoder() {
        let inDecoder = JSONDecoder()
        let inEncoder = JSONEncoder()
        let factory = JSONDataParserFactory(decoder: inDecoder, encoder: inEncoder)
        
        let outDecoder = factory.decoder(for: .JSON) as? JSONDecoder
        let outEncoder = factory.encoder(for: .JSON) as? JSONEncoder
        
        XCTAssertNotNil(outDecoder)
        XCTAssertNotNil(outEncoder)
        XCTAssertNotNil(factory.encoder(for: .formURLEncoded))

        XCTAssertNil(factory.decoder(for: .none))
        XCTAssertNil(factory.decoder(for: .binary))
        XCTAssertNil(factory.encoder(for: .none))
        XCTAssertNil(factory.encoder(for: .binary))
    }

    func testJSONDecode() throws {
        guard let decoder = sut.decoder(for: .JSON) else {
            throw NetworkError.noDecoder
        }
        
        // Given a JSON decoder, some JSON data, and a model that conforms to Decodable,
        // we should be able to decode an object from the JSON data
        let output = try decoder.decode(GroceryProduct.self, from: jsonData)
        
        // That object should hold all the correct values
        let expected = GroceryProduct.durian
        XCTAssertEqual(output.name, expected.name)
        XCTAssertEqual(output.points, expected.points)
        XCTAssertEqual(output.description, expected.description)
    }
    
    func testJSONEncode() throws {
        guard let encoder = sut.encoder(for: .JSON) else {
            throw NetworkError.noEncoder
        }
        
        // Given a JSON encoder and a model that conforms to Encodable
        let input = GroceryProduct.durian
        
        // It should be encodable to Data
        let data = try encoder.encode(input)
        
        // that data should be decodable to a dictionary
        guard let output = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                as? Parameters else {
                    throw SerializationError.toParameters
                }
        
        // That dictionary should hold all the fields with the
        // same values as the original model
        XCTAssertEqual(output["name"] as? String, input.name)
        XCTAssertEqual(output["points"] as? Int, input.points)
        XCTAssertEqual(output["description"] as? String, input.description)
    }
    
    func testFormURLEncode() throws {
        guard let encoder = sut.encoder(for: .formURLEncoded) else {
            throw NetworkError.noEncoder
        }
        
        // Given a form URL encoder and a model that conforms to ParametersBuilder
        let data = try encoder.encode(GroceryProduct.durian)
        let string = String(data: data, encoding: .utf8)
        
        // The string it produces should be form URL encoded
        // (url query format but with " " replaced by "+")
        XCTAssertEqual(string, "description=A+fruit+with+a+distinctive+scent.&name=Durian&points=600")
    }
}
