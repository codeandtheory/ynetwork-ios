//
//  UnitTestPath.swift
//  YNetworkTests
//
//  Created by Mark Pospesel on 11/18/21.
//  Copyright © 2021 Y Media Labs. All rights reserved.
//

import Foundation
import YNetwork

/// URL paths for various unit test cases
enum UnitTestPath: String, PathRepresentable {
    case webaim = "https://webaim.org/resources"
    case google = "https://google-translate1.p.rapidapi.com"
    case knownBadPath = "https://open t db.com/api.php"
    case openTriviaDb = "https://opentdb.com/api.php"
    case yml = "https://yml.co"
    case postImage = "https://imageshack.com/rest_api/v2/images"
}
