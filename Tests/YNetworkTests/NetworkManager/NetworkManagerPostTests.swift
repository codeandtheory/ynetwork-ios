//
//  NetworkManagerPostTests.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 10/15/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YNetwork

final class NetworkManagerPostTests: XCTestCase {
    // Free account created using mark.pospesel@ymedialabs.com
    // The free plan has a limit of 5 requests / second,
    // but only 500 characters / month 😭
    // So we'll use a MockEngine
    private let basePath = "https://google-translate1.p.rapidapi.com"
    private let apiKey = "8e9848efc9mshe6a577ec11b09e0p1b3410jsn78b1f236eeb4"
    
    private var sut: NetworkManager!

    override func setUp() {
        let configuration = NetworkManagerConfiguration(
            headers: [
                "x-rapidapi-host": "google-translate1.p.rapidapi.com",
                "x-rapidapi-key": apiKey
            ],
            networkEngine: ParrotNetworkEngine()
        )
        sut = NetworkManager()
        sut.configure(with: configuration)
    }

    override func tearDown() {
        sut = nil
    }

    func testPost() {
        let body =  DetectLanguageBody(q: "English is hard, but detectably so")
        
        let request = DetectLanguageRequest(body: body)
        
        var retValue: Data?
        let expectation = self.expectation(description: "POST Request")
        
        sut.submit(request) { (response: Result<Data, Error>) in
            XCTAssertTrue(Thread.isMainThread)
            switch response {
            case .success(let data):
                retValue = data
            case .failure(let error):
                XCTFail("failure with error \(error)")
            }
            expectation.fulfill()
        }

        // Give the network call 10 seconds to complete
        wait(for: [expectation], timeout: 10)
        
        // We expect to get back a response
        XCTAssertNotNil(retValue)
        
        // We expect it to have parroted back the formURLEncoded body
        let string = String(data: retValue ?? Data(), encoding: .utf8)
        
        // The string it produces should be form URL encoded
        // (url query format but with " " replaced by "+")
        XCTAssertEqual(string, "q=English+is+hard,+but+detectably+so")
    }
}

struct DetectLanguageRequest: NetworkRequest {
    var basePath: PathRepresentable? { UnitTestPath.google }
    var path: PathRepresentable { "language/translate/v2/detect" }
    var method: HttpMethod { .POST }
    var headers: HttpHeaders? { ["system": "iOS", "language": "en_US"] }
    var requestType: RequestContentType { .formURLEncoded }
    var responseType: ResponseContentType { .binary }

    var body: BodyBuilder?
}

struct DetectLanguageBody: Encodable, BodyBuilder {
    let q: String
}

extension DetectLanguageBody: ParametersBuilder {
    // Because this api is form-URL encoded, we need to render body as a dictionary
    var parameters: Parameters { ["q": q] }
}

struct DetectLanguageResponse: Decodable {
    let data: DetectLanguageData
    
    struct DetectLanguageData: Decodable {
        let detections: [[Detection]]
    }
    
    struct Detection: Decodable {
        let language: String
        let isReliable: Bool
        let confidence: Double
    }
}

final class ParrotNetworkEngine: URLNetworkEngine {
    override func submit(_ request: URLRequest) async throws -> (Data, URLResponse) {
        guard let url = request.url else { throw NetworkError.invalidURL }

        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "1.0",
            headerFields: request.allHTTPHeaderFields
        )

        guard let data = request.httpBody,
              let httpResponse = httpResponse else {
            throw NetworkError.noData
        }

        return (data, httpResponse as URLResponse)
    }
}
