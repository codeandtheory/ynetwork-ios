//
//  JSONDecoder+Extension.swift
//  YNetwork
//
//  Created by Sumit Goswami on 22/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Declare `JSONDecoder`'s conformance to the `DataDecoder` protocol
extension JSONDecoder: DataDecoder {
    /// The default JSON decoder
    static public var defaultDecoder = JSONDecoder()
}
