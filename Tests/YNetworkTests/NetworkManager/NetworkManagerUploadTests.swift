//
//  NetworkManagerUploadTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 11/7/22.
//

import XCTest
@testable import YNetwork

final class NetworkManagerUploadTests: XCTestCase {
    // Expect it to be much less, but let's allow a generous timeout because CI
    // server may be slow at times
    private let timeout: TimeInterval = 5

    private var data: Data!
    private var request: NetworkRequest!
    private var sut: NetworkManagerSpy!

    override func setUp() {
        super.setUp()

        let configuration = NetworkManagerConfiguration(networkEngine: URLProtocolStubNetworkEngine())
        data = "Hello, World!".data(using: .utf8)
        request = createRequest()
        sut = NetworkManagerSpy()
        sut.configure(with: configuration)
    }

    override func tearDown() {
        super.tearDown()
        data = nil
        request = nil
        sut = nil
        URLProtocolStub.reset()
    }

    func testSubmitSuccessCallback() throws {
        let expectation = expectation(description: "Wait for upload success.")
        sut.expectation = expectation

        var percentage = 0.0

        URLProtocolStub.appendStub(withData: data, statusCode: 200, type: .upload)

        XCTAssertNil(sut.totalBytesSent)
        XCTAssertNil(sut.receivedData)

        let task = sut.submitBackgroundUpload(request) { percent in
            percentage = percent
            XCTAssert(Thread.isMainThread)
        }

        XCTAssertNotNil(task)

        wait(for: [expectation], timeout: timeout)

        XCTAssertEqual(percentage, 1, "Expected to have progress callback")
        XCTAssertNotNil(sut.totalBytesSent)
        XCTAssertNotNil(sut.receivedData)
    }

    func test_submitCancel_deliversError() throws {
        let expectation = expectation(description: "Wait for upload failure.")
        sut.expectation = expectation

        URLProtocolStub.appendStub(withData: data, statusCode: 200, type: .upload)

        XCTAssertNil(sut.receivedError)

        let task = try XCTUnwrap(sut.submitBackgroundUpload(request) { _ in })
        task.cancel() // this will make it fail

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(sut.receivedError)
    }

    func test_submitError_deliversError() throws {
        let expectation = expectation(description: "Wait for upload failure")
        sut.expectation = expectation

        XCTAssertNil(sut.receivedError)

        URLProtocolStub.appendStub(.failure(NetworkError.invalidResponse), type: .upload)
        let task = sut.submitBackgroundUpload(request) { _ in }

        XCTAssertNotNil(task)

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(sut.receivedError)
    }

    func test_submit401_deliversError() throws {
        let expectation = expectation(description: "Wait for upload success.")
        sut.expectation = expectation

        var percentage = 0.0

        URLProtocolStub.appendStub(withData: data, statusCode: 401, type: .upload)

        XCTAssertNil(sut.totalBytesSent)
        XCTAssertNil(sut.receivedData)

        let task = sut.submitBackgroundUpload(request) { percent in
            percentage = percent
            XCTAssert(Thread.isMainThread)
        }

        XCTAssertNotNil(task)

        wait(for: [expectation], timeout: timeout)

        XCTAssertEqual(percentage, 0, "No progress expected")
        XCTAssertNil(sut.totalBytesSent)
        XCTAssertNotNil(sut.receivedData)
    }

    func test_submit500_deliversError() throws {
        let expectation = expectation(description: "Wait for upload success.")
        sut.expectation = expectation

        var percentage = 0.0

        let statusCode = Int.random(in: 500...599)
        URLProtocolStub.appendStub(withData: data, statusCode: statusCode, type: .upload)

        XCTAssertNil(sut.totalBytesSent)
        XCTAssertNil(sut.receivedData)

        let task = sut.submitBackgroundUpload(request) { percent in
            percentage = percent
            XCTAssert(Thread.isMainThread)
        }

        XCTAssertNotNil(task)

        wait(for: [expectation], timeout: timeout)

        XCTAssertEqual(percentage, 0, "No progress expected")
        XCTAssertNil(sut.totalBytesSent)
        XCTAssertNotNil(sut.receivedData)
    }

    func testSubmitWithoutConfiguration() {
        let sut = NetworkManager()

        // Given we submit a request without first configuring the network manager
        let task = sut.submitBackgroundUpload(request) { _ in }

        // We don't expect a task to be returned
        XCTAssertNil(task)
    }
}

private extension NetworkManagerUploadTests {
    func createRequest() -> NetworkRequest! {
        MockMultipartRequest()
    }
}

private final class NetworkManagerSpy: NetworkManager {
    var expectation: XCTestExpectation?
    private(set) var totalBytesSent: Int?
    private(set) var receivedError: Error?
    private(set) var receivedData: Data?

    override func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        var error = error
        if error == nil {
            if let httpResponse = task.response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200..<300:
                    if task.state == .canceling {
                        error = NetworkSpyError.cancelled
                    }
                case 401:
                    error = NetworkError.unauthenticated
                default:
                    error = HttpError(response: httpResponse, data: receivedData ?? Data())
                }
            } else {
                error = NetworkError.invalidResponse
            }
        }

        // The best we can do mocking upload progress is to post a 100% completion here
        if error == nil {
            totalBytesSent = task.originalRequest?.httpBody?.count
            fileUpload.signal(percent: 1, forKey: task.taskIdentifier)
        }

        super.urlSession(session, task: task, didCompleteWithError: error)
        self.receivedError = error
        DispatchQueue.main.async {
            // ensures expectation fulfills after any pending progress updates
            self.fulfill()
        }
    }

    func fulfill() {
        expectation?.fulfill()
        expectation = nil
    }
}

extension NetworkManagerSpy: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.receivedData = data
    }
}

public enum NetworkSpyError: Error {
    case cancelled
}
