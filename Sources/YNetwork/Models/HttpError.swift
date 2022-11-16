//
//  HttpError.swift
//  YNetwork
//
//  Created by Sanjib Chakraborty on 23/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// An HTTP Error, typically with a status code >= 300
public struct HttpError: Error {
    /// The HTTP status code, typically >= 300
    public let statusCode: Int
    
    /// Any headers returned with the failed response
    public let headers: [AnyHashable: Any]?

    /// Any body returned with the failed response
    public let body: HttpResponseType

    /// Initializes an HTTP Error
    /// - Parameters:
    ///   - response: HTTP URL Response (from which status code and headers will be extracted)
    ///   - data: data from the network request (if any)
    public init(response: HTTPURLResponse, data: Data?) {
        self.statusCode = response.statusCode
        self.headers = response.allHeaderFields
        self.body = data?.toHttpResponse() ?? .none
    }
}
