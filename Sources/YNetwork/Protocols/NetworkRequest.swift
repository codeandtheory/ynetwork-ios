//
//  NetworkRequest.swift
//  YNetwork
//
//  Created by Anand Kumar on 16/11/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// All the information needed to make a network request.
/// The only required property to implement is `path`. Everything else has default values.
public protocol NetworkRequest {
    /// Optional base path of the request.
    /// May be nil if `path` is an absolute path or if `NetworkManagerConfiguration.basePath` has been set.
    /// If non-nil, supercedes `NetworkManagerConfiguration.basePath`.
    /// Default `nil`
    var basePath: PathRepresentable? { get }

    /// Path to the endpoint. May be a relative path if either `basePath` or
    /// `NetworkManagerConfiguration.basePath` has been set.
    /// Otherwise must be an absolute path.
    var path: PathRepresentable { get }

    /// HTTP method of the request. Default `.GET`
    var method: HttpMethod { get }
    
    /// Optional headers to include in the request.
    /// Will be combined with `NetworkManagerConfiguration.headers`.
    /// Default: `nil`
    var headers: HttpHeaders? { get }
    
    /// Content type of the request.
    /// Corresponds to the "Content-Type" HTTP header.
    /// Default `.JSON`
    var requestType: RequestContentType { get }

    /// Expected content type of the response.
    /// Corresponds to the "Accept" HTTP header.
    /// Default `.JSON`
    var responseType: ResponseContentType { get }

    /// Optional query parameters. Default `nil`
    var queryParameters: ParametersBuilder? { get }
    
    /// Optional request body. Default `nil`
    var body: BodyBuilder? { get }

    /// Optional timeout interval to use.
    /// If non-zero, supercedes `NetworkManagerConfiguration.timeoutInterval`.
    /// Default `0`
    var timeoutInterval: TimeInterval { get }
    
    /// Optional cache policy to use.
    /// If non-nil, supercedes `NetworkManagerConfiguration.cachePolicy`.
    /// Default `nil`
    var cachePolicy: URLRequest.CachePolicy? { get }

    /// Optional parser factory to vend encoders to encode the request and
    /// decoders to decode the response.
    /// If non-nil, supercedes `NetworkManagerConfiguration.parserFactory`.
    /// Default `nil`
    var parserFactory: DataParserFactory? { get }

    /// Whether this request should use session information.
    /// Default `true`
    ///
    /// When `true` the network manager's associated session manager (if any)
    /// may adjust the request (typically by adding a session token to the request's headers) prior to submiting,
    /// and in the event of a 401 response will attempt to refresh the session and retry the request.
    ///
    /// When `false`, the session manager will not adjust the request nor retry on a 401 response.
    ///
    /// Typically you would want to return `false` for your refresh token request and for other unauthenticated
    /// requests (such as log in, sign up, or register requests).
    var usesSession: Bool { get }
}

/// Default implementation for Network Request properties.
/// The only required property to implement is `path`. Everything else has default values.
public extension NetworkRequest {
    /// Uses no base path
    var basePath: PathRepresentable? { nil }

    /// Uses `.GET` HTTP method
    var method: HttpMethod { .GET }

    /// Includes no additional headers
    var headers: HttpHeaders? { nil }

    /// Sets `.JSON` as request content type
    var requestType: RequestContentType { .JSON }

    /// Sets `.JSON` as response content type
    var responseType: ResponseContentType { .JSON }

    /// No query parameters
    var queryParameters: ParametersBuilder? { nil }

    /// No body
    var body: BodyBuilder? { nil }

    /// Uses the default timeout interval
    var timeoutInterval: TimeInterval { 0 }

    /// Uses the default cache policy
    var cachePolicy: URLRequest.CachePolicy? { nil }

    /// Uses the default parser factory
    var parserFactory: DataParserFactory? { nil }

    /// Uses session tokens (if `NetworkManager.sessionManager` is specified)
    var usesSession: Bool { true }
}
