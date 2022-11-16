//
//  CheckContrastRequest.swift
//  YNetworkTests
//
//  Created by Sumit Goswami on 01/04/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

@testable import YNetwork

struct CheckContrastRequest {
    var method: HttpMethod = .GET
    var requestType: RequestContentType = .JSON
    var responseType: ResponseContentType = .JSON
    var queryParameters: ParametersBuilder?
    var body: BodyBuilder?
}

extension CheckContrastRequest: NetworkRequest {
    var basePath: PathRepresentable? { UnitTestPath.webaim }
    var path: PathRepresentable { "contrastchecker" }
}

struct CheckContrastPayload {
    let foregroundColor: String
    let backgroundColor: String
}

extension CheckContrastPayload: ParametersBuilder {
    var parameters: Parameters {
        [
            "api": true,
            "fcolor": foregroundColor,
            "bcolor": backgroundColor
        ]
    }
}

// {"ratio":"3.58","AA":"fail","AALarge":"pass","AAA":"fail","AAALarge":"fail"}

enum ContrastTestResult: String, Codable {
    case pass
    case fail
}

struct CheckContrastResponse: Codable, Equatable {
    let ratio: String
    let AA: ContrastTestResult
    let AALarge: ContrastTestResult
    let AAA: ContrastTestResult
    let AAALarge: ContrastTestResult
}

extension CheckContrastResponse {
    static let mock = CheckContrastResponse(ratio: "3.58", AA: .fail, AALarge: .pass, AAA: .fail, AAALarge: .fail)

    static func makeJSON() -> [String: Any] {
        [
            "ratio": "21",
            "AA": "pass",
            "AALarge": "pass",
            "AAA": "pass",
            "AAALarge": "pass"
        ]
    }
}
