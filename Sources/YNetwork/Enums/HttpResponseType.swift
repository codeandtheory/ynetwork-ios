//
//  HttpResponseType.swift
//  YNetwork
//
//  Created by Mark Pospesel on 1/6/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// Convenience enum for packaging HTTP responses
///
/// Used to return additional response data for non-successful (non-200) HTTP responses.
public enum HttpResponseType {
    /// Empty response (0 bytes)
    case none
    /// JSON response deserialized to a top-level dictionary
    case jsonDictionary([String: Any])
    /// JSON response deserialzied to a top-level array
    case jsonArray([Any])
    /// non-JSON response returned as raw bytes
    case raw(Data)
}
