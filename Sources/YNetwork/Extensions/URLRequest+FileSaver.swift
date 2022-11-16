//
//  URLRequest+FileSaver.swift
//  YNetwork
//
//  Created by Anand Kumar on 28/01/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

extension URLRequest {
    /// Writes the data into temporary directory & throws an file url
    public func writeDataToFile() throws -> URL {
        let localURL = fetchLocalUrl()
        try self.httpBody?.write(to: localURL)
        return localURL
    }
    
    /// Creates local url from temporary directory
    internal func fetchLocalUrl() -> URL {
        FileManager.default
            .temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: false)
    }
}
