import XCTest
@testable import CalendarView

// MARK: - CalendarViewMode Tests

final class CalendarViewModeTests: XCTestCase {
    // MARK: - component

    func testMonthComponent() {
        XCTAssertEqual(CalendarViewMode.month.component, .month)
    }

    func testWeekComponent() {
        XCTAssertEqual(CalendarViewMode.week.component, .weekOfMonth)
    }

    func testYearComponent() {
        XCTAssertEqual(CalendarViewMode.year(.full).component, .year)
        XCTAssertEqual(CalendarViewMode.year(.compact).component, .year)
    }

    func testSingleComponent() {
        XCTAssertEqual(CalendarViewMode.single.component, .day)
    }

    // MARK: - dateComponent

    func testMonthDateComponent() {
        XCTAssertEqual(
            CalendarViewMode.month.dateComponent,
            DateComponents(day: 1)
        )
    }

    func testWeekDateComponent() {
        XCTAssertEqual(
            CalendarViewMode.week.dateComponent,
            DateComponents(day: 1)
        )
    }

    func testSingleDateComponent() {
        XCTAssertEqual(
            CalendarViewMode.single.dateComponent,
            DateComponents(day: 1)
        )
    }

    func testYearDateComponent() {
        XCTAssertEqual(
            CalendarViewMode.year(.full).dateComponent,
            DateComponents(month: 1)
        )
    }

    // MARK: - enableScroll

    func testMonthScrollDisabled() {
        XCTAssertFalse(CalendarViewMode.month.enableScroll)
    }

    func testWeekScrollDisabled() {
        XCTAssertFalse(CalendarViewMode.week.enableScroll)
    }

    func testSingleScrollDisabled() {
        XCTAssertFalse(CalendarViewMode.single.enableScroll)
    }

    func testYearScrollEnabled() {
        XCTAssertTrue(CalendarViewMode.year(.full).enableScroll)
        XCTAssertTrue(CalendarViewMode.year(.compact).enableScroll)
    }

    // MARK: - Equatable / Hashable

    func testEquatable() {
        XCTAssertEqual(CalendarViewMode.month, CalendarViewMode.month)
        XCTAssertNotEqual(CalendarViewMode.month, CalendarViewMode.week)
        XCTAssertEqual(
            CalendarViewMode.year(.full),
            CalendarViewMode.year(.full)
        )
        XCTAssertNotEqual(
            CalendarViewMode.year(.full),
            CalendarViewMode.year(.compact)
        )
    }

    // MARK: - allCases

    func testAllCases() {
        let cases = CalendarViewMode.allCases
        XCTAssertEqual(cases.count, 5)
        XCTAssertTrue(cases.contains(.month))
        XCTAssertTrue(cases.contains(.week))
        XCTAssertTrue(cases.contains(.single))
        XCTAssertTrue(cases.contains(.year(.full)))
        XCTAssertTrue(cases.contains(.year(.compact)))
    }
}
