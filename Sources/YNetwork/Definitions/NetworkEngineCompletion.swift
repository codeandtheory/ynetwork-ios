//
//  NetworkEngineCompletion.swift
//  YNetwork
//
//  Created by Mark Pospesel on 10/15/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Represents an asynchronous completion callback for a raw network request.
/// The callback will supply either the data and the URL response or else an error.
public typealias NetworkEngineCompletion = (Data?, URLResponse?, Error?) -> Void
