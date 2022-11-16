//
//  GifBuilder.swift
//  YNetwork
//
//  Created by Mark Pospesel on 1/11/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// Information needed to send a gif via multipart request
public struct GifBuilder {
    /// GIF name
    ///
    /// Should match the resource name in your bundle
    public let fileName: String

    /// additional form field parameters
    public let formFields: [String: CustomStringConvertible]

    /// unique boundary identifier
    public let boundary: String

    /// bundle containing the resource
    public let bundle: Bundle

    /// Initializes a GIF Builder
    /// - Parameters:
    ///   - fileName : GIF name (should match the resource name in your main bundle)
    ///   - formFields : additional form field parameters
    ///   - boundary : unique boundary identifier (defaults to a UUID string)
    ///   - bundle: bundle containing the GIF (defaults to `.main`)
    public init(
        fileName: String,
        formFields: [String: CustomStringConvertible],
        boundary: String = UUID().uuidString,
        bundle: Bundle = .main
    ) {
        self.fileName = fileName
        self.formFields = formFields
        self.boundary = boundary
        self.bundle = bundle
    }
}

extension GifBuilder: MultipartBuilder {
    /// All the parts that compose a multipart body keyed by name
    ///
    /// Combines gif file data and `formFields`
    public var parts: [String: MultipartElement] {
        // One part represents the gif file
        var parts: [String: MultipartElement] = [
            "file": .file(info: self)
            ]

        // Append additional form field parts (if any)
        for (key, value) in formFields {
            parts[key] = .formField(value: value)
        }

        return parts
    }
}

extension GifBuilder: MultipartFile {
    /// MIME content type
    public var mimeType: String { ImageContentType.gif.value }

    /// File data
    public var data: Data? {
        guard let filePath = bundle.path(forResource: fileName, ofType: "gif") else { return nil }
        return try? Data(contentsOf: URL(fileURLWithPath: filePath))
    }
}
