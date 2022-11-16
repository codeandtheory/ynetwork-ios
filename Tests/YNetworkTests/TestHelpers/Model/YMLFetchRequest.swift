//
//  YMLFetchRequest.swift
//  YNetworkTests
//
//  Created by Sumit Goswami on 01/04/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

@testable import YNetwork

struct YMLFetchRequest { }

extension YMLFetchRequest: NetworkRequest {
    var path: PathRepresentable { UnitTestPath.yml }
    var responseType: ResponseContentType { .none }
}
