//
//  Data+HttpResponse.swift
//  YNetwork
//
//  Created by Mark Pospesel on 1/6/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

extension Data {
    /// Attempts to decode URL response data into a more usable form.
    ///
    /// If empty will return `.none`.
    ///
    /// If the data is deserializable into a JSON dictionary, returns `.jsonDictionary(dictionary)`.
    ///
    /// If the data is deserializable into a JSON array, returns `.jsonArray(array)`.
    ///
    /// Otherwise returns `.raw(data)`.
    /// - Returns: `HttpResponseType` enum with associated data.
    public func toHttpResponse() -> HttpResponseType {
        guard !isEmpty else { return .none }

        let jsonObject = try? JSONSerialization.jsonObject(with: self)
        if let dictionary = jsonObject as? [String: Any] {
            return .jsonDictionary(dictionary)
        } else if let array = jsonObject as? [Any] {
            return .jsonArray(array)
        }
        return .raw(self)
    }
}
