//
//  StringInterpolation+URLRequest.swift
//  YNetwork
//
//  Created by Mark Pospesel on 1/10/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

public extension String.StringInterpolation {
    /// Pretty prints requests using string interpolation.
    ///
    /// Only intended for debugging purposes.
    ///
    /// Includes method (e.g. GET), path, headers (if any), and pretty printed JSON body (if any)
    ///
    /// Usage: `print("\(request: requestObject)")`
    /// - Parameter request: the request
    mutating func appendInterpolation(request: URLRequest) {
        var items: [String] = []

        defer {
            appendInterpolation(items.joined(separator: "\t"))
        }

        if let method = request.httpMethod {
            items.append(method)
        }

        if let path = request.url?.absoluteString {
            items.append(path)
        }

        if let headers = request.allHTTPHeaderFields,
           !headers.isEmpty {
            items.append("Headers: \(headers)")
        }

        guard let data = request.httpBody,
              !data.isEmpty else { return }

        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
              let jsonData = try? JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted, .fragmentsAllowed]
              ) else {
                  items.append("Content-Length: \(data.count) bytes")
                  return
              }

        items.append("\(String(decoding: jsonData, as: UTF8.self))")
    }
}
