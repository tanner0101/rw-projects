@testable import App
import Vapor

extension Application {
    /// Creates an `Application` configured for testing.
    static func test() throws -> Application {
        var config = Config()
        var services = Services.default()
        var env = Environment.testing

        try configure(&config, &env, &services)
        return try Application(config: config, environment: env, services: services)
    }
}
