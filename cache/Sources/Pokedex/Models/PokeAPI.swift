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
    /// - parameter client: Queries the "pokeapi.co" API to verify supplied names
    /// - parameter cache: Caches client results to minimize slow, external API calls
    public func verifyName(_ name: String) throws -> Future<Bool> {
        /// create a consistent cache key
        let key = name.lowercased()
        return try cache.get(Bool.self, forKey: key).flatMap(to: Bool.self) { result in
            if let exists = result, exists {
                /// The verification result has been cached, no need to continue!
                /// Note: we must wrap the Bool in a Future here because we are inside of `flatMap`
                /// and the API fetch that happens after this is async.
                return Future(exists)
            }

            /// This Pokemon was not cached, we need to query the PokeAPI to verify.
            return self.fetchPokemon(named: name).flatMap(to: Bool.self) { res in
                switch res.status.code {
                case 200..<302: // FIXME: Pretend 301 is 200 until SSL works
                    /// The API returned 2xx which means this is a real Pokemon name
                    return try self.cache.set(true, forKey: key).transform(to: true)
                case 404:
                    /// The API returned a 404 meaning this Pokemon name was not found.
                    return try self.cache.set(false, forKey: key).transform(to: false)
                default: throw Abort(.internalServerError, reason: "Unexpected PokeAPI response: \(res.status)")
                }
            }
        }
    }

    /// Fetches a pokemen with the supplied name from the PokeAPI.
    public func fetchPokemon(named name: String) -> Future<Response> {
        let uri = URI("http://pokeapi.co/api/v2/pokemon/\(name)")
        return client.get(uri)
    }
}

/// Allow our custom PokeAPI wrapper to be used as a Vapor service.
extension PokeAPI: ServiceType {
    /// See `ServiceType.makeService(for:)`
    public static func makeService(for container: Container) throws -> PokeAPI {
        /// Use the container to create the Client and KeyedCache services our PokeAPI wrapper needs.
        return try PokeAPI(
            client: container.make(for: PokeAPI.self),
            cache: container.make(for: PokeAPI.self)
        )
    }
}
