//
//  ResponseContentType.swift
//  YNetwork
//
//  Created by Sumit Goswami on 23/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// ResponseContentType type of network  response
///
/// New types should be added as needed
public enum ResponseContentType {
    /// Empty response (0 bytes expected)
    case none
    /// JSON
    case JSON
    /// binary
    case binary
}

/// Generate Accept header
public extension ResponseContentType {
    /// Accept header field
    static let field = "Accept"

    /// Accept header value
    var value: String? {
        switch self {
        case .JSON: return "application/json"
        case .none, .binary: return nil
        }
    }

    /// Accept header for this content type
    var header: HttpHeader? {
        guard let value = value else { return nil }
        return (ResponseContentType.field, value)
    }
}

// Unit test helpers
extension ResponseContentType: CaseIterable { }
