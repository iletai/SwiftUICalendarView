import XCTest
@testable import CalendarView

final class FastCalendarEngineTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 1 // Sunday
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return calendar.date(from: comps)!
    }

    func testFixed42CellsGeneration() {
        let date = makeDate(year: 2026, month: 9, day: 1)
        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: date,
            calendar: calendar,
            todayDate: date,
            selectedKeySet: [20260924],
            rangeBounds: (nil, nil)
        )

        XCTAssertEqual(matrix.days.count, 42, "Matrix must always produce 42 normalized cells")
        XCTAssertEqual(matrix.yearMonthKey, 202609)
        XCTAssertFalse(matrix.monthTitle.isEmpty)

        let day24 = matrix.days.first { $0.dateKey == 20260924 }
        XCTAssertNotNil(day24)
        XCTAssertTrue(day24!.isSelected)
        XCTAssertTrue(day24!.isCurrentMonth)
        XCTAssertEqual(day24!.dayNumber, 24)

        // Previous month days in grid (August 2026 has 31 days)
        // 2026-09-01 is a Tuesday, so leading days are Sunday Aug 30, Monday Aug 31
        let dayAug30 = matrix.days.first { $0.dateKey == 20260830 }
        XCTAssertNotNil(dayAug30)
        XCTAssertFalse(dayAug30!.isCurrentMonth)
        XCTAssertEqual(dayAug30!.dayNumber, 30)

        // Next month days in grid
        let dayOct = matrix.days.first { $0.dateKey == 20261001 }
        XCTAssertNotNil(dayOct)
        XCTAssertFalse(dayOct!.isCurrentMonth)
        XCTAssertEqual(dayOct!.dayNumber, 1)
    }

    func testTodayFlag() {
        let baseDate = makeDate(year: 2026, month: 9, day: 1)
        let today = makeDate(year: 2026, month: 9, day: 15)

        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: baseDate,
            calendar: calendar,
            todayDate: today
        )

        let todayDay = matrix.days.first { $0.dateKey == 20260915 }
        XCTAssertNotNil(todayDay)
        XCTAssertTrue(todayDay!.isToday)

        let otherDay = matrix.days.first { $0.dateKey == 20260916 }
        XCTAssertNotNil(otherDay)
        XCTAssertFalse(otherDay!.isToday)
    }

    func testRangeSelectionPositions() {
        let baseDate = makeDate(year: 2026, month: 9, day: 1)

        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: baseDate,
            calendar: calendar,
            rangeBounds: (startKey: 20260910, endKey: 20260920)
        )

        let startDay = matrix.days.first { $0.dateKey == 20260910 }
        XCTAssertEqual(startDay?.rangePosition, RangeSelectionPosition.rangeStart)

        let midDay = matrix.days.first { $0.dateKey == 20260915 }
        XCTAssertEqual(midDay?.rangePosition, RangeSelectionPosition.rangeMiddle)

        let endDay = matrix.days.first { $0.dateKey == 20260920 }
        XCTAssertEqual(endDay?.rangePosition, RangeSelectionPosition.rangeEnd)

        let beforeDay = matrix.days.first { $0.dateKey == 20260909 }
        XCTAssertEqual(beforeDay?.rangePosition, RangeSelectionPosition.none)

        let afterDay = matrix.days.first { $0.dateKey == 20260921 }
        XCTAssertEqual(afterDay?.rangePosition, RangeSelectionPosition.none)
    }

    func testSingleDayRangePosition() {
        let baseDate = makeDate(year: 2026, month: 9, day: 1)

        // Case 1: startKey == endKey
        let matrixSame = FastCalendarEngine.computeMonthMatrix(
            for: baseDate,
            calendar: calendar,
            rangeBounds: (startKey: 20260915, endKey: 20260915)
        )
        let daySame = matrixSame.days.first { $0.dateKey == 20260915 }
        XCTAssertEqual(daySame?.rangePosition, RangeSelectionPosition.singleDay)

        // Case 2: only startKey set
        let matrixStartOnly = FastCalendarEngine.computeMonthMatrix(
            for: baseDate,
            calendar: calendar,
            rangeBounds: (startKey: 20260915, endKey: nil)
        )
        let dayStartOnly = matrixStartOnly.days.first { $0.dateKey == 20260915 }
        XCTAssertEqual(dayStartOnly?.rangePosition, RangeSelectionPosition.singleDay)
    }

    func testDisabledDates() {
        let baseDate = makeDate(year: 2026, month: 9, day: 1)

        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: baseDate,
            calendar: calendar,
            disabledRule: { date in
                let key = CalendarDateKey.key(for: date, using: Calendar(identifier: .gregorian))
                return key == 20260910
            }
        )

        let day10 = matrix.days.first { $0.dateKey == 20260910 }
        XCTAssertNotNil(day10)
        XCTAssertTrue(day10!.isDisabled)
        XCTAssertFalse(day10!.isSelectable)

        let day11 = matrix.days.first { $0.dateKey == 20260911 }
        XCTAssertNotNil(day11)
        XCTAssertFalse(day11!.isDisabled)
        XCTAssertTrue(day11!.isSelectable)
    }

    func testEventsMap() {
        let baseDate = makeDate(year: 2026, month: 9, day: 1)
        let eventDate = makeDate(year: 2026, month: 9, day: 15)
        let event = CalendarEvent(id: "event-1", date: eventDate, title: "Meeting")
        let eventsMap: [Int: [CalendarEvent]] = [20260915: [event]]

        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: baseDate,
            calendar: calendar,
            eventsMap: eventsMap
        )

        let day15 = matrix.days.first { $0.dateKey == 20260915 }
        XCTAssertNotNil(day15)
        XCTAssertEqual(day15!.events.count, 1)
        XCTAssertEqual(day15!.events.first?.id, "event-1")
        XCTAssertEqual(day15!.events.first?.title, "Meeting")

        let day16 = matrix.days.first { $0.dateKey == 20260916 }
        XCTAssertNotNil(day16)
        XCTAssertTrue(day16!.events.isEmpty)
    }

    func testFirstWeekdayMonday() {
        var mondayCal = Calendar(identifier: .gregorian)
        mondayCal.timeZone = TimeZone(secondsFromGMT: 0)!
        mondayCal.firstWeekday = 2 // Monday

        let date = makeDate(year: 2026, month: 9, day: 1)
        // 2026-09-01 is Tuesday. With Monday first weekday, leadDays is 1 (Monday Aug 31).
        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: date,
            calendar: mondayCal
        )

        XCTAssertEqual(matrix.days.count, 42)
        XCTAssertEqual(matrix.days.first?.dateKey, 20260831)
    }
}
