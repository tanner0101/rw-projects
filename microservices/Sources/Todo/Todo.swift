import Foundation
import Vapor

/// A single entry of a Todo list.
public final class Todo: Content {
    /// The unique identifier for this `Todo`.
    public var id: UUID?

    /// A title describing what this `Todo` entails.
    public var title: String

    /// Reference to the user that created this `Todo` item.
    public var userID: UUID

    /// Creates a new `Todo`.
    public init(id: UUID? = nil, title: String, userID: UUID) {
        self.id = id
        self.title = title
        self.userID = userID
    }
}
