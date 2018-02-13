import FluentSQLite
import Todo
import Vapor

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register providers first
    try services.register(FluentSQLiteProvider())

    // Register non-standard server config for port 8081
    let serverConfig = try EngineServerConfig.detect(port: 8081)
    services.register(serverConfig)

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Configure a SQLite database
    var databases = DatabaseConfig()
    try databases.add(database: SQLiteDatabase(storage: .memory), as: .sqlite)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: PrivateUser.self, database: .sqlite)
    services.register(migrations)

    // Configure JWT signer
    services.register(Identity.signer())

    // Configure the rest of your application here
}
