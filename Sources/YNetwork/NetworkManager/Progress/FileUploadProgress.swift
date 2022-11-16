//
//  FileUploader.swift
//  YNetwork
//
//  Created by Anand Kumar on 24/02/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// Persistent object used to track file upload progress across multiple requests.
///
/// This class is not intended for external use (hence it is marked `internal`).
/// NetworkManager will hold a strong reference to one instance of this object and use it
/// to optionally track progress for large file upload tasks.
internal class FileUploadProgress: FileProgress { }

extension FileUploadProgress: URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        let percent = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        signal(percent: percent, forKey: task.taskIdentifier)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // clean up the task now that we're finished with it
        unregister(forKey: task.taskIdentifier)
    }
}
