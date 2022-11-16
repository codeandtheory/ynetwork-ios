//
//  HttpMethod.swift
//  YNetwork
//
//  Created by Mark Pospesel on 9/20/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// HTTP Method to be used with a request
public enum HttpMethod: String {
    /// GET request
    case GET
    /// POST request
    case POST
    /// PUT request
    case PUT
    /// PATCH request
    case PATCH
    /// DELETE request
    case DELETE
}

// Unit test helpers

extension HttpMethod: CaseIterable { }
