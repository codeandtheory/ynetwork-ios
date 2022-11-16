//
//  JSONDataParserFactory.swift
//  YNetwork
//
//  Created by Sumit Goswami on 22/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// A parser factory that vends JSON encoders and decoders
public struct JSONDataParserFactory {
    private let decoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private let formURLEncoder: FormURLEncoder
    
    /// Initializes a parser factory with the specified JSON decoder and encoder.
    /// Use this method to pass decoder/encoder for custom behaviors.
    /// - Parameters:
    ///   - decoder: JSON decoder to use for JSON responses
    ///   - encoder: JSON encoder to use for JSON requests
    public init(decoder: JSONDecoder, encoder: JSONEncoder) {
        self.decoder = decoder
        self.jsonEncoder = encoder
        self.formURLEncoder = FormURLEncoder()
    }
    
    /// Initializes a parser factory with default JSON decoder and encoder.
    public init() {
        self.init(decoder: JSONDecoder.defaultDecoder, encoder: JSONEncoder.defaultEncoder)
    }
}

/// JSONDataParserFactory conformance to `DataParserFactory` protocol
extension JSONDataParserFactory: DataParserFactory {
    /// Vends a decoder for the response type
    /// - Parameter contentType: the response content type to fetch a decoder for
    /// - Returns: A `JSONDecoder` if content type is JSON, otherwise `nil`
    public func decoder(for contentType: ResponseContentType) -> DataDecoder? {
        guard contentType == .JSON else { return nil }
        return decoder
    }
    
    /// Vends an encoder for the request type
    /// - Parameter contentType: the request content type to fetch an encoder for
    /// - Returns: A `JSONEncoder` if content type is JSON,
    /// a `FormURLEncoder` if content type is form URL encoded, otherwise `nil`
    public func encoder(for contentType: RequestContentType) -> DataEncoder? {
        switch contentType {
        case .JSON, .multipart:
            return jsonEncoder
        case .formURLEncoded:
            return formURLEncoder
        case .none, .binary:
            return nil
        }
    }
}
