//
//  DataDecoder.swift
//  YNetwork
//
//  Created by Mark Pospesel on 9/20/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// A generic decoder that can decode business objects from `Data`.
/// In practice this will often be an instance of `JSONDecoder`
public protocol DataDecoder {
    /// Decodes an object of the specified type into `Data`.
    /// Throws an error if there is a problem while decoding.
    /// - Parameters:
    ///   - type: the type of object to be decoded
    ///   - data: the source data to be decoded into an object
    /// - Returns: The decoded object
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
}
