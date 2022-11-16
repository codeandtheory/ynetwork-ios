//
//  ImageBuilder.swift
//  YNetwork
//
//  Created by Anand Kumar on 24/12/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import UIKit

/// Information needed to send an image via multipart request
public struct ImageBuilder: UIImageMultipartFile {
    /// Image
    public let image: UIImage
    
    /// File name
    public let fileName: String
    
    /// Content Type
    ///
    /// Determines how `image` will be converted to `Data`.
    public let imageType: UIImageDataType
    
    /// additional form field parameters
    public let formFields: [String: CustomStringConvertible]
    
    /// unique boundary identifier
    public let boundary: String
    
    /// Initializes an Image Builder
    /// - Parameters:
    ///   - image : image
    ///   - fileName : file name
    ///   - imageType : Image Data Type
    ///   - formFields : additional form field parameters
    ///   - boundary : unique boundary identifier (defaults to a UUID string)
    public init(
        image: UIImage,
        fileName: String,
        imageType: UIImageDataType,
        formFields: [String: CustomStringConvertible],
        boundary: String = UUID().uuidString
    ) {
        self.image = image
        self.fileName = fileName
        self.imageType = imageType
        self.formFields = formFields
        self.boundary = boundary
    }
}

extension ImageBuilder: MultipartBuilder {
    /// All the parts that compose a multipart body keyed by name
    ///
    /// Combines UIImage file data and `formFields`
    public var parts: [String: MultipartElement] {
        // One part represents the UIImage file
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
