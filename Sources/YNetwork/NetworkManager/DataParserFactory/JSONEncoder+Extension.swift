//
//  JSONEncoder+Extension.swift
//  YNetwork
//
//  Created by Sumit Goswami on 22/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Declare `JSONEncoder`'s conformance to the `DataEncoder` protocol
extension JSONEncoder: DataEncoder {
    /// The default JSON encoder (outputs in pretty printed format)
    static public var defaultEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }
}
