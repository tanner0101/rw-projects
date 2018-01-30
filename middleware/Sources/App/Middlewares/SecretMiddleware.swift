import Vapor

/// Rejects requests that do not contain correct secret.
final class SecretMiddleware: Middleware {
    /// The secret.
    let secret: String

    /// Creates a new `SecretMiddleware`.
    init(secret: String) {
        self.secret = secret
    }

    /// See `Middleware.respond(to:)`
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        guard request.http.headers["X-Secret"] == secret else {
            throw Abort(.unauthorized)
        }

        return try next.respond(to: request)
    }
}

extension SecretMiddleware: ServiceType {
    /// See `ServiceType.makeService(for:)`
    static func makeService(for worker: Container) throws -> SecretMiddleware {
        let secret: String
        switch worker.environment {
        case .development: secret = "foo"
        default:
            guard let envSecret = Environment.get("SECRET") else {
                throw Abort(.internalServerError, reason: "No $SECRET set on environment. Use `export SECRET=<secret>`")
            }
            secret = envSecret
        }
        return SecretMiddleware(secret: secret)
    }
}
