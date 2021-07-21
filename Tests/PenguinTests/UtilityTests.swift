import XCTest
@testable import Penguin

class UtilityTests: XCTestCase {
    func testIDFactory() {
        XCTAssertEqual(IDFactory.nextID, 1)
        XCTAssertEqual(IDFactory.nextID, 2)
        XCTAssertEqual(IDFactory.nextID, 3)
    }
}
