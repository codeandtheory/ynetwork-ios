//
//  EmptyNetworkResponse.swift
//  YNetwork
//
//  Created by Mark Pospesel on 10/8/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Placeholder response for network requests that return 0 bytes of data in response.
/// That is, the request only returns an HTTP Status code (plus headers).
public struct EmptyNetworkResponse: Decodable {
    /// Initializes an empty network response
    public init() { }
}
