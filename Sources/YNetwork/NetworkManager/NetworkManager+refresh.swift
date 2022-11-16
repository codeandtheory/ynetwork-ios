//
//  NetworkManager+refresh.swift
//  YNetwork
//
//  Created by Mark Pospesel on 9/9/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

extension NetworkManager {
    /// Refresh the session token if necessary and if refresh is successful, repeat the original network call.
    /// If the original network call returns anything other than a 401, or if we don't have a session manager,
    /// then we do nothing.
    ///
    /// If we have n consecutive network calls all failing with a 401,
    /// we want to have the session manager refresh the session token exactly once.
    /// All processes should await the outcome of the single refresh call and then
    /// either all resubmit their network calls or all fail.
    /// - Parameters:
    ///   - urlRequest: the original network request
    ///   - data: original data from `urlRequest`
    ///   - response: original response from `urlRequest`
    func refreshIfNeeded(urlRequest: URLRequest, data: inout Data, response: inout URLResponse) async {
        guard let sessionManager = sessionManager,
              let urlResponse = response as? HTTPURLResponse,
              urlResponse.statusCode == 401 else {
            // nothing to do
            return
        }

        do {
            // Wait for the session manager to refresh the token (or fail)
            // This is synchronized so that refresh is only called once
            guard await waitForRefresh(sessionManager).value else {
                // refresh failed
                return
            }

            // apply refreshed session credentials to the original request
            var urlRequest = urlRequest
            sessionManager.apply(&urlRequest)
            // repeat the network call (with the new session credentials)
            (data, response) = try await configuration.networkEngine.submit(urlRequest)
        } catch {
            // discard this error and use the 401
        }
    }

    /// Refreshes the session token. This is designed to only have one refresh operation at a time.
    ///
    /// If a refresh task is in progress, merely return the handle to that task.
    /// Otherwise create a new task to refresh the session token and then cache the handle.
    /// (When the refresh operation completes, we clear the cached handle.)
    /// - Parameter sessionManager: session manager to use
    /// - Returns: a handle to the refresh task (that can be waited on)
    func waitForRefresh(_ sessionManager: SessionManager) -> Task<Bool, Never> {
        if let task = refreshTask {
            // return the existing refresh task (if any)
            return task
        }

        // create a refresh task
        let handle: Task<Bool, Never> = Task {
            defer { refreshTask = nil }
            return await sessionManager.refresh(networkManager: self)
        }

        // cache it and return the handle
        refreshTask = handle
        return handle
    }
}
