import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    let controller = PokemonController()
    router.get("pokemon", use: controller.index)
    router.post(Pokemon.self, at: "pokemon", use: controller.create)
}
