//
//  MultiImageBuilder.swift
//  YNetwork
//
//  Created by Mark Pospesel on 1/13/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// Information needed to send multiple images via a single multipart request
public struct MultiImageBuilder {
    /// Images to send
    public let images: [String: UIImageMultipartFile]

    /// additional form field parameters
    public let formFields: [String: CustomStringConvertible]

    /// unique boundary identifier
    public let boundary: String
    
    /// Initializes a Multi-Image Builder
    /// - Parameters:
    ///   - images : images to send
    ///   - formFields : additional form field parameters
    ///   - boundary : unique boundary identifier (defaults to a UUID string)
    public init(
        images: [String: UIImageMultipartFile],
        formFields: [String: CustomStringConvertible],
        boundary: String = UUID().uuidString
    ) {
        self.images = images
        self.formFields = formFields
        self.boundary = boundary
    }
}

extension MultiImageBuilder: MultipartBuilder {
    /// All the parts that compose a multipart body keyed by name.
    ///
    /// Combines `images` and `formFields`
    public var parts: [String: MultipartElement] {
        var parts: [String: MultipartElement] = [:]

        // Append a file part for each image
        for (key, value) in images {
            parts[key] = .file(info: value)
        }

        // Append additional form field parts (if any)
        for (key, value) in formFields {
            parts[key] = .formField(value: value)
        }

        return parts
    }
}
