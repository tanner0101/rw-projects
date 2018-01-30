import FluentSQLite
import Vapor

/// A simple TODO-list item.
final class Todo: SQLiteModel, Content, Migration, Parameter {
    /// See `SQLiteModel.idKey`
    static let idKey = \Todo.id

    /// Unique identifier for this `Todo`
    var id: Int?

    /// Short, descriptive title explaining this `Todo`
    var title: String

    /// Creates a new `Todo`
    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
