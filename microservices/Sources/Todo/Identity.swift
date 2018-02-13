import Foundation
import JWT
import Vapor

public struct Identity: JWTPayload {
    /// Holds the owner's ID.
    public var id: UUID

    /// Holds information about the subject.
    public var sub: SubjectClaim {
        return SubjectClaim(value: id.uuidString)
    }

    /// Holds information about the expiration date.
    public var exp: ExpirationClaim

    /// See `JWTPayload.verify()`
    public func verify() throws {
        try exp.verify()
    }
}

/// JWT with Identity payload
public typealias IdentityToken = JWT<Identity>

extension Identity {
    /// Creates an `Identity` containing JWT for this `User`.
    /// Returns `nil` if the `User` does not have an identifier.
    public static func makeJWT(id: UUID) -> IdentityToken {
        let expiration = Date().addingTimeInterval(60 * 15) // 15 minutes from now
        let identity = Identity(id: id, exp: ExpirationClaim(value: expiration))
        return JWT(payload: identity)
    }

    /// Creates a JWT signer.
    public static func signer() -> JWTSigner {
        return .hs256(key: Data())
    }

    /// Signs the supplied token by creating a JWT signer from the container.
    public static func signJWT(_ token: inout IdentityToken, using container: Container) throws -> String {
        let signer = try container.make(JWTSigner.self, for: IdentityToken.self)
        return try String(data: token.sign(using: signer), encoding: .ascii) ?? ""
    }

    /// Parses a JWT from the supplied data using a container.
    public static func parseJWT(from data: Data, using container: Container) throws -> IdentityToken {
        let signer = try container.make(JWTSigner.self, for: IdentityToken.self)
        return try IdentityToken(from: data, verifiedUsing: signer)
    }
}

extension Request {
    /// Parses an `Identity` from the `Request` or throws an error.
    public func requireIdentity() throws -> Identity {
        guard let bearer = http.headers[.authorization] else {
            throw Abort(.unauthorized, reason: "No authorization header.")
        }

        guard let token = bearer.split(separator: " ").last else {
            throw Abort(.unauthorized, reason: "Malformatted authorization header.")
        }

        let jwt = try Identity.parseJWT(from: Data(token.utf8), using: self)
        return jwt.payload
    }
}

/// Allows JWT signers to be used as a service.
extension JWTSigner: Service { }
