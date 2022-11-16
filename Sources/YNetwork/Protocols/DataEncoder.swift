//
//  DataEncoder.swift
//  YNetwork
//
//  Created by Mark Pospesel on 9/16/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// A generic encoder that can encode business objects into `Data`.
/// In practice this will often be an instance of `JSONEncoder`
public protocol DataEncoder {
    /// Encodes a value into `Data`.
    /// Throws an error if there is a problem while encoding.
    /// - Parameters:
    ///   - value: the value to be decoded
    /// - Returns: The serialized bytes representing the value
    func encode<T>(_ value: T) throws -> Data where T: Encodable
}
