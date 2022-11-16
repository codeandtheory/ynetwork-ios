//
//  Data+AppendString.swift
//  YNetwork
//
//  Created by Anand Kumar on 24/12/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

extension Data {
    mutating func appendString(_ string: String) {
        append(Data(string.utf8))
    }
}
