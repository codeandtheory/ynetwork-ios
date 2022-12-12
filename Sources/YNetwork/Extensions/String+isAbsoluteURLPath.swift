//
//  String+isAbsoluteURLPath.swift
//  YNetwork
//
//  Created by Mark Pospesel on 9/22/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Match strings beginning with `http://`, `https://`, `ftp://`, and `ftps://`
let kUrlSchemaRegex = "^(ht|f)tp(s?)\\:\\/\\/"

/// Add helper to check if a string represents an absolute URL path
extension String {
    /// Determines whether the string begins with `http://`, `https://`, `ftp://`, or `ftps://`
    public var isAbsoluteURLPath: Bool {
        matches(regex: kUrlSchemaRegex)
    }
}
