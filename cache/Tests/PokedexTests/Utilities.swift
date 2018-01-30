import Pokedex
import Vapor

extension Application {
    /// Configures an Application for testing, we will just be using the default app
    public static func makeTest() throws -> Application {
        return try Application()
    }
}

extension PokeAPI {
    /// Creates a `PokeAPI` instance configured for testing.
    public static func makeTest(on container: Container) throws -> PokeAPI {
        return try PokeAPI(
            /// Use the container to make an HTTP client
            client: container.make(Client.self, for: PokeAPI.self),
            /// Instead of using the container to create a cache, we will use
            /// a simple In-Memory cache to limit the scope of our test to HTTP.
            cache: MemoryKeyedCache()
        )
    }
}
