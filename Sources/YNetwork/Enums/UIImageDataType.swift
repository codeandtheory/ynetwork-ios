//
//  UIImageContentType.swift
//  YNetwork
//
//  Created by Mark Pospesel on 1/13/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import UIKit

/// Different ways of converting UIImage to Data
///
/// New types should be added as needed
public enum UIImageDataType: Equatable {
    /// JPG
    ///
    /// Exact same thing as JPEG but maps to the `image/jpg` MIME Content Type
    /// (legacy from when file extensions could only have 3 characters)
    case jpg(compression: CGFloat)
    /// JPEG
    case jpeg(compression: CGFloat)
    ///  PNG
    case png
}

public extension UIImageDataType {
    /// Convert to `ImageContentType`
    var contentType: ImageContentType {
        switch self {
        case .jpg: return .jpg
        case .jpeg: return .jpeg
        case .png: return .png
        }
    }

    /// Content-Type value
    var value: String { contentType.value }
}
