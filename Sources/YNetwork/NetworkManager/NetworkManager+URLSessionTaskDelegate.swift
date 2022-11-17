//
//  NetworkManager+URLSessionTaskDelegate.swift
//  YNetwork
//
//  Created by Mark Pospesel on 1/14/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

// MARK: - URLSessionTaskDelegate

extension NetworkManager: URLSessionTaskDelegate {
    /// :nodoc:
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        fileUpload.urlSession(
            session,
            task: task,
            didSendBodyData: bytesSent,
            totalBytesSent: totalBytesSent,
            totalBytesExpectedToSend: totalBytesExpectedToSend
        )
    }

    /// :nodoc:
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if task is URLSessionDownloadTask {
            fileDownload.urlSession(session, task: task, didCompleteWithError: error)
        } else if task is URLSessionUploadTask {
            fileUpload.urlSession(session, task: task, didCompleteWithError: error)
        }
    }
}
