//
//  MultipartFile.swift
//  YNetwork
//
//  Created by Mark Pospesel on 1/13/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// Information to describe a file as a single part of a multipart message
public protocol MultipartFile {
    /// File name
    var fileName: String { get }

    /// File data
    var data: Data? { get }

    /// MIME content type
    var mimeType: String { get }
}

/// Information to describe a file as a single part of a multipart message
///
/// Basic struct that conforms to `MultipartFile`
public struct MultipartFileInfo: MultipartFile {
    /// File name
    public let fileName: String

    /// File data
    public let data: Data?

    /// MIME content type
    public let mimeType: String
    
    /// Initializes a multipart file info
    ///   - fileName: file name
    ///   - data: file data
    ///   - mimeType: MIME content type
    public init(fileName: String, data: Data?, mimeType: String) {
        self.fileName = fileName
        self.data = data
        self.mimeType = mimeType
    }
}
