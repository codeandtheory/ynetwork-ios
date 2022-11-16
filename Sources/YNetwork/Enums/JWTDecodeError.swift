//
//  JWTDecodeError.swift
//  YNetwork
//
//  Created by Sanjib Chakraborty on 31/01/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// JWT decode error codes
public enum JWTDecodeError: Error, Equatable {
    /// Malformed JWT token, failed to parse JSON value from base64Url
    case invalidJSON(String)
    
    /// Malformed JWT token has invalid number of parts when it should have 3 parts
    case invalidPartCount(String, Int)
    
    /// Malformed JWT token, failed to decode base64 value
    case invalidBase64(String)
}
