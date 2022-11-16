//
//  NetworkManager+URLSessionDownloadDelegate.swift
//  YNetwork
//
//  Created by Mark Pospesel on 1/14/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

// MARK: - URLSessionDownloadDelegate

extension NetworkManager: URLSessionDownloadDelegate {
    /// :nodoc:
    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        fileDownload.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
    }

    /// :nodoc:
    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        fileDownload.urlSession(
            session,
            downloadTask: downloadTask,
            didWriteData: bytesWritten,
            totalBytesWritten: totalBytesWritten,
            totalBytesExpectedToWrite: totalBytesExpectedToWrite
        )
    }
}
