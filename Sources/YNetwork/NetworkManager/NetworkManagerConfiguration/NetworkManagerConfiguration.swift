//
//  NetworkManagerConfiguration.swift
//  YNetwork
//
//  Created by Sumit Goswami on 21/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// The main configuration point for NetworkManager
public struct NetworkManagerConfiguration {
    /// A common base path for all network calls.
    /// This might be where you specify your prod vs dev endpoint.
    /// A non-nil `basePath` in a specific request takes precedence.
    /// Also any request that has an absolute path will not make use of this value. Defaults to `nil`
    public let basePath: PathRepresentable?
    
    /// Optional HTTP headers to be issued with every network request. These can be used to specify
    /// language, app version, device information, etc.
    /// These headers will be combined with headers specified in each request plus Content-Type and Accept
    /// headers generated based upon the `requestType` and expected `responseType`. Defaults to `nil`
    public let headers: HttpHeaders?
    
    /// A parser factory for vending encoders and decoders depending upon the request and response content types,
    /// respectively. For now we're only handling `.JSON`. If a request specifies its own `parserFactory` then
    /// that takes precedence. Defaults to `JSONDataParserFactory` initialized with
    /// `JSONDecoder.defaultDecoder` and `JSONEncoder.defaultEncoder`
    public let parserFactory: DataParserFactory
    
    /// Default timeout value for all network requests. If a request specifies a non-zero `timeoutInterval` then
    /// that will take precedence. Defaults to `0`, which indicates to use the system time out
    /// (for `URLSession` 60 seconds)
    public let timeoutInterval: TimeInterval
    
    /// Cache policy to use for all network requests. If a request specifies a non-nil `cachePolicy` then that will
    /// take precendence. Defaults to `nil` which means use the default cache policy
    public let cachePolicy: URLRequest.CachePolicy?

    /// Optional session delegate
    ///
    /// When set to `nil`, the `NetworkManager` will serve as session delegate.
    /// The network manager must be the session delegate in order to use the multicast delegate methods
    /// `NetworkManager.add(sessionDelegate:)` and `NetworkManager.remove(sessionDelegate:)`
    public weak var sessionDelegate: URLSessionDelegate?

    /// The network engine to execute `URLRequest`'s and response with `URLResponse` and `Data` (or
    /// `Error`) upon failure. Defaults to an instance of `URLNetworkEngine` which wraps `URLSession`.
    /// Normally you would not need to specify an alternate unless your app requires greater control or a different
    /// networking protocol.
    public let networkEngine: NetworkEngine

    /// Initializes a network manager configuration
    /// - Parameters:
    ///   - basePath: Optional base path
    ///   - headers: Optional headers
    ///   - parserFactory: parser factory to vend encoders and decoders
    ///   - timeoutInterval: Optional timeout interval (0 means use system default of 60 seconds)
    ///   - cachePolicy: Optional cache policy to use
    ///   - sessionDelegate: Optional session delegate (nil means NetworkManager acts as delegate)
    ///   - networkEngine: Network engine to perform network requests
    public init(
        basePath: PathRepresentable? = nil,
        headers: HttpHeaders? = nil,
        parserFactory: DataParserFactory = JSONDataParserFactory(),
        timeoutInterval: TimeInterval = 0,
        cachePolicy: URLRequest.CachePolicy? = nil,
        sessionDelegate: URLSessionDelegate? = nil,
        networkEngine: NetworkEngine = URLNetworkEngine()
    ) {
        self.basePath = basePath
        self.headers = headers
        self.parserFactory = parserFactory
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        self.sessionDelegate = sessionDelegate
        self.networkEngine = networkEngine
    }
}
