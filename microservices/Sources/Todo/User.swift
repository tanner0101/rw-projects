import Foundation
import Vapor

/// A registered user.
public final class User: Content {
    /// The unique identifier for this `User`.
    public var id: UUID?

    /// This user's preferred name.
    public var name: String

    /// This user's email address.
    public var email: String

    /// Creates a new `Todo`.
    public init(id: UUID? = nil, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}
