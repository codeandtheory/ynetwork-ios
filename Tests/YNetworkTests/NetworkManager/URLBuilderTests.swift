//
//  URLBuilderTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 9/22/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

typealias PathTestCase = (basePath: PathTestUrl?, path: String, output: String)
typealias FormUrlTestCase = (key: String, value: Any, output: String?)
typealias QueryTestCase = (params: Parameters, output: String)

enum PathTestUrl: String, PathRepresentable {
    case noTrailingSlash = "https://webaim.org"
    case trailingSlash = "https://webaim.org/"
    case doubleTrailingSlash = "https://webaim.org//"
}

final class URLBuilderTests: XCTestCase {
    private let pathTestCases: [PathTestCase] = [
        (nil, "https://webaim.org/resources/contrastchecker", "https://webaim.org/resources/contrastchecker"),
        (.noTrailingSlash, "resources/contrastchecker", "https://webaim.org/resources/contrastchecker"),
        (.noTrailingSlash, "/resources/contrastchecker", "https://webaim.org/resources/contrastchecker"),
        (.noTrailingSlash, "//resources/contrastchecker", "https://webaim.org/resources/contrastchecker"),
        (.noTrailingSlash, "/resources/contrastchecker?api", "https://webaim.org/resources/contrastchecker?api"),
        (.trailingSlash, "resources/contrastchecker", "https://webaim.org/resources/contrastchecker"),
        (.trailingSlash, "/resources/contrastchecker", "https://webaim.org/resources/contrastchecker"),
        (.trailingSlash, "//resources/contrastchecker", "https://webaim.org/resources/contrastchecker"),
        (.trailingSlash, "/resources/contrastchecker?api", "https://webaim.org/resources/contrastchecker?api"),
        (.doubleTrailingSlash, "resources/contrastchecker", "https://webaim.org/resources/contrastchecker"),
        (.doubleTrailingSlash, "/resources/contrastchecker", "https://webaim.org/resources/contrastchecker"),
        (.doubleTrailingSlash, "//resources/contrastchecker", "https://webaim.org/resources/contrastchecker"),
        (.doubleTrailingSlash, "/resources/contrastchecker?api", "https://webaim.org/resources/contrastchecker?api")
    ]
    
    private let formUrlTestCases: [FormUrlTestCase] = [
        ("name", "John", "name=John"),
        ("full name", "John Doe", "full+name=John+Doe"),
        ("full name+", "Johnny+ Doe", "full+name%2B=Johnny%2B+Doe"),
        ("full&name", "John&Doe", "full%26name=John%26Doe"),
        ("full=name", "John=Doe", "full%3Dname=John%3DDoe"),
        ("is Hidden", true, "is+Hidden"),
        ("api", false, nil)
    ]
    
    private let queryTestCases: [QueryTestCase] = [
        (["name": "John"], "name=John"),
        (["count": 1], "count=1"),
        (["api": true], "api"),
        (["api": false], ""),
        (["firstName": "John", "lastName": "Doe"], "firstName=John&lastName=Doe"),
        (["c": 10, "b": "book", "a": true], "a&b=book&c=10"),
        (
            ["name": "Beans", "points": 100, "description": "The musical fruit"],
            "description=The%20musical%20fruit&name=Beans&points=100"
        )
    ]
    
    private var sut: URLBuilder! = URLBuilder()
    private var configuration: NetworkManagerConfiguration!
    
    override func setUp() {
        super.setUp()
        sut = URLBuilder()
        configuration = NetworkManagerConfiguration()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        configuration = nil
    }
    
    func testPath() throws {
        pathTestCases.forEach {
            let request = MockRequest(basePath: $0.basePath, path: $0.path)

            XCTAssertEqual(
                try? sut.path(for: request, configuration: configuration),
                $0.output,
                "Expected \($0.basePath?.pathValue ?? "") + \($0.path) = \($0.output)"
            )
        }
    }
    
    func testNoBasePath() {
        let request = MockRequest(path: "/resources/contrastchecker")
        
        do {
            let path = try sut.path(for: request, configuration: configuration)
            XCTAssert(false, "Expected \(path) to throw an error")
        } catch {
            XCTAssertEqual(
                error as? NetworkError,
                NetworkError.noBasePath,
                "Expected \(error) to be NetworkError.noBasePath"
            )
        }
        
        do {
            let url = try sut.url(for: request, configuration: configuration)
            XCTAssert(false, "Expected \(url) to throw an error")
        } catch {
            XCTAssertEqual(
                error as? NetworkError,
                NetworkError.noBasePath,
                "Expected \(error) to be NetworkError.noBasePath"
            )
        }
    }
    
    func testURL() throws {
        pathTestCases.forEach {
            let request = MockRequest(basePath: $0.basePath, path: $0.path)
            
            XCTAssertEqual(
                try? sut.url(for: request, configuration: configuration),
                URL(string: $0.output),
                "Expected \($0.basePath?.pathValue ?? "") + \($0.path) = \($0.output)"
            )
        }
    }

