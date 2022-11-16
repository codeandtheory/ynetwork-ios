//
//  DataParserFactory.swift
//  YNetwork
//
//  Created by Sumit Goswami on 21/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Represents a factory that can vend decoders and encoders for the specified content type
public protocol DataParserFactory {
    /// Vends a decoder for the response type
    /// - Parameter contentType: the response content type to fetch a decoder for
    /// - Returns: The decoder to use or else nil
    func decoder(for contentType: ResponseContentType) -> DataDecoder?
    
    /// Vends an encoder for the request type
    /// - Parameter contentType: the request content type to fetch an encoder for
    /// - Returns: The encoder to use or else nil
    func encoder(for contentType: RequestContentType) -> DataEncoder?
}
