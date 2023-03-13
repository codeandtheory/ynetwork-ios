//
//  NetworkManagerDownloadTests.swift
//  YNetworkTests
//
//  Created by Sumit Goswami on 04/04/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class NetworkManagerDownloadTests: XCTestCase {
    // Expect it to be much less, but let's allow a generous timeout because CI
    // server may be slow at times
    private let timeout: TimeInterval = 5

    private var sut: NetworkManagerSpy!
    private var configuration: NetworkManagerConfiguration!
    private var request: NetworkRequest!

    override func setUp() {
        super.setUp()

        configuration = NetworkManagerConfiguration(networkEngine: URLProtocolStubNetworkEngine())
        sut = NetworkManagerSpy()
        sut.configure(with: configuration)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        configuration = nil
        URLProtocolStub.reset()
    }

    func testDownloadCompletionOnly() {
        let expectation = expectation(description: "testDownloadSuccess")

        URLProtocolStub.appendStub(withData: makeData(), statusCode: 200, type: .download)

        var downloadUrl: URL!

        let task = sut.submitBackgroundDownload(
            ImageDownloadRequest(),
            progress: nil
        ) { result in
            switch result {
            case .success(let url):
                XCTAssertFalse(Thread.isMainThread, "Expected callback on background thread")
                XCTAssert(FileManager.default.fileExists(atPath: url.path))
                downloadUrl = url

            case .failure:
                XCTFail("Invalid response")
            }

            expectation.fulfill()
        }

        XCTAssertNotNil(task, "Expected submit to return a task")

        wait(for: [expectation], timeout: timeout)

        // we received a download location
        XCTAssertNotNil(downloadUrl, "Expected to have received a download location.")
    }

    func testDownloadProgressAndCompletion() {
        let expectation = expectation(description: "testDownloadSuccess")

        URLProtocolStub.appendStub(withData: makeData(), statusCode: 200, type: .download)

        var progressCount: Int = 0
        var lastProgress: Percentage = -1
        var downloadUrl: URL!

        let task = sut.submitBackgroundDownload(
            ImageDownloadRequest()
        ) { percent in
            progressCount += 1
            lastProgress = percent
            XCTAssert(Thread.isMainThread, "Expected callback on main thread")
        } completionHandler: { result in
            switch result {
            case .success(let url):
                XCTAssertFalse(Thread.isMainThread, "Expected callback on background thread")
                XCTAssert(FileManager.default.fileExists(atPath: url.path))
                downloadUrl = url

            case .failure:
                XCTFail("Invalid response")
            }

            DispatchQueue.main.async {
                // ensures expectation fulfills after any pending progress updates
                expectation.fulfill()
            }
        }

        XCTAssertNotNil(task, "Expected submit to return a task")

        wait(for: [expectation], timeout: timeout)

        XCTAssertGreaterThan(progressCount, 0, "Expected to have progress callback")
        XCTAssertEqual(lastProgress, 1, "Expected progress to be 100%.")
        // we received a download location
        XCTAssertNotNil(downloadUrl, "Expected to have received a download location.")
    }

    func testSubmitSuccessCallback() throws {
        let expectation = expectation(description: "Wait for download success.")
        sut.expectation = expectation

        URLProtocolStub.appendStub(withData: makeData(), statusCode: 200, type: .download)

        XCTAssertNil(sut.totalBytesWritten)
        XCTAssertNil(sut.didFinishDownloadingTo)

        XCTAssertNotNil(sut.submitBackgroundDownload(ImageDownloadRequest()) { _ in })

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(sut.totalBytesWritten)
        XCTAssertNotNil(sut.didFinishDownloadingTo)
    }

    func test_submitCancel_deliversError() throws {
        let expectation = expectation(description: "Wait for download failure.")
        sut.expectation = expectation

        let engine = try XCTUnwrap(sut.configuration?.networkEngine as? URLProtocolStubNetworkEngine)
        engine.autoResumesBackgroundTasks = false
        defer {
            engine.autoResumesBackgroundTasks = true
        }

        URLProtocolStub.appendStub(withData: makeData(), statusCode: 200, type: .download)

        XCTAssertNil(sut.receivedError)

        let task = try XCTUnwrap(sut.submitBackgroundDownload(ImageDownloadRequest()) { _ in } as? URLSessionTask)
        task.cancel() // this will make it fail
        task.resume() // resume it

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(sut.receivedError)
    }

    func test_submitError_deliversError() throws {
        let expectation = expectation(description: "Wait for download failure.")
        sut.expectation = expectation

        URLProtocolStub.appendStub(.failure(NetworkError.invalidResponse), type: .download)

        XCTAssertNil(sut.receivedError)

        XCTAssertNotNil(sut.submitBackgroundDownload(ImageDownloadRequest()) { _ in })

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(sut.receivedError)
    }

    func test_submit401_deliversError() throws {
        let expectation = expectation(description: "Wait for download failure.")

        URLProtocolStub.appendStub(.success((Data(), makeHttpResponse(statusCode: 401))), type: .download)

        XCTAssertNil(sut.receivedError)

        var caught: Error?
        let task = sut.submitBackgroundDownload(
            ImageDownloadRequest(),
            progress: nil
        ) { result in
            switch result {
            case .success:
                XCTFail("Invalid response")
            case .failure(let error):
                caught = error
            }

            expectation.fulfill()
        }

        XCTAssertNotNil(task, "Expected submit to return a task")

        wait(for: [expectation], timeout: timeout)

        XCTAssertEqual(caught as? NetworkError, NetworkError.unauthenticated)
    }

    func test_submit500_deliversError() throws {
        let expectation = expectation(description: "Wait for download failure.")

        let statusCode = Int.random(in: 500...599)
        URLProtocolStub.appendStub(.success((Data(), makeHttpResponse(statusCode: statusCode))), type: .download)

        XCTAssertNil(sut.receivedError)

        var caught: Error?
        let task = sut.submitBackgroundDownload(
            ImageDownloadRequest(),
            progress: nil
        ) { result in
            switch result {
            case .success:
                XCTFail("Invalid response")
            case .failure(let error):
                caught = error
            }

            expectation.fulfill()
        }

        XCTAssertNotNil(task, "Expected submit to return a task")

        wait(for: [expectation], timeout: timeout)

        XCTAssertEqual((caught as? HttpError)?.statusCode, statusCode)
    }

    func testSubmitWithoutConfiguration() {
        let sut = NetworkManager()

        // Given we submit a request without first configuring the network manager
        let task = sut.submitBackgroundDownload(ImageDownloadRequest()) { _ in }

        // We don't expect a task to be returned
        XCTAssertNil(task)
    }
}

