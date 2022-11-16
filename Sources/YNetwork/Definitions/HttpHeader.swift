//
//  HttpHeader.swift
//  YNetwork
//
//  Created by Mark Pospesel on 9/20/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Represents a single HTTP header
public typealias HttpHeader = (field: String, value: String)

/// Represents a dictionary of HTTP headers
public typealias HttpHeaders = [String: String]
