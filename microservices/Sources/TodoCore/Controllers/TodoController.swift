import Todo
import FluentSQLite
import Vapor

/// Controlers basic CRUD operations on `Todo`s.
final class TodoController {
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Todo]> {
        let identity = try req.requireIdentity()
        return Todo.query(on: req).filter(\.userID == identity.id).all()
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Todo> {
        let identity = try req.requireIdentity()
        return req.content.get(String.self, at: "title").flatMap(to: Todo.self) { title in
            let todo = Todo(title: title, userID: identity.id)
            return todo.save(on: req)
        }
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let identity = try req.requireIdentity()
        return try req.parameter(Todo.self).flatMap(to: Void.self) { todo in
            guard todo.userID == identity.id else {
                throw Abort(.unauthorized, reason: "You do not own this Todo.")
            }
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
}
