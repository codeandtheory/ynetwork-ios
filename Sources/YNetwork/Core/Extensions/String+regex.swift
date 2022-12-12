//
//  String+regex.swift
//  YNetwork
//
//  Created by Mark Pospesel on 9/22/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Add simpler regular exression matching
extension String {
    /// Whether the string matches the specified regex pattern or not.
    /// - Parameter pattern: the regular expression pattern to evaluate
    /// - Returns: `true` if the string matches the pattern, otherwise `false`.
    public func matches(regex pattern: String) -> Bool {
        range(
            of: pattern,
            options: .regularExpression,
            range: nil,
            locale: .current
        ) != nil
    }
}
