//
//  MultipartElement.swift
//  YNetwork
//
//  Created by Mark Pospesel on 1/13/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// Types of elements in a multipart message
///
/// New types should be added as needed
public enum MultipartElement {
    /// Form field
    case formField(value: CustomStringConvertible)

    /// File
    case file(info: MultipartFile)
}

public extension MultipartElement {
    /// Encode the multipart element as data
    /// - Parameters:
    ///   - data: mutable data array to write to
    ///   - name: name (or key) for this part
    func encode(data: inout Data, name: String) {
        switch self {
        case .formField(let value):
            MultipartElement.encodeFormField(data: &data, name: name, value: value)
        case .file(let info):
            MultipartElement.encodeFileData(data: &data, name: name, file: info)
        }
    }
}

private extension MultipartElement {
    static func encodeFormField(data: inout Data, name: String, value: CustomStringConvertible) {
        data.appendString("Content-Disposition: form-data; name=\"\(name)\"\r\n")
        data.appendString("\r\n")
        data.appendString("\(value)\r\n")
    }

    static func encodeFileData(data: inout Data, name: String, file: MultipartFile) {
        data.appendString(
            "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(file.fileName)\"\r\n"
        )
        data.appendString("Content-Type: \(file.mimeType)\r\n")
        data.appendString("\r\n")
        if let fileData = file.data {
            data.append(fileData)
        }
        data.appendString("\r\n")
    }
}
