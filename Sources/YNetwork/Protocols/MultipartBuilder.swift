//
//  MultipartBuilder.swift
//  YNetwork
//
//  Created by Mark Pospesel on 1/11/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// Renders a multipart body as data.
///
/// Used for setting the `httpBody: Data?` of a `MultipartRequest`.
public protocol MultipartBuilder: BodyBuilder {
    /// All the parts that compose a multipart body keyed by name
    var parts: [String: MultipartElement] { get }

    /// Unique boundary identifier
    ///
    /// Often this is a UUID
    var boundary: String { get }
}

public extension MultipartBuilder {
    /// Renders the body to be used in a network request.
    func body(encoder: DataEncoder?) throws -> Data {
        encode()
    }
}

private extension MultipartBuilder {
    func encode() -> Data {
        var body = Data()

        encodeParts(data: &body)
        encodeEnd(data: &body)

        return body
    }

    func encodeParts(data: inout Data) {
        // encode each part
        for key in parts.keys.sorted() {
            guard let part = parts[key] else { continue }

            // each part begins with a boundary
            encodeBoundary(data: &data)
            part.encode(data: &data, name: key)
        }
    }

    func encodeBoundary(data: inout Data) {
        data.appendString("--\(boundary)\r\n")
    }

    func encodeEnd(data: inout Data) {
        data.appendString("--\(boundary)--\r\n")
    }
}
