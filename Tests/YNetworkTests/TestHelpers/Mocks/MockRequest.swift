//
//  MockRequest.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 11/18/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation
import YNetwork

// Unit test request class where you can set any NetworkRequest property
struct MockRequest: NetworkRequest {
    var basePath: PathRepresentable?
    var path: PathRepresentable
    var method: HttpMethod = .GET
    var headers: HttpHeaders?
    var requestType: RequestContentType = .JSON
    var responseType: ResponseContentType = .JSON
    var queryParameters: ParametersBuilder?
    var body: BodyBuilder?
    var timeoutInterval: TimeInterval = 0
    var cachePolicy: URLRequest.CachePolicy?
    var parserFactory: DataParserFactory?
}

// Unit test request class where with all default properties
struct DefaultRequest: NetworkRequest {
    var path: PathRepresentable
}
