//
//  BodegaProduct.swift
//  YNetworkTests
//
//  Created by Sumit Goswami on 01/04/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

@testable import YNetwork

// Similar to GroceryProduct but does not conform to ParametersBuilder
struct BodegaProduct: Codable, Equatable, BodyBuilder {
    let name: String
    let points: Int
    let description: String?
}

extension BodegaProduct {
    static let durian = BodegaProduct(
        name: "Durian",
        points: 600,
        description: "A fruit with a distinctive scent."
    )
}
