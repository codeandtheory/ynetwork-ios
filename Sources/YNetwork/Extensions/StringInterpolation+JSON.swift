//
//  StringInterpolation+JSON.swift
//  YNetwork
//
//  Created by Mark Pospesel on 1/10/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

public extension String.StringInterpolation {
    /// Pretty print JSON data using string interpolation.
    ///
    /// Only intended for debugging purposes.
    ///
    /// Usage: `print("\(json: myData)")`
    /// - Parameter json: JSON data
    mutating func appendInterpolation(json: Data) {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: json, options: .allowFragments),
              let jsonData = try? JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted, .fragmentsAllowed]
              ) else {
                  appendInterpolation("Invalid JSON data")
                  return
              }

        appendInterpolation("\(String(decoding: jsonData, as: UTF8.self))")
    }
}
