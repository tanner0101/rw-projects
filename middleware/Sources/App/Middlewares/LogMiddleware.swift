import Foundation
import Vapor

/// Logs all requests that pass through it.
final class LogMiddleware: Middleware {
    /// Creates a new `LogMiddleware`.
    init() { }

    /// See `Middleware.respond(to:)`
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        log(request.http.method.string + " " + request.http.uri.path)
        return try next.respond(to: request)
    }

    /// Logs the string
    private func log(_ string: String) {
        // just print it for this example
        print("[\(Date())] \(string)")
    }
}
