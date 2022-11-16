//
//  Error+Code.swift
//  YNetwork
//
//  Created by Anand Kumar on 29/11/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

public extension Error {
    /// Returns the error code
    var code: Int { (self as NSError).code }

    /// Returns the domain name
    var domain: String { (self as NSError).domain }

    /// Returns the user information
    var userInfo: [String: Any] { (self as NSError).userInfo}
}
