import XCTest
@testable import CalendarView

final class FastCalendarEngineWeekTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 1 // Sunday
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    func testWeekMatrixProduces7Cells() {
        let date = makeDate(year: 2026, month: 9, day: 24)
        let days = FastCalendarEngine.computeWeekMatrix(for: date, calendar: calendar)
        XCTAssertEqual(days.count, 7, "Week matrix must always produce 7 cells")
    }

    func testWeekMatrixContainsInputDate() {
        let date = makeDate(year: 2026, month: 9, day: 24)
        let days = FastCalendarEngine.computeWeekMatrix(for: date, calendar: calendar)
        let keys = days.map { $0.dateKey }
        XCTAssertTrue(keys.contains(20260924), "Week must contain the input date")
    }

    func testWeekMatrixStartsOnFirstWeekday() {
        let date = makeDate(year: 2026, month: 9, day: 24)
        let days = FastCalendarEngine.computeWeekMatrix(for: date, calendar: calendar)
        XCTAssertEqual(days.first?.dateKey, 20260920, "Week should start on Sunday Sep 20")
        XCTAssertEqual(days.last?.dateKey, 20260926, "Week should end on Saturday Sep 26")
    }

    func testWeekMatrixMondayFirst() {
        calendar.firstWeekday = 2
        let date = makeDate(year: 2026, month: 9, day: 24)
        let days = FastCalendarEngine.computeWeekMatrix(for: date, calendar: calendar)
        XCTAssertEqual(days.first?.dateKey, 20260921)
        XCTAssertEqual(days.last?.dateKey, 20260927)
    }

    func testWeekMatrixSelectionState() {
        let date = makeDate(year: 2026, month: 9, day: 24)
        let days = FastCalendarEngine.computeWeekMatrix(for: date, calendar: calendar, selectedKeySet: [20260924])
        let thu = days.first { $0.dateKey == 20260924 }
        XCTAssertNotNil(thu)
        XCTAssertTrue(thu!.isSelected)
    }

    func testWeekMatrixCrossMonthBoundary() {
        let date = makeDate(year: 2026, month: 9, day: 30)
        let days = FastCalendarEngine.computeWeekMatrix(for: date, calendar: calendar)
        XCTAssertEqual(days.count, 7)
        let hasOctober = days.contains { $0.dateKey >= 20261001 }
        XCTAssertTrue(hasOctober, "Cross-month week should include October days")
    }
}
