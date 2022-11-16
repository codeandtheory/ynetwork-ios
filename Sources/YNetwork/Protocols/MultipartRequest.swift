//
//  MultipartRequest.swift
//  YNetwork
//
//  Created by Mark Pospesel on 1/7/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// All the information needed to make a multipart network request.
///
/// Has some different default values relative to `NetworkRequest`.
public protocol MultipartRequest: NetworkRequest {
    /// Multipart builder
    var multipart: MultipartBuilder { get }
}

/// Default implementation for Multipart Request properties.
public extension MultipartRequest {
    var method: HttpMethod { .POST }
    var requestType: RequestContentType {
        .multipart(boundary: multipart.boundary)
    }
    var body: BodyBuilder? { multipart }
}
