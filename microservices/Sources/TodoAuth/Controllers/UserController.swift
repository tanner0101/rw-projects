import Todo
import Foundation
import FluentSQLite
import Vapor

/// Controls user creation and login.
final class UserController {
    /// Saves a decoded `User` to the database.
    func signup(_ req: Request) throws -> Future<User> {
        /// Decode user credentials from the request as well as a `name`.
        return try flatMap(
            to: PrivateUser.self,
            req.content.decode(UserCredentials.self),
            req.content.get(String.self, at: "name")
        ) { creds, name in
            /// Create a BCrypt hasher to hash the password.
            let hashedPassword = try req.make(BCryptHasher.self)
                .make(creds.cleartextPassword)

            /// Create a new user.
            let user = PrivateUser(
                name: name,
                email: creds.email,
                hashedPassword: hashedPassword
            )

            /// Save the user.
            return user.save(on: req)
        }.map(to: User.self) { user in
            return user.public
        }
    }

    /// Logs a user in.
    func login(_ req: Request) throws -> Future<[String: String]> {
        /// Use same unauthorized error for email not found
        /// AND password didn't match to prevent information leakage.
        let unauthorized = Abort(.unauthorized, reason: "Invalid credentials.")

        /// Decode user credentials from request.
        return try req.content.decode(UserCredentials.self).flatMap(to: [String: String].self) { creds in
            /// Use email in user credentials to find the first matching user.
            return PrivateUser.query(on: req).filter(\.email == creds.email).first()
                .unwrap(or: unauthorized)
                .map(to: [String: String].self)
            { user in
                /// Use BCryptHasher to check if passwords match.
                guard try req.make(BCryptHasher.self).verify(
                    message: creds.cleartextPassword,
                    matches: user.hashedPassword
                ) else {
                    throw unauthorized
                }

                /// Create a JWT.
                var jwt = try Identity.makeJWT(id: user.requireID())

                /// Sign the JWT.
                let token = try Identity.signJWT(&jwt, using: req)

                /// Convert to identity token response.
                return ["token": token]
            }
        }
    }
}
