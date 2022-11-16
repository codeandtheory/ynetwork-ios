//
//  URLBuilder.swift
//  YNetwork
//
//  Created by Mark Pospesel on 9/22/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Builds a URL from a request
open class URLBuilder {
    /// Builds a path from a request (without considering query parameters)
    /// - Parameters:
    ///   - request: request with `path` and optional `basePath`
    ///   - configuration: configuration with optional `basePath`
    /// - Throws: `NetworkError.noBasePath` if no `basePath` is specified for a request with a relative path
    /// - Returns: a complete path (without query parameters) that will be used to create a `URL`
    open func path(for request: NetworkRequest, configuration: NetworkManagerConfiguration) throws -> String {
        if request.path.pathValue.isAbsoluteURLPath {
            return request.path.pathValue
        }
        
        guard var basePath = (request.basePath ?? configuration.basePath)?.pathValue else {
            throw NetworkError.noBasePath
        }
    
        var relativePath = request.path.pathValue

        // strip trailing slashes from base path
        while basePath.hasSuffix("/") {
            basePath.removeLast()
        }

        // strip leading slashes from relative path
        while relativePath.hasPrefix("/") {
            relativePath.removeFirst()
        }

        // join together with exactly one forwards slash
        return "\(basePath)/\(relativePath)"
    }
    
    /// Builds a URL from a request and a configuration
    /// - Parameters:
    ///   - request: request with `path`, optional `basePath`, optional `queryParameters`, and `contentType`
    ///   - configuration: configuration with optional `basePath`
    /// - Throws: an error if configuration is nil or if a valid `URL` cannot be generated
    /// - Returns: a valid `URL` that will be used to generate a `URLRequest`
    open func url(for request: NetworkRequest, configuration: NetworkManagerConfiguration!) throws -> URL {
        guard let configuration = configuration else {
            throw NetworkError.notConfigured
        }
        
        var urlPath: String
        
        do {
            urlPath = try path(for: request, configuration: configuration)
        } catch {
            throw error
        }
        
        // Add query parameters
        if let parameters = request.queryParameters?.parameters,
           !parameters.isEmpty {
            let queryString = queryString(with: parameters, contentType: request.requestType)
            if !queryString.isEmpty {
                let connector = urlPath.contains("?") ? "&" : "?"
                urlPath.append("\(connector)\(queryString)")
            }
        }
        
        guard let url = URL(string: urlPath) else {
            throw NetworkError.invalidURL
        }
        return url
    }
    
    /// Generates a query string from a dictionary of parameters
    /// - Parameters:
    ///   - parameters: Dictionary of query parameters
    ///   - contentType: request content Type (determines encoding)
    /// - Returns: a percent-escaped query string that can be used to create a `URL`
    open func queryString(with parameters: Parameters, contentType: RequestContentType) -> String {
        parameters
            .compactMap { queryParameterString(field: $0, value: $1, contentType: contentType) }
            .sorted()
            .joined(separator: "&")
    }
    
    /// Generates a query parameter string for a given key/value pair
    /// - Parameters:
    ///   - field: key name
    ///   - value: value
    ///   - contentType: request content Type (determines encoding)
    /// - Returns: a percent-escaped query parameter string that can be used to build a complete query string
    open func queryParameterString(field: String, value: Any, contentType: RequestContentType) -> String? {
        // query parameters need to be percent-encoded
        guard var escapedField = field.addingPercentEncoding(withAllowedCharacters: .formUrlAllowed) else {
            return nil
        }
        
        if contentType == .formURLEncoded {
            // for form URL Encoded we escape space (" ") with ("+")
            // e.g. first+name=John+Doe
            escapedField = escapedField.replacingOccurrences(of: "%20", with: "+")
        }
        
        if let booleanValue = value as? Bool {
            return booleanValue ? "\(escapedField)" : nil
        }
        
        let escapedValue: Any

        if let stringValue = value as? String {
            guard let encoded = stringValue.addingPercentEncoding(withAllowedCharacters: .formUrlAllowed) else {
                return nil
            }
            
            if contentType == .formURLEncoded {
                // for form URL Encoded we escape space (" ") with ("+")
                // e.g. first+name=John+Doe
                escapedValue = encoded.replacingOccurrences(of: "%20", with: "+")
            } else {
                escapedValue = encoded
            }
        } else {
            escapedValue = value
        }
        
        return "\(escapedField)=\(escapedValue)"
    }
}
