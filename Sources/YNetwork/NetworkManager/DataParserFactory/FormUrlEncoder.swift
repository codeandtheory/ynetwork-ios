//
//  FormUrlEncoder.swift
//  YNetwork
//
//  Created by Mark Pospesel on 10/10/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// An encoder to render a request body via Form URL encoding.
/// In this case the body needs to be a Dictionary (or renderable as a Dictionary)
public struct FormURLEncoder: DataEncoder {
    private let builder = URLBuilder()
    
    /// Initializes FormURLEncoder
    public init() { }
    
    /// Encodes a value into `Data`.
    /// - Parameters:
    ///   - value: the value to be decoded
    /// - Throws: `SerializationError.toParameters` if the value is not
    /// `Parameters` or does not conform to `ParametersBuilder`
    /// - Returns: The serialized bytes representing the value
    public func encode<T>(_ value: T) throws -> Data where T: Encodable {
        guard let paramBuilder = value as? ParametersBuilder else {
            throw SerializationError.toParameters
        }
        
        let parameters = paramBuilder.parameters
        
        // generate a Form URL encoded query string
        let queryString = builder.queryString(with: parameters, contentType: .formURLEncoded)
        
        // convert it to utf8 data
        return Data(queryString.utf8)
    }
}
