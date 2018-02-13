import FluentSQLite
import Foundation
import Todo
import Vapor

/// A single entry of a Todo list.
extension Todo: SQLiteModel {
    /// See `Model.idKey`
    public static var idKey: ReferenceWritableKeyPath<Todo, UUID?> { return \.id }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Todo: Migration { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Todo: Parameter { }
