//
//  NetworkEngine.swift
//  YNetwork
//
//  Created by Sanjib Chakraborty on 29/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// The Network engine issues API requests, sychronously returns a cancelable task,
/// and asynchronously completes with the response and associated data upon success or else an error upon failure.
/// Your app will not need to interact directly with the NetworkEngine, but rather with the NetworkManager.
/// NetworkManager handles building the request, encoding the parameters, optionally encrypting data,
/// optionally decrypting the response, and decoding the data into business objects.
/// You may choose to implement your own NetworkEngine if your app will be using a different protocol, such
/// as WebRTC or something that communicates over UDP.
public protocol NetworkEngine {
    /// Configure the network engine. This must be called once prior to calling `submit`.
    /// It may be called multiple times, but should only be done if the configuration has changed.
    /// - Parameter configuration: the configuration to use
    func configure(with configuration: NetworkEngineConfiguration)

    /// Submit a network request using async/await
    /// - Throws: any error from handling the request
    /// - Parameter request: the request to submit
    /// - Returns: a tuple of the returned data and URL response
    func submit(_ request: URLRequest) async throws -> (Data, URLResponse)

    /// Submit a download network request to be executed in a background session.
    ///
    /// Immediately throws an error if the engine has not been configured.
    /// Progress, completion, and failure callbacks will occur via session delegate.
    /// - Parameter request: the download request to submit
    /// - Returns: a cancelable download task
    @discardableResult func submitBackgroundDownload(_ request: URLRequest) throws -> Cancelable
    
    /// Submit a upload network request to be executed in a background session.
    ///
    /// Immediately throws an error if the engine has not been configured.
    /// Progress, completion, and failure callbacks will occur via session delegate.
    /// - Parameters:
    ///   - request: the upload request to submit
    ///   - fileUrl: the file to upload
    /// - Returns: a cancelable upload task
    @discardableResult func submitBackgroundUpload(_ request: URLRequest, fileUrl: URL) throws -> Cancelable
}
