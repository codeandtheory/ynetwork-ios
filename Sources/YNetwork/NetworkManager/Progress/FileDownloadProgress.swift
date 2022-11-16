//
//  FileDownloader.swift
//  YNetwork
//
//  Created by Anand Kumar on 24/02/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// Persistent object used to track file download progress across multiple requests.
///
/// This class is not intended for external use (hence it is marked `internal`).
/// NetworkManager will hold a strong reference to one instance of this object and use it
/// to optionally track progress for large file download tasks.
internal class FileDownloadProgress: FileProgress { }

extension FileDownloadProgress: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // Update the status before unregister the task identifier
        if let error = error {
            updateDownloadStatus(result: .failure(error), forKey: task.taskIdentifier)
        }
        
        // clean up the task now that we're finished with it (success or failure)
        unregister(forKey: task.taskIdentifier)
    }
}

extension FileDownloadProgress: URLSessionDownloadDelegate {
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        // Update the status before unregister the task identifier
        let result: Result<URL, Error>
        if let error = checkResponseForError(task: downloadTask) {
            // for non-200 range responses we should return an error
            result = .failure(error)
        } else {
            // otherwise we return success
            result = .success(location)
        }
        updateDownloadStatus(result: result, forKey: downloadTask.taskIdentifier)
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        let percent = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        signal(percent: percent, forKey: downloadTask.taskIdentifier)
    }
}
