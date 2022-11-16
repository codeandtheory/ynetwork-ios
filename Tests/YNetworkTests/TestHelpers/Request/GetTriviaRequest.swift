//
//  GetTriviaRequest.swift
//  YNetworkTests
//
//  Created by Sumit Goswami on 01/04/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

@testable import YNetwork
import Foundation

struct GetTriviaRequest {
    let amount: Int
    let category: Int
    let difficulty: String
    let type: String

    var queryParameters: ParametersBuilder? {
        [
            "amount": amount,
            "category": category,
            "difficulty": difficulty,
            "type": type
        ]
    }
}

extension GetTriviaRequest: NetworkRequest {
    var path: PathRepresentable { UnitTestPath.openTriviaDb }
}

// Top-level response object
struct TriviaResponse: Decodable {
    let responseCode: Int
    let results: [TriviaQuestion]
}

extension TriviaResponse {
    static func makeJSON() -> [String: Any] {
        [
            "responseCode": 0,
            "results": [
                [
                    "category": "General Knowledge",
                    "type": "multiple",
                    "difficulty": "medium",
                    "question": "Which river flows through the Scottish city of Glasgow?",
                    "correct_answer": "Clyde",
                    "incorrect_answers": ["Tay", "Dee", "Tweed"]
                ], [
                    "category": "General Knowledge",
                    "type": "multiple",
                    "difficulty": "medium",
                    "question": "What is the unit of currency in Laos?",
                    "correct_answer": "Kip",
                    "incorrect_answers": ["Ruble", "Konra", "Dollar"]
                ]
            ]
        ]
    }
}

// This does not at all match our expected response object
struct NotTriviaResponse: Decodable {
    let name: String
    let count: Int
    let price: Double
    let currency: String
}

struct TriviaQuestion: Decodable {
    let category: String
    let correctAnswer: String
    let difficulty: String
    let incorrectAnswers: [String]
    let question: String
    let type: String
}

struct TriviaApi {
    static func makeTriviaFactory() -> JSONDataParserFactory {
        let jsonDecoder = JSONDecoder()
        // Open Trivia api uses snake_case
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return JSONDataParserFactory(decoder: jsonDecoder, encoder: JSONEncoder.defaultEncoder)
    }

    static func makeTriviaRequest(_ count: Int = 2) -> NetworkRequest {
        GetTriviaRequest(amount: count, category: 9, difficulty: "medium", type: "multiple")
    }
}
