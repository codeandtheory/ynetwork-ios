//
//  FileProgress.swift
//  YNetwork
//
//  Created by Mark Pospesel on 2/24/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// Percentage expressed as a double value
public typealias Percentage = Double

/// Asynchronous completion handler that reports file progress as a percentage (ranging from 0.0 to 1.0).
///
/// Guaranteed to be called back on the main thread
public typealias ProgressHandler = (Percentage) -> Void

/// Asynchronous completion handler that reports the status of request.
///
/// Guaranteed to be called back on a background thread (because the system erases the temporary file)
public typealias FileDownloadHandler = (Result<URL, Error>) -> Void

/// Persistent object used to track file progress across multiple requests.
///
/// This class is not intended for external use (hence it is marked `internal`).
/// NetworkManager will hold a strong reference to one instance of this object and use it
/// to optionally track progress for large file download tasks.
internal class FileProgress: NSObject {
    /// Stores the progress handlers to be called, keyed by unique task identifier
    private var progressHandlersByTaskID: [Int: ProgressHandler] = [:]
    private var downloadHandlersByTaskID: [Int: FileDownloadHandler] = [:]

    /// Updates the progress handler for the specified task with the percentage value
    /// - Parameters:
    ///   - percent: percent completion, ranging from 0.0 to 1.0
    ///   - taskIdentifier: unique task identifier
    func signal(percent: Percentage, forKey taskIdentifier: Int) {
        guard let progressHandler = progressHandlersByTaskID[taskIdentifier] else { return }
        DispatchQueue.main.async {
            progressHandler(percent)
        }
    }

    /// Updates the request status for the specified task with the file URL
    /// - Parameters:
    ///   - result: Result contain file downloaded path url & error type
    ///   - taskIdentifier: unique task identifier
    func updateDownloadStatus(result: (Result<URL, Error>), forKey taskIdentifier: Int) {
        guard let completionhandler = downloadHandlersByTaskID[taskIdentifier] else { return }
        // Do not call on main thread because the system will erase this temporary file
        // after the URLSession delegate callback completes
        completionhandler(result)
    }
    
    /// Registers a data task for file progress.
    /// - Parameters:
    ///   - cancelable: optional cancelable task
    ///   - progress: optional progress handler
    func register(_ cancelable: Cancelable?, progress: ProgressHandler?) {
        guard let task = cancelable as? URLSessionTask,
              let progress = progress else { return }
        progressHandlersByTaskID[task.taskIdentifier] = progress
    }
    
    /// Registers a data task for file progress.
    /// - Parameters:
    ///   - cancelable: optional cancelable task
    ///   - progress: optional progress handler
    ///   - handler: file download handler (will be called back on URLSession background thread)
    func registerDownload(
        _ cancelable: Cancelable?,
        progress: ProgressHandler?,
        handler: @escaping FileDownloadHandler
    ) {
        register(cancelable, progress: progress)
        guard let task = cancelable as? URLSessionTask else { return }
        downloadHandlersByTaskID[task.taskIdentifier] = handler
    }

    /// Unregisters a data task for file progress
    /// - Parameter taskIdentifier: unique task identifier
    func unregister(forKey taskIdentifier: Int) {
        progressHandlersByTaskID.removeValue(forKey: taskIdentifier)
        downloadHandlersByTaskID.removeValue(forKey: taskIdentifier)
    }

    func checkResponseForError(task: URLSessionTask) -> Error? {
        guard let httpResponse = task.response as? HTTPURLResponse else {
            return NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return nil
        case 401:
            return NetworkError.unauthenticated
        default:
            return HttpError(response: httpResponse, data: Data())
        }
    }
}
