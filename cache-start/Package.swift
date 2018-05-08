// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Pokedex",
    dependencies: [
        // 💧 A server-side Swift web framework. 
        .package(url: "https://github.com/vapor/vapor.git", .branch("nio")),

        // 🖋 Swift ORM framework (queries, models, and relations) for building NoSQL and SQL database integrations.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", .branch("nio")),
    ],
    targets: [
        .target(name: "Pokedex", dependencies: ["FluentSQLite", "Vapor"]),
        .target(name: "Run", dependencies: ["Pokedex"]),
        .testTarget(name: "PokedexTests", dependencies: ["Pokedex"]),
    ]
)

