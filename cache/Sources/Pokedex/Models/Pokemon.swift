import FluentSQLite
import Foundation
import Vapor

/// Represents a Pokemon we have captured and logged in our Pokedex.
final class Pokemon: SQLiteModel {
    /// See `Model.idKey`
    static let idKey = \Pokemon.id

    /// See `Model.id`
    var id: UUID?

    /// The Pokemon's name.
    var name: String

    /// See `Timestampable.createdAt`
    var createdAt: Date?

    /// See `Timestampable.updatedAt`
    var updatedAt: Date?

    /// Creates a new `Pokemon`.
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

/// Allows this model to be parsed/serialized to HTTP messages
/// as JSON or any other supported format.
extension Pokemon: Content { }

/// Allows this Model to be used as its own database migration.
/// The database schema will be inferred from the Model's properties.
extension Pokemon: Migration { }

/// Allows this Model to be parameterized in Router paths.
extension Pokemon: Parameter { }

/// Allows Fluent to automatically update this Model's `createdAt`
/// and `updatedAt` properties as necessary.
extension Pokemon: Timestampable { }
