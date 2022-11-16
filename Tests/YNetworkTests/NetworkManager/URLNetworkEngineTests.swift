//
//  URLNetworkEngineTests.swift
//  YNetworkTests
//
//  Created by Sumit Goswami on 01/04/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class URLNetworkEngineTests: XCTestCase {
    private var sut: URLNetworkEngine!
    private var mockSut: MockURLNetworkEngine!

    override func setUp() {
        super.setUp()
        sut = URLNetworkEngine()
        mockSut = MockURLNetworkEngine()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        mockSut = nil
        URLProtocolStub.reset()
    }

    func testSutWithoutConfiguration() {
        XCTAssertNil(mockSut.configuration)
    }

    func testSutWithDefaultConfiguration() {
        XCTAssertNil(mockSut.configuration)

        mockSut.configure(with: NetworkEngineConfiguration())

        XCTAssertNotNil(mockSut.configuration)
        XCTAssertNil(mockSut.configuration?.headers)
        XCTAssertEqual(mockSut.configuration?.timeoutInterval, 0)
        XCTAssertNil(mockSut.configuration?.cachePolicy)
    }

    func testSutWithDataConfiguration() {
        mockSut.configure(with: NetworkEngineConfiguration(
            headers: ["platform": "iOS"],
            timeoutInterval: 60,
            cachePolicy: .useProtocolCachePolicy
        ))

        XCTAssertEqual(mockSut.configuration?.headers?["platform"], "iOS")
        XCTAssertEqual(mockSut.configuration?.timeoutInterval, 60)
        XCTAssertEqual(mockSut.configuration?.cachePolicy, .useProtocolCachePolicy)
    }

    func testSubmitWithoutConfiguration() async {
        guard let url = URL(string: "https://webaim.org/resources/contrastchecker") else {
            XCTFail("Invalid URL")
            return
        }

        do {
            _ = try await(sut.submit(URLRequest(url: url)))
            XCTFail("Expected submit to throw an error")
        } catch {
            XCTAssertEqual(
                error as? NetworkError,
                NetworkError.notConfigured,
                "Expected \(error) to be NetworkError.notConfigured"
            )
        }
    }

    func testSubmitWithConfiguration() async throws {
        guard let url = URL(string: "https://webaim.org/resources/contrastchecker") else {
            XCTFail("Invalid URL")
            return
        }
        mockSut.configure(with: NetworkEngineConfiguration())
        // Given a hard-coded 200 http response
        let httpResponse = makeHTTPURLResponse(url: url, statusCode: 200)
        mockSut.nextResponse = .success((Data(), httpResponse))

        _ = try await(mockSut.submit(URLRequest(url: url)))
    }

    func testSubmitDownloadWithoutConfiguration() {
        guard let url = URL(string: "https://webaim.org/resources/contrastchecker") else {
            XCTFail("Invalid URL")
            return
        }

        do {
            _ = try sut.submitBackgroundDownload(URLRequest(url: url))
            XCTFail("Expected submit to throw an error")
        } catch {
            XCTAssertEqual(
                error as? NetworkError,
                NetworkError.notConfigured,
                "Expected \(error) to be NetworkError.notConfigured"
            )
        }
    }

    func testDownload() {
        mockSut.configure(with: NetworkEngineConfiguration())

        guard let url = URL(string: "https://webaim.org/resources/contrastchecker") else {
            XCTFail("Invalid URL")
            return
        }

        do {
            let task = try mockSut.submitBackgroundDownload(URLRequest(url: url)) as? MockURLSessionTask
            XCTAssertNotNil(task)
            XCTAssertFalse(task?.isCancelled ?? true)
            task?.cancel()
            XCTAssertTrue(task?.isCancelled ?? false)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testSubmitBackgroundUploadWithoutConfiguration() {
        guard let url = URL(string: "https://webaim.org/resources/contrastchecker") else {
            XCTFail("Invalid URL")
            return
        }

        guard let filePath = Bundle.module.path(forResource: "marioRunRight", ofType: "gif") else {
            XCTFail("Invalid local file URL")
            return
        }

        let fileUrl = URL(fileURLWithPath: filePath)

        do {
            let urlRequest = URLRequest(url: url)
            _ = try sut.submitBackgroundUpload(
                urlRequest,
                fileUrl: fileUrl
            )
            XCTFail("Expected submit to throw an error")
        } catch {
            XCTAssertEqual(
                error as? NetworkError,
                NetworkError.notConfigured,
                "Expected \(error) to be NetworkError.notConfigured"
            )
        }
    }

    func testSubmitBackgroundUpload() {
        mockSut.configure(with: NetworkEngineConfiguration())

        guard let url = URL(string: "https://webaim.org/resources/contrastchecker") else {
            XCTFail("Invalid URL")
            return
        }

        guard let filePath = Bundle.module.path(forResource: "marioRunRight", ofType: "gif") else {
            XCTFail("Invalid local file URL")
            return
        }

        let fileUrl = URL(fileURLWithPath: filePath)

        do {
            let urlRequest = URLRequest(url: url)
            let task = try mockSut.submitBackgroundUpload(
                urlRequest,
                fileUrl: fileUrl
            ) as? MockURLSessionTask
            XCTAssertNotNil(task)
            XCTAssertFalse(task?.isCancelled ?? true)
            task?.cancel()
            XCTAssertTrue(task?.isCancelled ?? false)
        } catch {
            XCTFail("\(error)")
        }
    }
}

private extension URLNetworkEngineTests {
    private func makeHTTPURLResponse(url: URL, statusCode: Int) -> HTTPURLResponse {
        guard let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        ) else {
            XCTFail("Invalid HTTPURLResponse")
            return HTTPURLResponse()
        }

        return httpResponse
    }
}
