import XCTest
@testable import CalendarView

final class CalendarDateKeyTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
    }

    func testDateKeyCalculation() {
        let key = CalendarDateKey.makeKey(year: 2026, month: 9, day: 24)
        XCTAssertEqual(key, 20260924)
    }

    func testDateKeyDeconstruction() {
        let (y, m, d) = CalendarDateKey.deconstruct(key: 20260924)
        XCTAssertEqual(y, 2026)
        XCTAssertEqual(m, 9)
        XCTAssertEqual(d, 24)
    }

    func testDateKeyFromDateUsingCalendar() {
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 5
        components.hour = 14
        components.minute = 30
        let date = calendar.date(from: components)!

        let key = CalendarDateKey.key(for: date, using: calendar)
        XCTAssertEqual(key, 20260105)

        let (y, m, d) = CalendarDateKey.deconstruct(key: key)
        XCTAssertEqual(y, 2026)
        XCTAssertEqual(m, 1)
        XCTAssertEqual(d, 5)
    }

    func testLeapYearDateKey() {
        let leapKey = CalendarDateKey.makeKey(year: 2024, month: 2, day: 29)
        XCTAssertEqual(leapKey, 20240229)
        let (y, m, d) = CalendarDateKey.deconstruct(key: leapKey)
        XCTAssertEqual(y, 2024)
        XCTAssertEqual(m, 2)
        XCTAssertEqual(d, 29)
    }

    func testYearBoundaryDateKey() {
        let endOfYearKey = CalendarDateKey.makeKey(year: 2025, month: 12, day: 31)
        XCTAssertEqual(endOfYearKey, 20251231)
        let startOfYearKey = CalendarDateKey.makeKey(year: 2026, month: 1, day: 1)
        XCTAssertEqual(startOfYearKey, 20260101)
    }
}
