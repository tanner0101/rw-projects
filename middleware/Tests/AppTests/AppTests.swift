@testable import App
import Vapor
import XCTest

final class AppTests : XCTestCase {
    func testRateLimitMiddleware() throws {
        /// Create a test applicaiton
        let app = try Application.test()

        /// Create a test request
        let getFoo = HTTPRequest(method: .get, uri: URI("/foo"))
        let req = Request(http: getFoo, using: app)

        /// A basic responder that returns a blank response.
        let responder = BasicResponder { req in
            return Future(req.makeResponse())
        }

        /// Initialize rate limit middleware
        let rateLimiter = RateLimitMiddleware(minimumTimeInterval: 0.5)

        /// Send two requests, the second should trigger limit
        let res1 = try rateLimiter.respond(to: req, chainingTo: responder).requireCompleted()
        XCTAssertEqual(res1.http.status, .ok)
        do {
            _ = try rateLimiter.respond(to: req, chainingTo: responder).requireCompleted()
            XCTFail("Should have thrown")
        } catch let error as AbortError {
            XCTAssertEqual(error.status, .enhanceYourCalm)
        }

        /// Wait and send a third request, this should go through succesfully.
        sleep(1)
        let res3 = try rateLimiter.respond(to: req, chainingTo: responder).requireCompleted()
        XCTAssertEqual(res3.http.status, .ok)
    }

    static let allTests = [
        ("testRateLimitMiddleware", testRateLimitMiddleware),
    ]
}
