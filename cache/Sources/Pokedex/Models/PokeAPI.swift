import Vapor

/// A simple wrapper around the "pokeapi.co" API.
public final class PokeAPI {
    /// The HTTP client powering this API.
    let client: Client

    /// Internal cache for optimizing HTTP client API usage.
    let cache: KeyedCache

    /// Creates a new `PokeAPI` wrapper from the supplied client and cache.
    public init(client: Client, cache: KeyedCache) {
        self.client = client
        self.cache = cache
    }

    /// Returns `true` if the supplied Pokemon name is real.
    ///
    /// - parameter name: The Pokemon name to verify.
    /// - parameter worker: The async worker to use.
    public func verifyName(_ name: String, on worker: Worker) -> Future<Bool> {
        /// create a consistent cache key
        let key = name.lowercased()
        return cache.get(key, as: Bool.self).flatMap { result in
            if let exists = result {
                /// The verification result has been cached, no need to continue!
                /// Note: we must wrap the Bool in a Future here because we are inside of `flatMap`
                /// and the API fetch that happens after this is async.
                return worker.eventLoop.newSucceededFuture(result: exists)
            }

            /// This Pokemon was not cached, we need to query the PokeAPI to verify.
            return self.fetchPokemon(named: name).flatMap { res in
                switch res.http.status.code {
                case 200..<300:
                    /// The API returned 2xx which means this is a real Pokemon name
                    return self.cache.set(key, to: true).transform(to: true)
                case 404:
                    /// The API returned a 404 meaning this Pokemon name was not found.
                    return self.cache.set(key, to: false).transform(to: false)
                default:
                    /// The API returned a 500. Only thing we can do is forward the error.
                    throw Abort(.internalServerError, reason: "Unexpected PokeAPI response: \(res.http.status)")
                }
            }
        }
    }

    /// Fetches a pokemen with the supplied name from the PokeAPI.
    public func fetchPokemon(named name: String) -> Future<Response> {
        return client.get("https://pokeapi.co/api/v2/pokemon/\(name)")
    }
}

/// Allow our custom PokeAPI wrapper to be used as a Vapor service.
extension PokeAPI: ServiceType {
    /// See `ServiceType.makeService(for:)`
    public static func makeService(for container: Container) throws -> PokeAPI {
        /// Use the container to create the Client and KeyedCache services our PokeAPI wrapper needs.
        return try PokeAPI(client: container.make(), cache: container.make())
    }
}
