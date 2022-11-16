//
//  BodyBuilder.swift
//  YNetwork
//
//  Created by Mark Pospesel on 10/10/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Renders the object as data.
/// Used for setting the `httpBody: Data?` of a `NetworkRequest`.
public protocol BodyBuilder {
    /// Renders the body to be used in a network request.
    /// Throws an error if the object cannot be encoded.
    /// - Parameter encoder: the encoder to be used to encode the body
    /// - Returns: the serialized bytes to use in the request body
    func body(encoder: DataEncoder?) throws -> Data
}

/// Default implementation of `BodyBuilder` for `Data`
extension Data: BodyBuilder {
    /// Renders the body to be used in a network request.
    /// Throws an error if the object cannot be encoded.
    /// - Parameter encoder: the encoder to be used to encode the body
    /// - Returns: the serialized bytes to use in the request body.
    /// If no encoder is specified, it just returns `self`.
    public func body(encoder: DataEncoder?) throws -> Data {
        // Data doesn't need an encoder (although it can support one)
        guard let encoder = encoder else { return self }
        
        return try encoder.encode(self)
    }
}

/// Default implementation of `BodyBuilder` for `Encodable`
extension Encodable {
    /// Renders the body to be used in a network request.
    /// Throws an error if no encoder is provided or the object cannot be encoded.
    /// - Parameter encoder: the encoder to be used to encode the body
    /// - Returns: the serialized bytes to use in the request body.
    public func body(encoder: DataEncoder?) throws -> Data {
        guard let encoder = encoder else { throw NetworkError.noEncoder }
        
        return try encoder.encode(self)
    }
}
