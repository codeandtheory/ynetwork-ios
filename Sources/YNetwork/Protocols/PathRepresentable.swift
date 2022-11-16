//
//  PathRepresentable.swift
//  YNetwork
//
//  Created by Anand Kumar on 17/11/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Represents a url path (which may be relative or absolute)
public protocol PathRepresentable {
    /// URL path string
    var pathValue: String {get}
}

/// String conforms to PathRepresentable by simply returning itself
extension String: PathRepresentable {
    /// URL path string
    public var pathValue: String { self }
}

/// RawRepresentable (e.g. all string-based enums) conforms to PathRepresentable by simply returning its raw value
extension RawRepresentable where RawValue == String {
    /// URL path string
    public var pathValue: String { rawValue }
}
