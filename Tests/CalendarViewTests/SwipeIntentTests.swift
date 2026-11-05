import XCTest
@testable import CalendarView

final class SwipeIntentTests: XCTestCase {
    func testHorizontalDragIsHorizontal() {
        XCTAssertTrue(SwipeIntent.isHorizontal(CGSize(width: 40, height: 5)))
        XCTAssertTrue(SwipeIntent.isHorizontal(CGSize(width: -40, height: -5)))
    }

    func testVerticalDragIsNotHorizontal() {
        XCTAssertFalse(SwipeIntent.isHorizontal(CGSize(width: 5, height: 40)))
        XCTAssertFalse(SwipeIntent.isHorizontal(CGSize(width: 0, height: -30)))
    }

    func testDiagonalDragIsNotHorizontal() {
        XCTAssertFalse(SwipeIntent.isHorizontal(CGSize(width: 30, height: 30)))
        // Just under the 1.2 bias.
        XCTAssertFalse(SwipeIntent.isHorizontal(CGSize(width: 35, height: 30)))
        XCTAssertTrue(SwipeIntent.isHorizontal(CGSize(width: 37, height: 30)))
    }

    func testZeroIsNotHorizontal() {
        XCTAssertFalse(SwipeIntent.isHorizontal(.zero))
    }
}
