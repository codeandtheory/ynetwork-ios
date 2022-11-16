//
//  Cancelabel.swift
//  YNetwork
//
//  Created by Sanjib Chakraborty on 29/09/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Represents an operation that can be canceled
public protocol Cancelable {
    /// Cancel the operation
    func cancel()
}