    func testInvalidURL() {
        let request = MockRequest(path: "https://web aim.org/resources/contrastchecker")

        do {
            let url = try sut.url(for: request, configuration: configuration)
            XCTAssert(false, "Expected \(url) to throw an error")
        } catch {
            XCTAssertEqual(
                error as? NetworkError,
                NetworkError.invalidURL,
                "Expected \(error) to be NetworkError.invalidURL"
            )
        }
    }

    func testNotConfigured() {
        let request = MockRequest(path: "https://web aim.org/resources/contrastchecker")
        var url: URL?

        do {
            url = try sut.url(for: request, configuration: nil)
            XCTAssert(false, "Expected to throw NetworkError.notConfigured")
        } catch {
            XCTAssertEqual(
                error as? NetworkError,
                NetworkError.notConfigured,
                "Expected \(error) to be NetworkError.notConfigured"
            )
        }

        XCTAssertNil(url)
    }

    func testFormUrlParams() {
        formUrlTestCases.forEach {
            let param = sut.queryParameterString(field: $0.key, value: $0.value, contentType: .formURLEncoded)
            XCTAssertEqual(
                param,
                $0.output,
                "Expected \($0.output ?? ""), but got \(param ?? "")"
            )
        }
    }
    
    func testPercentEncoding() {
        let unencodable = String(
            bytes: [0xD8, 0x00] as [UInt8],
            encoding: String.Encoding.utf16BigEndian
        ) ?? ""
        XCTAssertFalse(unencodable.isEmpty)
        let param1 = sut.queryParameterString(field: "flag", value: unencodable, contentType: .formURLEncoded)
        let param2 = sut.queryParameterString(field: unencodable, value: true, contentType: .formURLEncoded)
        let param3 = sut.queryParameterString(field: unencodable, value: unencodable, contentType: .JSON)
        XCTAssertNil(param1)
        XCTAssertNil(param2)
        XCTAssertNil(param3)
    }
    
    func testQueryStrings() {
        queryTestCases.forEach {
            let queryString = sut.queryString(with: $0.params, contentType: .JSON)
            XCTAssertEqual(
                queryString,
                $0.output,
                "Expected \($0.output), but got \(queryString)"
            )
        }
    }
    
    func testUrlWithQuery() {
        let request = MockRequest(
            path: "https://webaim.org/resources/contrastchecker",
            queryParameters: ["fcolor": "000000", "bcolor": "FFFFFF", "api": true]
        )

        let url: URL! = try? sut.url(for: request, configuration: configuration)
        XCTAssertNotNil(url)
        XCTAssertEqual(
            url.absoluteString,
            "https://webaim.org/resources/contrastchecker?api&bcolor=FFFFFF&fcolor=000000"
        )
    }
    
    func testUrlWithIntQueryParameters() {
        let request = MockRequest(
            path: "https://webaim.org/resources/contrastchecker",
            queryParameters: ["page": "1"]
        )

        let url: URL! = try? sut.url(for: request, configuration: configuration)
        XCTAssertNotNil(url)
        XCTAssertEqual(
            url.absoluteString,
            "https://webaim.org/resources/contrastchecker?page=1"
        )
    }
    
    func testUrlWithBoolQueryParameters() {
        let request = MockRequest(
            path: "https://webaim.org/resources/contrastchecker",
            queryParameters: ["page": true]
        )

        let url: URL! = try? sut.url(for: request, configuration: configuration)
        XCTAssertNotNil(url)
        XCTAssertEqual(
            url.absoluteString,
            "https://webaim.org/resources/contrastchecker?page"
        )
    }

    func testUrlWithAdditionalQueryParams() {
        let request = MockRequest(
            path: "https://webaim.org/resources/contrastchecker?api",
            queryParameters: ["fcolor": "000000", "bcolor": "FFFFFF"]
        )

        let url: URL! = try? sut.url(for: request, configuration: configuration)
        XCTAssertNotNil(url)
        XCTAssertEqual(
            url.absoluteString,
            "https://webaim.org/resources/contrastchecker?api&bcolor=FFFFFF&fcolor=000000"
        )
    }
    
    func testJSONUrlWithQueryParams() throws {
        let request = MockRequest(
            path: "https://fakeapi/signup",
            queryParameters: ["full Name": "John Doe"]
        )

        do {
            let url = try sut.url(for: request, configuration: configuration)
            XCTAssertEqual(
                url.absoluteString,
                "https://fakeapi/signup?full%20Name=John%20Doe"
            )
        } catch {
            throw error
        }
    }
    
    func testFormUrlWithQueryParams() throws {
        let request = MockRequest(
            path: "https://fakeapi/signup",
            requestType: .formURLEncoded,
            queryParameters: ["full Name": "John Doe"]
        )

        do {
            let url = try sut.url(for: request, configuration: configuration)
            XCTAssertEqual(
                url.absoluteString,
                "https://fakeapi/signup?full+Name=John+Doe"
            )
        } catch {
            throw error
        }
    }
}
