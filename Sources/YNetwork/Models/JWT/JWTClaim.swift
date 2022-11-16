//
//  JWTClaim.swift
//  YNetwork
//
//  Created by Sanjib Chakraborty on 28/01/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// JWT Claim
struct JWTClaim {
    /// raw value of the claim
    let value: Any?
    
    init(value: Any?) {
        self.value = value
    }

    /// value of the claim as String
    var string: String? { value as? String }

    /// value of the claim as Double
    var double: Double? {
        let double: Double?
        if let string = string {
            double = Double(string)
        } else {
            double = value as? Double
        }
        return double
    }

    /// value of the claim as Int
    var integer: Int? {
        let integer: Int?
        if let string = string {
            integer = Int(string)
        } else if let double = value as? Double {
            integer = Int(double)
        } else {
            integer = value as? Int
        }
        return integer
    }

    /// value of the claim as date
    var date: Date? {
        guard let timestamp: TimeInterval = double else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }

    /// value of the claim as an array of Strings
    var array: [String]? {
        if let array = value as? [String] {
            return array
        }
        if let value = string {
            return [value]
        }
        return nil
    }
}
