import Vapor

/// A simple wrapper around the "pokeapi.co" API.
public final class PokeAPI {
    /// The HTTP client powering this API.
    let client: Client

    /// Creates a new `PokeAPI` wrapper from the supplied client and cache.
    public init(client: Client) {
        self.client = client
    }

    /// Returns `true` if the supplied Pokemon name is real.
    ///
    /// - parameter client: Queries the "pokeapi.co" API to verify supplied names
    /// - parameter cache: Caches client results to minimize slow, external API calls
    public func verifyName(_ name: String, on worker: Worker) throws -> Future<Bool> {
        /// Query the PokeAPI.
        return self.fetchPokemon(named: name).map { res in
            switch res.http.status.code {
            case 200..<300:
                /// The API returned 2xx which means this is a real Pokemon name
                return true
            case 404:
                /// The API returned a 404 meaning this Pokemon name was not found.
                return false
            default:
                /// The API returned a 500. Only thing we can do is forward the error.
                throw Abort(.internalServerError, reason: "Unexpected PokeAPI response: \(res.http.status)")
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
        /// Use the container to create the Client services our PokeAPI wrapper needs.
        return try PokeAPI(client: container.make())
    }
}
