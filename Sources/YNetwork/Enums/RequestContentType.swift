//
//  RequestContentType.swift
//  YNetwork
//
//  Created by Mark Pospesel on 9/20/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Content type of network request
///
/// New types should be added as needed
public enum RequestContentType: Equatable {
    /// Empty request (0 bytes)
    case none
    /// JSON
    case JSON
    /// binary
    case binary
    /// form URL encoded
    case formURLEncoded
    /// multi part form data
    case multipart(boundary: String)
}

/// Generate Content-Type header
public extension RequestContentType {
    /// Content-Type header field
    static let field = "Content-Type"

    /// Content-Type header value
    var value: String? {
        switch self {
        case .JSON: return "application/json"
        case .formURLEncoded: return "application/x-www-form-urlencoded; charset=utf-8"
        case .multipart(let boundary): return "multipart/form-data; boundary=\(boundary)"
        case .none, .binary: return nil
        }
    }
    
    /// Content-Type header for this content type
    var header: HttpHeader? {
        guard let value = value else { return nil }
        return (RequestContentType.field, value)
    }
}
