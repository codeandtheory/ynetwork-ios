//
//  GroceryProduct.swift
//  YNetworkTests
//
//  Created by Sumit Goswami on 01/04/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

@testable import YNetwork

struct GroceryProduct: Codable, Equatable {
    let name: String
    let points: Int
    let description: String?
}

extension GroceryProduct: ParametersBuilder {
    var parameters: Parameters {
        var params: Parameters = [
            "name": name,
            "points": points
        ]
        if let description = description {
            params["description"] = description
        }
        return params
    }
}

extension GroceryProduct {
    static let durian = GroceryProduct(
        name: "Durian",
        points: 600,
        description: "A fruit with a distinctive scent."
    )
}
