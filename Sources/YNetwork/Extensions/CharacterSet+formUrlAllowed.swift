//
//  CharacterSet+formUrlAllowed.swift
//  YNetwork
//
//  Created by Mark Pospesel on 9/23/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation

/// Add helpers for form URL encoding
extension CharacterSet {
    /// Characters allowed in form URL encoding
    public static let formUrlAllowed: CharacterSet = {
        var toExclude = CharacterSet(charactersIn: "+&=/?")
        return CharacterSet.urlQueryAllowed
            .subtracting(toExclude)
    }()
}
