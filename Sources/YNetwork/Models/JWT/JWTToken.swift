//
//  JWTToken.swift
//  YNetwork
//
//  Created by Sanjib Chakraborty on 27/01/22.
//  Copyright © 2022 Y Media Labs. All rights reserved.
//

import Foundation

/// JWT token.
public struct JWTToken {
    public let header: [String: Any]
    public let body: [String: Any]
    public let signature: String?
    public let string: String
    
    /// public init method
    /// - Parameter jwtString: JWT token string
    public init(jwtString: String) throws {
        let parts = jwtString.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw JWTDecodeError.invalidPartCount(jwtString, parts.count)
        }

        self.header = try JWTToken.decodeJWTPart(parts[0])
        self.body = try JWTToken.decodeJWTPart(parts[1])
        self.signature = parts[2]
        self.string = jwtString
    }
}

extension JWTToken: JWTTokenRepresentable {
    public var expiresAt: Date? { JWTClaim(value: body["exp"]).date }
    public var issuer: String? { JWTClaim(value: body["iss"]).string }
    public var subject: String? { JWTClaim(value: body["sub"]).string }
    public var audience: [String]? { JWTClaim(value: body["aud"]).array }
    public var issuedAt: Date? { JWTClaim(value: body["iat"]).date }
    public var notBefore: Date? { JWTClaim(value: body["nbf"]).date }
    public var identifier: String? { JWTClaim(value: body["jti"]).string }

    public var isExpired: Bool {
        guard let date = self.expiresAt else { return false }
        return date.compare(Date()) != ComparisonResult.orderedDescending
    }
}

extension JWTToken {
    /// Decode part of a JWT and converts it to a dictionary
    /// - Parameter value: part of JWT token
    /// - Throws: a decode error
    /// - Returns: a dictionary for the corresponding JWT part
    static func decodeJWTPart(_ value: String) throws -> [String: Any] {
        guard let bodyData = base64Decode(value) else {
            throw JWTDecodeError.invalidBase64(value)
        }

        guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
                let payload = json as? [String: Any] else {
            throw JWTDecodeError.invalidJSON(value)
        }
        
        return payload
    }

    /// Converts a given string to base64 encoded data
    /// - Parameter value: string we want to convert to base64 data
    /// - Returns: base64 encoded data
    static func base64Decode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
}
