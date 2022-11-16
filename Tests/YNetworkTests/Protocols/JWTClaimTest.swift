//
//  JWTClaimTest.swift
//  YNetworkTests
//
//  Created by Sanjib Chakraborty on 01/02/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

class JWTClaimTest: XCTestCase {
    private let interval = Date().timeIntervalSince1970
    
    private var stringSut: JWTClaim!
    private var doubleStringSut: JWTClaim!
    private var doubleSut: JWTClaim!
    private var stringArraySut: JWTClaim!
    private var integerArraySut: JWTClaim!
    private var dateSut: JWTClaim!
    
    override func setUp() {
        super.setUp()

        stringSut = JWTClaim(value: "YNetwork")
        doubleStringSut = JWTClaim(value: "2.5")
        doubleSut = JWTClaim(value: 2.4)
        stringArraySut = JWTClaim(value: ["1", "2"])
        integerArraySut = JWTClaim(value: [1, 2])
        dateSut = JWTClaim(value: interval)
    }

    override func tearDown() {
        super.tearDown()
        
        stringSut = nil
        doubleStringSut = nil
        doubleSut = nil
        stringArraySut = nil
        integerArraySut = nil
        dateSut = nil
    }

    func testStringClaim() {
        XCTAssertEqual(stringSut.string, "YNetwork")
        XCTAssertEqual(stringSut.array, ["YNetwork"])
        XCTAssertNil(stringSut.double)
        XCTAssertNil(stringSut.integer)
        XCTAssertNil(stringSut.date)
    }

    func testDoubleClaim() {
        XCTAssertEqual(doubleSut.double, 2.4)
        XCTAssertNil(doubleSut.string)
        XCTAssertNil(doubleSut.array)
        XCTAssertEqual(doubleSut.integer, 2)
        XCTAssertNotNil(doubleSut.date)
    }

    func testDoubleStringClaim() {
        XCTAssertEqual(doubleStringSut.double, 2.5)
        XCTAssertEqual(doubleStringSut.string, "2.5")
        XCTAssertEqual(doubleStringSut.array, ["2.5"])
        XCTAssertNil(doubleStringSut.integer)
        XCTAssertNotNil(doubleStringSut.date)
    }

    func testStringArrayClaim() {
        XCTAssertNil(stringArraySut.double)
        XCTAssertNil(stringArraySut.string)
        XCTAssertNil(stringArraySut.integer)
        XCTAssertNil(stringArraySut.date)
        XCTAssertEqual(stringArraySut.array, ["1", "2"])
    }

    func testIntegerArrayClaim() {
        XCTAssertNil(integerArraySut.double)
        XCTAssertNil(integerArraySut.string)
        XCTAssertNil(integerArraySut.integer)
        XCTAssertNil(integerArraySut.date)
        XCTAssertNil(integerArraySut.array)
    }

    func testDateClaim() {
        XCTAssertEqual(dateSut.double, interval)
        XCTAssertNil(dateSut.string)
        XCTAssertEqual(dateSut.integer, Int(interval))
        XCTAssertEqual(dateSut.date?.timeIntervalSince1970, interval)
        XCTAssertNil(dateSut.array)
    }
}
