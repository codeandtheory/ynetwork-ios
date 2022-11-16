//
//  URLProtocolStubNetworkEngineTests.swift
//  YNetworkTests
//
//  Created by Karthik K Manoj on 02/11/22.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

// It's OK to have lots of unit test code
// swiftlint:disable file_length

final class URLProtocolStubNetworkEngineTests: XCTestCase {
    override func tearDown() {
        super.tearDown()

        URLProtocolStub.reset()
    }

    func test_init_deliversNonEmptyProtocolClasses() {
        XCTAssertEqual(makeSUT().protocolClasses.count, 1)
    }

    func test_initWithEmptyProtocolClass_deliversEmptyProtocolClasses() {
        // zero item
        XCTAssertTrue(makeSUT(protocolClasses: []).protocolClasses.isEmpty)
    }

    func test_initWithOneProtocolClass_deliversOneProtocolClass() {
        // one item
        XCTAssertEqual(makeSUT(protocolClasses: [URLProtocolStub.self]).protocolClasses.count, 1)
    }

    func test_initWithMultipleProtocolClasses_deliversMultipleProtocolClasses() {
        // more than one
        XCTAssertEqual(makeSUT(protocolClasses: [URLProtocolStub.self, URLProtocolStub.self]).protocolClasses.count, 2)
    }

    func test_configure_setsSession() {
        let sut = makeSUT()

        XCTAssertNil(sut.session)
        
        sut.configure(with: NetworkEngineConfiguration())

        XCTAssertNotNil(sut.session)
    }

    func test_configure_deliversOneProtocolClass() {
        let sut = makeSUT()

        sut.configure(with: NetworkEngineConfiguration())

        XCTAssertEqual(sut.session.configuration.protocolClasses?.count, 1)
    }

    func test_configureWithEmptyConfiguration_doesNotDeliverDelegate() {
        let sut = makeSUT()

        sut.configure(with: NetworkEngineConfiguration())

        XCTAssertNil(sut.session.delegate)
    }

    func test_configureWithNonEmptyConfiguration_deliversDelegate() {
        let sut = makeSUT()
        let sessionDelegate = SessionDelegate()
        
        sut.configure(with: NetworkEngineConfiguration(sessionDelegate: sessionDelegate))

        XCTAssertNotNil(sut.session.delegate)
    }