private extension NetworkManagerDownloadTests {
    func makeData() -> Data {
        let text = """
I'm baby truffaut viral celiac listicle trust fund schlitz glossier affogato
four loko 90's wolf chartreuse gatekeep. Shoreditch fit prism portland, 90's
tonx squid viral gatekeep fanny pack raclette adaptogen retro. Williamsburg
brunch asymmetrical tbh 3 wolf moon. Photo booth live-edge hashtag palo santo,
cronut put a bird on it street art cloud bread artisan.
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
}

private final class NetworkManagerSpy: NetworkManager {
    var expectation: XCTestExpectation?
    private(set) var totalBytesWritten: Int64?
    private(set) var didFinishDownloadingTo: URL?
    private(set) var receivedError: Error?

    override func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        super.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)

        didFinishDownloadingTo = location
    }

    override func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        super.urlSession(session, task: task, didCompleteWithError: error)

        receivedError = error
        DispatchQueue.main.async {
            // ensures expectation fulfills after any pending progress updates
            self.fulfill()
        }
    }

    override func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        super.urlSession(
            session,
            downloadTask: downloadTask,
            didWriteData: bytesWritten,
            totalBytesWritten: totalBytesWritten,
            totalBytesExpectedToWrite: totalBytesExpectedToWrite
        )

        self.totalBytesWritten = totalBytesWritten
    }

    func fulfill() {
        expectation?.fulfill()
        expectation = nil
    }
}
