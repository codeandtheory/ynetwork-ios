//
//  NetworkEngineConfiguration.swift
//  YNetwork
//
//  Created by Sanjib Chakraborty on 29/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Subset of NetworkManagerConfiguration with only engine-specific values
public struct NetworkEngineConfiguration {
    /// Optional HTTP headers
    public let headers: HttpHeaders?
    
    /// Optional timeout interval (0 means use system default of 60 seconds)
    public let timeoutInterval: TimeInterval
    
    /// Optional cache policy
    public let cachePolicy: URLRequest.CachePolicy?

    /// Optional session delegate
    ///
    /// When set to `nil`, the `NetworkManager` will serve as session delegate.
    /// The network manager must be the session delegate in order to use the multicast delegate methods
    /// `NetworkManager.add(sessionDelegate:)` and `NetworkManager.remove(sessionDelegate:)`
    public weak var sessionDelegate: URLSessionDelegate?

    /// Initializes a network engine configuration
    /// - Parameters:
    ///   - headers: Optional headers
    ///   - timeoutInterval: Optional timeout interval
    ///   - cachePolicy: Optional cache policy
    ///   - sessionDelegate: Optional session delegate (nil means NetworkManager acts as delegate)
    public init(
        headers: HttpHeaders? = nil,
        timeoutInterval: TimeInterval = 0,
        cachePolicy: URLRequest.CachePolicy? = nil,
        sessionDelegate: URLSessionDelegate? = nil
    ) {
        self.headers = headers
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        self.sessionDelegate = sessionDelegate
    }
}

extension NetworkManagerConfiguration {
    /// Convert `NetworkManagerConfiguration` to `NetworkEngineConfiguration`
    public var engineConfiguration: NetworkEngineConfiguration {
        NetworkEngineConfiguration(
            headers: headers,
            timeoutInterval: timeoutInterval,
            cachePolicy: cachePolicy,
            sessionDelegate: sessionDelegate
        )
    }
}
