//
//  APICompletion.swift
//  YNetwork
//
//  Created by Sanjib Chakraborty on 23/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Represents an asynchronous completion callback for a network request.
/// The callback will supply either `.success` + the expected response object or
/// else `.failure` + an `Error`.
public typealias APICompletion<Response: Decodable> = (Result<Response, Error>) -> Void
