//
//  SessionManager.swift
//  YNetwork
//
//  Created by Sanjib Chakraborty on 16/03/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// Implement this to have NetworkManager perform automatic retries on network requests when
/// your requests get a 401 response due to session expiry.
///
/// Do not call either of these methods directly. NetworkManager will call them when appropriate.
public protocol SessionManager {
    /// Applies the session to the current request.
    ///
    /// Most likely this will be done by applying headers.
    func apply(_ request: inout URLRequest)

    /// Attempts to refresh the current session (if any).
    ///
    /// If there is no session or it cannot be refreshed, immediately return `false`
    /// Upon success, the session manager is responsible to securely store the session information.
    /// - Parameter networkManager: networkManager to be used to issue the refresh request
    /// - Returns: `true` if the session token is successfully refreshed, otherwise `false`
    func refresh(networkManager: NetworkManager) async -> Bool
}
