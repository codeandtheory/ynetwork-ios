//
//  NetworkError.swift
//  YNetwork
//
//  Created by Mark Pospesel on 9/22/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Networking or network-related errors
public enum NetworkError: Error {
    /// a relative path was specified without a corresponding base path
    case noBasePath
    /// not a valid URL
    case invalidURL
    /// if NetworkEngine is not configured
    case notConfigured
    /// if response is nil
    case invalidResponse
    /// unexpected empty response
    case noData
    /// received data did not match expected response type
    case unexpectedResponse(type: ResponseContentType)
    /// error deserializing model objects
    case deserialization(Error)
    /// error serializing model objects
    case serialization(Error)
    /// no decoder was provided
    case noDecoder
    /// no encoder was provided
    case noEncoder
    /// User is unauthenticated (or token has expired)
    case unauthenticated
    /// SSL certificate pinning failed
    case invalidSSL(Error)
    /// no internet connection
    case noInternet(Error)
}

extension NetworkError: Equatable {
    /// Test equivalency between two network errors
    /// - Returns: `true` if the two errors are equivalent, otherwise `false`.
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (let .serialization(lhError), let .serialization(rhError)):
            return lhError.localizedDescription == rhError.localizedDescription
        case (let .deserialization(lhError), let .deserialization(rhError)):
            return lhError.localizedDescription == rhError.localizedDescription
        case (let .unexpectedResponse(lhType), let .unexpectedResponse(rhType)):
            return lhType == rhType
        case (let .invalidSSL(lhError), let .invalidSSL(rhError)):
            return lhError.localizedDescription == rhError.localizedDescription
        case (let .noInternet(lhError), let .noInternet(rhError)):
            return lhError.code == rhError.code && lhError.domain == rhError.domain
        case (.noBasePath, .noBasePath),
            (.invalidURL, .invalidURL),
            (.notConfigured, .notConfigured),
            (.invalidResponse, .invalidResponse),
            (.noData, .noData),
            (.noDecoder, .noDecoder),
            (.noEncoder, .noEncoder),
            (.unauthenticated, .unauthenticated):
            return true
        default:
            return false
        }
    }
}
