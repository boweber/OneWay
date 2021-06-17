import XCTest
@testable import Penguin

final class PenguinTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Penguin().text, "Hello, World!")
    }
}
