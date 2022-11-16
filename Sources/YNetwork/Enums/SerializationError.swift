//
//  SerializationError.swift
//  YNetwork
//
//  Created by Mark Pospesel on 10/15/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Serialization errors.
/// Commonly used as the internal error within `NetworkError.serialization`
enum SerializationError: Error {
    /// Error converting the object to `Parameters`.
    /// This error is thrown by `FormURLEncoder.encode(:)`
    case toParameters
    
    /// Error converting the object to `Data`.
    /// This error might be thrown by implementations of `BodyBuilder.body(encoder:)`
    case toBody
}
