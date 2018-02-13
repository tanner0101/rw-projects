// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Todo",
    dependencies: [
        // 💧 A server-side Swift web framework. 
        .package(url: "https://github.com/vapor/vapor.git", .exact("3.0.0-beta.1")),

        // 🖋 Swift ORM framework (queries, models, and relations) for building NoSQL and SQL database integrations.
        .package(url: "https://github.com/vapor/fluent.git", .exact("3.0.0-beta.1")),

        // 🔑 JSON Web Tokens in Swift.
        .package(url: "https://github.com/vapor/jwt.git", .exact("3.0.0-beta.1")),
    ],
    targets: [
        .target(name: "Todo", dependencies: ["JWT", "Vapor"]),
        .target(name: "TodoCore", dependencies: ["FluentSQLite", "Todo", "Vapor"]),
        .target(name: "TodoAuth", dependencies: ["FluentSQLite", "Todo", "Vapor"]),
        .testTarget(name: "TodoTests", dependencies: ["Todo"]),
    ]
)

