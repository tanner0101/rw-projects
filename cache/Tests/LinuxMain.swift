#if os(Linux)

import XCTest
@testable import PokedexTests

XCTMain([
    // Vapor
    testCase(PokeAPITests.allTests),
])

#endif