    func test_submitWithConfiguration_deliversDataOnSuccess() async throws {
        let sut = makeSUT()

        sut.configure(with: NetworkEngineConfiguration())

        let expectedData = makeData()
        let expectedResponse = makeHttpResponse(statusCode: 200)

        XCTAssertEqual(URLProtocolStub.messages.count, 0)
        URLProtocolStub.appendStub(
            .success((expectedData, expectedResponse)),
            type: .data
        )
        XCTAssertEqual(URLProtocolStub.messages.count, 1)

        guard let url = expectedResponse.url else {
            XCTFail("Failed to generate an URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        let (receivedData, receivedResponse) = try await sut.submit(urlRequest)

        XCTAssertEqual(URLProtocolStub.messages.count, 0)
        XCTAssertEqual(receivedData, expectedData)
        XCTAssertEqual(receivedResponse.url, expectedResponse.url)
    }

    func test_submitWithConfiguration_deliversObjectOnSuccess() async throws {
        let sut = makeSUT()

        sut.configure(with: NetworkEngineConfiguration())

        XCTAssertEqual(URLProtocolStub.messages.count, 0)
        URLProtocolStub.appendStub(withJSONObject: TriviaResponse.makeJSON(), statusCode: 200)
        XCTAssertEqual(URLProtocolStub.messages.count, 1)

        let urlRequest = URLRequest(url: makeURL(UnitTestPath.openTriviaDb.rawValue))
        let (receivedData, receivedResponse) = try await sut.submit(urlRequest)

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let receivedObject = try jsonDecoder.decode(TriviaResponse.self, from: receivedData)

        XCTAssertEqual(URLProtocolStub.messages.count, 0)
        XCTAssertEqual((receivedResponse as? HTTPURLResponse)?.statusCode, 200)
        XCTAssertEqual(receivedObject.responseCode, 0)
        XCTAssertEqual(receivedObject.results.count, 2)
    }

    func test_submitWithoutStub_deliversError() async throws {
        let sut = makeSUT()

        sut.configure(with: NetworkEngineConfiguration())

        XCTAssertEqual(URLProtocolStub.messages.count, 0)

        let urlRequest = URLRequest(url: makeURL(UnitTestPath.openTriviaDb.rawValue))

        do {
            let (_, _) = try await sut.submit(urlRequest)

            XCTFail("Expected to throw error when no stub is set")
        } catch {
            // Expected error
        }
    }

    func test_submitWithConfiguration_deliversErrorOnFailure() async throws {
        let sut = makeSUT()

        sut.configure(with: NetworkEngineConfiguration())

        let expectedError = makeError()
        URLProtocolStub.appendStub(.failure(expectedError), type: .data)

        do {
            _ = try await sut.submit(URLRequest(url: makeURL()))
        } catch {
            XCTAssertEqual((error as NSError).code, expectedError.code)
            XCTAssertEqual((error as NSError).domain, expectedError.domain)
        }
    }

    func test_submitWithoutConfiguration_deliversError() async throws {
        do {
            _ = try await makeSUT().submit(URLRequest(url: makeURL()))
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.notConfigured)
        }
    }

    func test_submitBackgroundDownloadWithConfiguration_deliversDataOnSuccess() throws {
        let sut = makeSUT()
        let sessionDelegate = SessionDelegate()

        let expectation = expectation(description: "Wait for download completion.")
        sessionDelegate.expectation = expectation

        sut.configure(with: NetworkEngineConfiguration(sessionDelegate: sessionDelegate))

        let expectedData = makeData()
        let expectedResponse = makeHttpResponse(statusCode: 200)
        URLProtocolStub.appendStub(
            .success((expectedData, expectedResponse)),
            type: .download
        )

        guard let url = expectedResponse.url else {
            XCTFail("Failed to generate an URL")
            return
        }
        let urlRequest = URLRequest(url: url)

        XCTAssertNil(sessionDelegate.totalBytesWritten)
        XCTAssertNil(sessionDelegate.didFinishDownloadingTo)

        XCTAssertNoThrow(try sut.submitBackgroundDownload(urlRequest))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(sessionDelegate.totalBytesWritten, Int64(expectedData.count))
        XCTAssertNotNil(sessionDelegate.didFinishDownloadingTo)
    }

    func test_submitBackgroundDownloadWithConfiguration_deliversErrorOnFailure() throws {
        let sut = makeSUT()
        let sessionDelegate = SessionDelegate()

        let expectation = expectation(description: "Wait for download completion.")
        sessionDelegate.expectation = expectation

        sut.configure(with: NetworkEngineConfiguration(sessionDelegate: sessionDelegate))

        URLProtocolStub.appendStub(.failure(makeError()), type: .download)

        XCTAssertNil(sessionDelegate.receivedError)

        let task = try sut.submitBackgroundDownload(URLRequest(url: makeURL()))
        XCTAssertNoThrow(task)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertNotNil(sessionDelegate.receivedError)
    }

    func test_submitBackgroundDownloadWithoutConfiguration_deliversError() throws {
        do {
            _ = try makeSUT().submitBackgroundDownload(URLRequest(url: makeURL()))
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.notConfigured)
        }
    }

