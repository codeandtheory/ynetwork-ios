//
//  JWTTokenTest.swift
//  YNetworkTests
//
//  Created by Sanjib Chakraborty on 01/02/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

class JWTTokenTest: XCTestCase {
    private let jwtString = """
        eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\
            .eyJlbWFpbCI6InNhbjFAZ21haWwuY29\
        tIiwibmFtZSI6IkpvaG4gRG9lIiwiY3JlY\
        XRlZEF0IjoxNjQzMjc4MTQ3NDA2LCJzb\
        3VyY2UiOiJsb2NhbCIsImlhdCI6MTY0MzI3ODE0N\
        ywiZXhwIjoxNjQzMzM4MTQ3LCJpc3MiOiJ5bWwifQ.\
        qvRQppqdO2PgHqScuYVywjAttC7uTiS0FDrN95R1N2E
        """
    
    private let jwtStringWithoutExpiry = """
        eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\
        .eyJjcmVhdGVkQXQiOjE2NDMyNzgxNDc0\
        MDYsImVtYWlsIjoic2FuMUBnbWFpbC5jb20i\
        LCJuYW1lIjoiSm9obiBEb2UiLCJzb3VyY2Ui\
        OiJsb2NhbCIsImlhdCI6MTY0MzI3ODE0Nywi\
        aXNzIjoieW1sIn0.FAIiqGDNERxXimZV3jTi\
        5N_mufL_AKzjFW0798z-1qY
        """
    
    private let jwtIssuer = "yml"
    private let jwtExpiresAt: Double = 1643338147
    private let jwtIssuedAt: Double = 1643278147
    
    private var validSut: JWTToken!
    private var withoutExpirySut: JWTToken!
    
    private var invalidSut: JWTToken!
    private var jwtError: JWTDecodeError?
    
    override func setUpWithError() throws {
        try super.setUpWithError()

        validSut = try JWTToken(jwtString: jwtString)
        
        withoutExpirySut = try JWTToken(jwtString: jwtStringWithoutExpiry)
        
        do {
            invalidSut = try JWTToken(jwtString: jwtString.appending(".YNETWORK"))
        } catch {
            jwtError = error as? JWTDecodeError
        }
    }

    override func tearDown() {
        super.tearDown()
        
        validSut = nil
        withoutExpirySut = nil
        
        invalidSut = nil
        jwtError = nil
    }

    func testValidJWT() {
        XCTAssertNotNil(validSut)
        XCTAssertEqual(validSut.string, jwtString)
        XCTAssertEqual(validSut.signature, jwtString.components(separatedBy: ".").last)
        XCTAssertNotNil(validSut.body)
        XCTAssertNotNil(validSut.header)
        XCTAssertEqual(validSut.issuer, jwtIssuer)
        XCTAssertEqual(validSut.expiresAt, Date(timeIntervalSince1970: jwtExpiresAt))
        XCTAssertEqual(validSut.issuedAt, Date(timeIntervalSince1970: jwtIssuedAt))
        XCTAssertEqual(validSut.isExpired, validSut.expiresAt?.compare(Date()) != ComparisonResult.orderedDescending)
        XCTAssertNil(validSut.subject)
        XCTAssertNil(validSut.audience)
        XCTAssertNil(validSut.notBefore)
        XCTAssertNil(validSut.identifier)
    }
    
    func testWithoutExpiryJWT() {
        XCTAssertNotNil(withoutExpirySut)
        XCTAssertEqual(withoutExpirySut.string, jwtStringWithoutExpiry)
        XCTAssertEqual(withoutExpirySut.signature, jwtStringWithoutExpiry.components(separatedBy: ".").last)
        XCTAssertNotNil(withoutExpirySut.body)
        XCTAssertNotNil(withoutExpirySut.header)
        XCTAssertEqual(withoutExpirySut.issuer, jwtIssuer)
        XCTAssertEqual(withoutExpirySut.expiresAt, nil)
        XCTAssertEqual(withoutExpirySut.issuedAt, Date(timeIntervalSince1970: jwtIssuedAt))
        XCTAssertEqual(withoutExpirySut.isExpired, false)
        XCTAssertNil(withoutExpirySut.subject)
        XCTAssertNil(withoutExpirySut.audience)
        XCTAssertNil(withoutExpirySut.notBefore)
        XCTAssertNil(withoutExpirySut.identifier)
    }
    
    func testInvalidJWT() {
        XCTAssertNil(invalidSut)
        XCTAssertEqual(jwtError, .invalidPartCount(jwtString.appending(".YNETWORK"), 4))
    }
    
    func testInvalidJsonDecodeError() {
        // Passing a base64 string for the below invalid JSON
        /*{
          "alg": "HS256"
          "typ": "JWT"
        }*/
        
        let myString = "ewogICJhbGciOiAiSFMyNTYiCiAgInR5cCI6ICJKV1QiCn0="
        do {
            _ = try JWTToken.decodeJWTPart(myString)
            XCTFail("Expected to throw an error")
        } catch {
            XCTAssertEqual(error as? JWTDecodeError, .invalidJSON(myString))
        }
    }
    
    func testInvalidBase64DecodeError() {
        // As % is not allowed in base64 encoding, so passing a string containing %
        let myString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ%9"
        do {
            _ = try JWTToken.decodeJWTPart(myString)
            XCTFail("Expected to throw an error")
        } catch {
            XCTAssertEqual(error as? JWTDecodeError, .invalidBase64(myString))
        }
    }
}
