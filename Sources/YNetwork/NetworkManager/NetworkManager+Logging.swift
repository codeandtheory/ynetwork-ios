//
//  NetworkManager+Logging.swift
//  YNetwork
//
//  Created by Mark Pospesel on 8/23/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation
import os

internal extension NetworkManager {
    func log(request: URLRequest) {
        if #available(iOS 14.0, tvOS 14.0, *) {
            guard let logger = logger else {
                return
            }

            // unlike `print`, `Logger` does not support
            // custom string interpolation parameters, so
            // we wrap the request inside another object
            // to log it properly
            logger.debug("\(RequestLogger(request: request))")
        }
    }

    func log(json data: Data) {
        if #available(iOS 14.0, tvOS 14.0, *) {
            guard let logger = logger else {
                return
            }

            // unlike `print`, `Logger` does not support
            // custom string interpolation parameters, so
            // we wrap the JSON data inside another object
            // to log it properly
            logger.debug("\(JSONLogger(data: data))")
        }
    }
}

// MARK: - URL Request

struct RequestLogger {
    let request: URLRequest
}

extension RequestLogger: CustomStringConvertible {
    // Performs custom string interpolation
    // cf. StringInterpolation+URLRequest.swift
    var description: String { "\(request: request)" }
}

// MARK: - JSON Data

struct JSONLogger {
    let data: Data
}

extension JSONLogger: CustomStringConvertible {
    // Performs custom string interpolation
    // cf. StringInterpolation+JSON.swift
    var description: String { "\(json: data)" }
}
