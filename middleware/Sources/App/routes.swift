import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router, _ env: Environment) throws {
    // register todo controller routes
    let todoController = TodoController()

    let rateLimiter = RateLimitMiddleware(minimumTimeInterval: 1)
    router.grouped(rateLimiter).get("todos", use: todoController.index)

    // FIXME: https://github.com/vapor/vapor/issues/1469
    router.group(SecretMiddleware(secret: "foo")) { secretGroup in
        // routes registered inside this closure will use `SecretMiddleware`
        secretGroup.post("todos", use: todoController.create)
        secretGroup.delete("todos", Todo.parameter, use: todoController.delete)
    }
}
