import FluentSQLite
import Foundation
import Todo
import Vapor

/// Represents a Todo user + the private information known
/// only by the Auth microservice (such as hashed password).
public final class PrivateUser: Content {
    /// The unique identifier for this `Todo`.
    public var id: UUID?

    /// This user's preferred name.
    public var name: String

    /// This user's email address.
    public var email: String

    /// Hashed string created from cleartext password.
    public var hashedPassword: String

    /// Creates a new `Todo`.
    public init(id: UUID? = nil, name: String, email: String, hashedPassword: String) {
        self.id = id
        self.name = name
        self.email = email
        self.hashedPassword = hashedPassword
    }

    /// Creates a public version of this user. (Without the hashed password)
    public var `public`: User {
        return .init(id: id, name: name, email: email)
    }
}

/// A single user.
extension PrivateUser: SQLiteModel {
    /// See `SQLiteModel.name`
    public static var name: String { return "user" }

    /// See `Model.idKey`
    public static var idKey: ReferenceWritableKeyPath<PrivateUser, UUID?> { return \.id }
}

/// Allows `User` to be used as a dynamic migration.
extension PrivateUser: Migration { }

/// Allows `User` to be used as a dynamic parameter in route definitions.
extension PrivateUser: Parameter { }
