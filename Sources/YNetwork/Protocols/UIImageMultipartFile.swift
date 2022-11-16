//
//  UIImageMultipartFile.swift
//  YNetwork
//
//  Created by Mark Pospesel on 1/13/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import UIKit

/// Information to describe a UIImage file (as a single part of a multipart message)
public protocol UIImageMultipartFile: MultipartFile {
    /// Image
    var image: UIImage { get }

    /// File Name
    var fileName: String { get }

    /// Image data type
    ///
    /// Determines how `image` will be converted to `Data`.
    var imageType: UIImageDataType { get }
}

extension UIImageMultipartFile {
    /// MIME content type
    public var mimeType: String { imageType.value }

    /// File data
    public var data: Data? {
        switch imageType {
        case .jpg(let quality):
            return image.jpegData(compressionQuality: quality)
        case .jpeg(let quality):
            return image.jpegData(compressionQuality: quality)
        case .png:
            return image.pngData()
        }
    }
}

/// Information to describe a UIImage file (as a single part of a multipart message)
///
/// Basic struct that conforms to `UIImageMultipartFile`
public struct UIImageMultipartFileInfo: UIImageMultipartFile {
    /// Image
    public let image: UIImage

    /// File Name
    public let fileName: String

    /// Image data type
    ///
    /// Determines how `image` will be converted to `Data`.
    public let imageType: UIImageDataType
    
    /// Initializes a multipart file info
    /// - Parameters:
    ///   - image : Image
    ///   - fileName: file name
    ///   - imageType: Image Data Type
    public init(image: UIImage, fileName: String, imageType: UIImageDataType) {
        self.image = image
        self.fileName = fileName
        self.imageType = imageType
    }
}
