import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let controller = PokemonController()
    router.get("pokemon", use: controller.index)
    router.post(Pokemon.self, at: "pokemon", use: controller.create)
}
