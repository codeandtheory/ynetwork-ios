//
//  ParametersBuilder.swift
//  YNetwork
//
//  Created by Mark Pospesel on 10/10/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Renders the object as a dictionary
public protocol ParametersBuilder {
    /// The query parameters to use for a network request
    var parameters: Parameters { get }
}

/// Default implementation of `ParametersBuilder` for `Parameters`
extension Parameters: ParametersBuilder {
    /// The query parameters to use for a network request
    public var parameters: Parameters { self }
}
