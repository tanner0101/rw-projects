// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Pokedex",
    dependencies: [
        // 💧 A server-side Swift web framework. 
        .package(url: "https://github.com/vapor/vapor.git", .branch("beta")),

        // 🖋 Swift ORM framework (queries, models, and relations) for building NoSQL and SQL database integrations.
        // FIXME: will become FluentSQLite import once we fully separate packages
        .package(url: "https://github.com/vapor/fluent.git", .branch("beta")),
    ],
    targets: [
        .target(name: "Pokedex", dependencies: ["FluentSQLite", "Vapor"]),
        .target(name: "Run", dependencies: ["Pokedex"]),
        .testTarget(name: "PokedexTests", dependencies: ["Pokedex"]),
    ]
)

