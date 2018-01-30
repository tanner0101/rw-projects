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
    // register providers
    try services.register(FluentSQLiteProvider())

    // register routes to the router
    let router = EngineRouter.default()
    try routes(router, env)
    services.register(router, as: Router.self)

    // register custom service types
    services.register(SecretMiddleware.self)
    services.register(RateCounter.self)

    // configure middleware
    var middleware = MiddlewareConfig()
    middleware.use(LogMiddleware())
    middleware.use(ErrorMiddleware.self)
    middleware.use(DateMiddleware.self)
    services.register(middleware)

    // configure sqlite db
    var databases = DatabaseConfig()
    let sqlite = try SQLiteDatabase(storage: .memory)
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    // configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Todo.self, database: .sqlite)
    services.register(migrations)
}
