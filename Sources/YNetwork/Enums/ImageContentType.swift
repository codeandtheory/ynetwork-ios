//
//  ImageContentType.swift
//  YNetwork
//
//  Created by Anand Kumar on 04/01/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// Image Content type
///
/// New types should be added as needed
public enum ImageContentType {
    /// JPG
    case jpg
    /// JPEG
    case jpeg
    ///  PNG
    case png
    /// GIF
    case gif
}

public extension ImageContentType {
    /// Content-Type value
    var value: String {
        let type: String

        switch self {
        case .jpg: type = "jpg"
        case .jpeg: type = "jpeg"
        case .png: type = "png"
        case .gif: type = "gif"
        }

        return "image/\(type)"
    }
}

// Unit test helpers

extension ImageContentType: CaseIterable { }
