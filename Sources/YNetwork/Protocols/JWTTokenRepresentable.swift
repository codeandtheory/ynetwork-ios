//
//  JWTTokenRepresentable.swift
//  YNetwork
//
//  Created by Sanjib Chakraborty on 27/01/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// Protocol that represents a decoded JWT token.
public protocol JWTTokenRepresentable {
    /// header part of JWT token
    var header: [String: Any] { get }

    /// body part of JWT token
    var body: [String: Any] { get }

    /// signature part of JWT token
    var signature: String? { get }

    /// JWT token string
    var string: String { get }

    /// value of exp claim
    var expiresAt: Date? { get }

    /// value of iss claim
    var issuer: String? { get }

    /// value of sub claim
    var subject: String? { get }

    /// value of aud claim
    var audience: [String]? { get }

    /// value of iat claim
    var issuedAt: Date? { get }

    /// value of nbf claim
    var notBefore: Date? { get }

    /// value of jti if available
    var identifier: String? { get }

    /// Checks if the token is currently expired using the exp claim.
    /// If there is no claim present it will deem the token not expired
    var isExpired: Bool { get }
}
