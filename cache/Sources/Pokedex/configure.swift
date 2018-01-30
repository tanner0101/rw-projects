import FluentSQLite
import Vapor

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    /// Register providers
    try services.register(FluentSQLiteProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register our custom PokeAPI wrapper
    services.register(PokeAPI.self)

    /// Setup a simple in-memory SQLite database
    var databases = DatabaseConfig()
    let sqlite = try SQLiteDatabase(storage: .memory)
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    /// Ensure there is a table ready to store the Pokemon
    migrations.add(model: Pokemon.self, database: .sqlite)
    /// Ensure SQLiteCache has the tables it will need
    migrations.prepareCache(for: .sqlite)
    services.register(migrations)
}
