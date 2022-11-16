//
//  ImageDownloadRequest.swift
//  YNetworkTests
//
//  Created by Sumit Goswami on 13/04/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation
@testable import YNetwork

struct ImageDownloadRequest: NetworkRequest {
    var path: PathRepresentable {
        "https://res.cloudinary.com/swiggy/image/upload/fl_lossy,f_auto,q_auto,w_1024/h7fsyiyvx3tawfhkh5b2"
    }
}
