import XCTest
@testable import OneWay

class UtilityTests: XCTestCase {
    func testIDFactory() {
        XCTAssertEqual(IDFactory.nextID, 1)
        XCTAssertEqual(IDFactory.nextID, 2)
        XCTAssertEqual(IDFactory.nextID, 3)
    }
}
