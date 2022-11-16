//
//  NetworkEngineConfigurationTests.swift
//  YNetworkTests
//
//  Created by Sanjib Chakraborty on 30/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class NetworkEngineConfigurationTests: XCTestCase {
    private var defaultSut: NetworkEngineConfiguration!
    private var dataSut: NetworkEngineConfiguration!
    private var networkManagerConfigurationSut: NetworkManagerConfiguration!
    
    override func setUp() {
        super.setUp()
        
        defaultSut = NetworkEngineConfiguration()
        
        dataSut = NetworkEngineConfiguration(
            headers: ["platform": "iOS"],
            timeoutInterval: 60,
            cachePolicy: .useProtocolCachePolicy
        )
        
        networkManagerConfigurationSut = NetworkManagerConfiguration()
    }

    override func tearDown() {
        super.tearDown()
        
        defaultSut = nil
        dataSut = nil
        networkManagerConfigurationSut = nil
    }

    func testDefaultParams() {
        XCTAssertNil(defaultSut.headers)
        XCTAssertEqual(defaultSut.timeoutInterval, 0)
        XCTAssertNil(defaultSut.cachePolicy)
    }
    
    func testDataSut() {
        XCTAssertEqual(dataSut.headers?["platform"], "iOS")
        XCTAssertEqual(dataSut.timeoutInterval, 60)
        XCTAssertEqual(dataSut.cachePolicy, .useProtocolCachePolicy)
    }
    
    func testEngineConfigurationFromManagerConfiguration() {
        XCTAssertNil(networkManagerConfigurationSut.engineConfiguration.headers)
        XCTAssertEqual(networkManagerConfigurationSut.engineConfiguration.timeoutInterval, 0)
        XCTAssertNil(networkManagerConfigurationSut.engineConfiguration.cachePolicy)
    }
}