    func test_submitBackgroundUploadWithConfiguration_deliversDataOnSuccess() throws {
        let sut = makeSUT()
        let sessionDelegate = SessionDelegate()

        let expectation = expectation(description: "Wait for upload completion.")
        sessionDelegate.expectation = expectation

        sut.configure(with: NetworkEngineConfiguration(sessionDelegate: sessionDelegate))

        let expectedData = "Success".data(using: .utf8) ?? Data()
        let expectedResponse = makeHttpResponse(statusCode: 200)
        URLProtocolStub.appendStub(
            .success((expectedData, expectedResponse)),
            type: .upload
        )

        guard let url = expectedResponse.url else {
            XCTFail("Failed to generate an URL")
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = makeData()
        urlRequest.httpMethod = "POST"

        XCTAssertFalse(sessionDelegate.didFinishUploading)

        XCTAssertNoThrow(try sut.submitBackgroundUpload(urlRequest, fileUrl: makeURL()))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertNil(sessionDelegate.totalBytesWritten)
        XCTAssertTrue(sessionDelegate.didFinishUploading)
    }

    func test_submitBackgroundUploadWithoutStub_deliversError() throws {
        let sut = makeSUT()
        let sessionDelegate = SessionDelegate()

        let expectation = expectation(description: "Wait for upload completion.")
        sessionDelegate.expectation = expectation

        sut.configure(with: NetworkEngineConfiguration(sessionDelegate: sessionDelegate))

        var urlRequest = URLRequest(url: makeURL())
        urlRequest.httpBody = makeData()
        urlRequest.httpMethod = "POST"

        XCTAssertNoThrow(try sut.submitBackgroundUpload(urlRequest, fileUrl: makeURL()))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertFalse(sessionDelegate.didFinishUploading)
        XCTAssertNotNil(sessionDelegate.receivedError)
    }

    func test_submitBackgroundUploadWithoutHttpBody_deliversError() throws {
        let sut = makeSUT()
        sut.configure(with: NetworkEngineConfiguration())

        do {
            _ = try sut.submitBackgroundUpload(URLRequest(url: makeURL()), fileUrl: makeURL())
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.noData)
        }
    }

    func test_submitBackgroundUploadWithoutConfiguration_deliversError() throws {
        do {
            _ = try makeSUT().submitBackgroundUpload(URLRequest(url: makeURL()), fileUrl: makeURL())
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.notConfigured)
        }
    }
}

private final class SessionDelegate: NSObject {
    var expectation: XCTestExpectation?
    var totalBytesWritten: Int64?
    var didFinishDownloadingTo: URL?
    var receivedError: Error?
    var didFinishUploading = false

    func fulfill() {
        expectation?.fulfill()
        expectation = nil
    }
}

extension SessionDelegate: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        receivedError = error
        fulfill()
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        print("📺 Sent: \(totalBytesSent)")
    }
}

extension SessionDelegate: URLSessionDownloadDelegate {
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        didFinishDownloadingTo = location
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        self.totalBytesWritten = totalBytesWritten
    }
}

extension SessionDelegate: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.didFinishUploading = true // only called when there's at least one byte of response
    }
}

private extension URLProtocolStubNetworkEngineTests {
    func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line,
        protocolClasses: [AnyClass] = [URLProtocolStub.self]
    ) -> URLProtocolStubNetworkEngine {
        let sut = URLProtocolStubNetworkEngine(protocolClasses: protocolClasses)
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }

    func makeData() -> Data {
        let text = """
I'm baby man braid portland lo-fi, vaporware flexitarian before they sold out
helvetica tbh hot chicken snackwave listicle gochujang man bun meditation shaman.
Pork belly whatever meditation umami. Seitan marfa hella microdosing yes plz pop-up
messenger bag vice jean shorts poke post-ironic chia crucifix. Occupy tote bag pop-up tilde.
"""
        guard let data = text.data(using: .utf8) else {
            XCTFail("Invalid data")
            return Data()
        }

        return data
    }

    func makeHttpResponse(statusCode: Int) -> HTTPURLResponse {
        guard let response = URLProtocolStub.makeHTTPURLResponse(statusCode: statusCode) else {
            XCTFail("Failed to generate an HTTP response")
            return HTTPURLResponse()
        }
        return response
    }

    func makeURL(_ string: String = "https://www.any-url.com") -> URL {
        guard let url = URL(string: string) else {
            XCTFail("Invalid URL")
            return URL(fileURLWithPath: "")
        }

        return url
    }

    func makeError() -> NSError { NSError(domain: "", code: -1200) }
}
