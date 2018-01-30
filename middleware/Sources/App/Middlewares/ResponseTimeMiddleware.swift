import Foundation
import Vapor

/// Limits how often a route can be queried.
final class RateLimitMiddleware: Middleware {
    /// The minimum allowable time inteveral between successful requests.
    let minimumTimeInterval: TimeInterval

    /// Creates a new `RateLimitMiddleware`.
    init(minimumTimeInterval: TimeInterval) {
        self.minimumTimeInterval = minimumTimeInterval
    }

    /// See `Middleware.respond(to:)`
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        let rateCount = try request.make(RateCounter.self, for: RateLimitMiddleware.self)
        defer {
            /// always update the rate count
            rateCount.data[request.http.uri.path] = Date()
        }

        // if there is last query time, limit rate
        if let lastQuery = rateCount.data[request.http.uri.path] {
            let oneSecondAgo = Date().addingTimeInterval(minimumTimeInterval * -1)
            guard lastQuery <= oneSecondAgo else {
                // error if rate has been exceeded
                throw Abort(.enhanceYourCalm, reason: "Rate limit exceeded")
            }
        }

        return try next.respond(to: request)
    }
}

/// Holds rate limit data.
final class RateCounter: ServiceType {
    /// [Route Path: Last Query Date]
    var data: [String: Date]

    /// Creates a new `RateCounter`
    init() {
        self.data = [:]
    }

    /// See `ServiceType.makeService(for:)`
    static func makeService(for worker: Container) throws -> RateCounter {
        return RateCounter()
    }
}
