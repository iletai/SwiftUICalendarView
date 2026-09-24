import XCTest
@testable import CalendarView

final class CalendarEdgeCaseTests: XCTestCase {
    private var gregorianCalendar: Calendar!

    override func setUp() {
        super.setUp()
        gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = TimeZone(identifier: "UTC")!
        gregorianCalendar.firstWeekday = 1 // Sunday
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 0, calendar: Calendar? = nil) -> Date {
        let cal = calendar ?? gregorianCalendar!
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = hour
        return cal.date(from: comps)!
    }

    // MARK: - 1. Leap Year Handling

    func testLeapYear2024February29() {
        let feb2024 = makeDate(year: 2024, month: 2, day: 1)
        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: feb2024,
            calendar: gregorianCalendar
        )

        XCTAssertEqual(matrix.days.count, 42)
        let currentMonthDays = matrix.days.filter { $0.isCurrentMonth }
        XCTAssertEqual(currentMonthDays.count, 29, "February 2024 must have 29 days")

        let feb29 = matrix.days.first { $0.dateKey == 20240229 }
        XCTAssertNotNil(feb29, "February 29, 2024 must exist in matrix")
        XCTAssertTrue(feb29!.isCurrentMonth)
        XCTAssertEqual(feb29!.dayNumber, 29)

        // Day 1 of March should appear as non-current month
        let mar1 = matrix.days.first { $0.dateKey == 20240301 }
        XCTAssertNotNil(mar1)
        XCTAssertFalse(mar1!.isCurrentMonth)
    }

    func testLeapYear2028February29() {
        let feb2028 = makeDate(year: 2028, month: 2, day: 15)
        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: feb2028,
            calendar: gregorianCalendar
        )

        XCTAssertEqual(matrix.days.count, 42)
        let currentMonthDays = matrix.days.filter { $0.isCurrentMonth }
        XCTAssertEqual(currentMonthDays.count, 29, "February 2028 must have 29 days")

        let feb29 = matrix.days.first { $0.dateKey == 20280229 }
        XCTAssertNotNil(feb29)
        XCTAssertTrue(feb29!.isCurrentMonth)
        XCTAssertEqual(feb29!.dayNumber, 29)
    }

    func testNonLeapYear2023February28() {
        let feb2023 = makeDate(year: 2023, month: 2, day: 1)
        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: feb2023,
            calendar: gregorianCalendar
        )

        XCTAssertEqual(matrix.days.count, 42)
        let currentMonthDays = matrix.days.filter { $0.isCurrentMonth }
        XCTAssertEqual(currentMonthDays.count, 28, "February 2023 must have 28 days")

        let feb28 = matrix.days.first { $0.dateKey == 20230228 }
        XCTAssertNotNil(feb28)
        XCTAssertTrue(feb28!.isCurrentMonth)
        XCTAssertEqual(feb28!.dayNumber, 28)

        // There should be NO Feb 29 in 2023
        let feb29 = matrix.days.first { $0.dateKey == 20230229 }
        XCTAssertNil(feb29, "February 2023 must not contain February 29")

        // First following day must be March 1
        let mar1 = matrix.days.first { $0.dateKey == 20230301 }
        XCTAssertNotNil(mar1)
        XCTAssertFalse(mar1!.isCurrentMonth)
    }

    func testNonLeapYear2025February28() {
        let feb2025 = makeDate(year: 2025, month: 2, day: 10)
        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: feb2025,
            calendar: gregorianCalendar
        )

        XCTAssertEqual(matrix.days.count, 42)
        let currentMonthDays = matrix.days.filter { $0.isCurrentMonth }
        XCTAssertEqual(currentMonthDays.count, 28, "February 2025 must have 28 days")

        let feb28 = matrix.days.first { $0.dateKey == 20250228 }
        XCTAssertNotNil(feb28)
        XCTAssertTrue(feb28!.isCurrentMonth)
        XCTAssertEqual(feb28!.dayNumber, 28)

        let feb29 = matrix.days.first { $0.dateKey == 20250229 }
        XCTAssertNil(feb29)
    }

    // MARK: - 2. Daylight Saving Time (DST) Shifts

    func testUSSpringForwardDSTTransition() {
        // US Spring Forward: March 10, 2024 in America/New_York (clocks forward 1 hour at 2:00 AM)
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/New_York")!
        cal.firstWeekday = 1

        let march2024 = makeDate(year: 2024, month: 3, day: 10, hour: 12, calendar: cal)
        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: march2024,
            calendar: cal
        )

        XCTAssertEqual(matrix.days.count, 42, "DST transition month must produce exact 42 cells")
        let currentMonthDays = matrix.days.filter { $0.isCurrentMonth }
        XCTAssertEqual(currentMonthDays.count, 31, "March has 31 days")

        // Verify March 10 cell specifically
        let day10 = matrix.days.first { $0.dateKey == 20240310 }
        XCTAssertNotNil(day10, "March 10 cell must exist")
        XCTAssertEqual(day10?.dayNumber, 10)
        XCTAssertTrue(day10?.isCurrentMonth == true)

        // Verify consecutive progression of days without skipping
        for i in 1...31 {
            let key = CalendarDateKey.makeKey(year: 2024, month: 3, day: i)
            let cell = matrix.days.first { $0.dateKey == key }
            XCTAssertNotNil(cell, "Day \(i) must exist in March 2024 DST matrix")
            XCTAssertEqual(cell?.dayNumber, i)
        }

        // Verify midnight normalization: every cell's date matches startOfDay in local timezone
        for cell in matrix.days {
            let startOfDay = cal.startOfDay(for: cell.date)
            XCTAssertEqual(cell.date, startOfDay, "Cell date must be normalized to start of day (midnight)")
        }
    }

    func testEUFallBackDSTTransition() {
        // EU Fall Back: October 27, 2024 in Europe/Paris (clocks backward 1 hour at 3:00 AM)
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Europe/Paris")!
        cal.firstWeekday = 1

        let oct2024 = makeDate(year: 2024, month: 10, day: 27, hour: 12, calendar: cal)
        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: oct2024,
            calendar: cal
        )

        XCTAssertEqual(matrix.days.count, 42, "DST transition month must produce exact 42 cells")
        let currentMonthDays = matrix.days.filter { $0.isCurrentMonth }
        XCTAssertEqual(currentMonthDays.count, 31, "October has 31 days")

        // Verify October 27 cell specifically
        let day27 = matrix.days.first { $0.dateKey == 20241027 }
        XCTAssertNotNil(day27, "October 27 cell must exist")
        XCTAssertEqual(day27?.dayNumber, 27)
        XCTAssertTrue(day27?.isCurrentMonth == true)

        // Verify consecutive progression of days without duplicating
        for i in 1...31 {
            let key = CalendarDateKey.makeKey(year: 2024, month: 10, day: i)
            let matchingCells = matrix.days.filter { $0.dateKey == key }
            XCTAssertEqual(matchingCells.count, 1, "Day \(i) must appear exactly once in October 2024 DST matrix")
        }

        // Verify midnight normalization
        for cell in matrix.days {
            let startOfDay = cal.startOfDay(for: cell.date)
            XCTAssertEqual(cell.date, startOfDay, "Cell date must be normalized to start of day (midnight)")
        }
    }

    // MARK: - 3. Non-Gregorian Calendars

    func testBuddhistCalendarYear2567BE() {
        var cal = Calendar(identifier: .buddhist)
        cal.locale = Locale(identifier: "th_TH")
        cal.timeZone = TimeZone(identifier: "Asia/Bangkok")!

        // Year 2024 Gregorian is 2567 in Buddhist Era (BE)
        var comps = DateComponents()
        comps.year = 2567
        comps.month = 5
        comps.day = 15
        guard let date = cal.date(from: comps) else {
            XCTFail("Failed to create date for Buddhist calendar")
            return
        }

        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: date,
            calendar: cal
        )

        XCTAssertEqual(matrix.days.count, 42)
        XCTAssertEqual(matrix.yearMonthKey, 256705)
        XCTAssertFalse(matrix.monthTitle.isEmpty)

        let day15 = matrix.days.first { $0.dateKey == 25670515 }
        XCTAssertNotNil(day15)
        XCTAssertEqual(day15?.dayNumber, 15)
        XCTAssertTrue(day15?.isCurrentMonth == true)
    }

    func testJapaneseCalendarReiwaEra() {
        var cal = Calendar(identifier: .japanese)
        cal.locale = Locale(identifier: "ja_JP")
        cal.timeZone = TimeZone(identifier: "Asia/Tokyo")!

        // 2024 Gregorian is Reiwa 6
        var comps = DateComponents()
        comps.year = 6
        comps.month = 4
        comps.day = 1
        guard let date = cal.date(from: comps) else {
            XCTFail("Failed to create date for Japanese calendar")
            return
        }

        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: date,
            calendar: cal
        )

        XCTAssertEqual(matrix.days.count, 42)
        XCTAssertEqual(matrix.yearMonthKey, 604)
        XCTAssertFalse(matrix.monthTitle.isEmpty)

        let day1 = matrix.days.first { $0.dateKey == 60401 }
        XCTAssertNotNil(day1)
        XCTAssertEqual(day1?.dayNumber, 1)
        XCTAssertTrue(day1?.isCurrentMonth == true)
    }

    func testIslamicCalendarHijri() {
        var cal = Calendar(identifier: .islamicUmmAlQura)
        cal.locale = Locale(identifier: "ar_SA")
        cal.timeZone = TimeZone(identifier: "Asia/Riyadh")!

        // Ramadan 1445 AH (around March 2024)
        var comps = DateComponents()
        comps.year = 1445
        comps.month = 9
        comps.day = 1
        guard let date = cal.date(from: comps) else {
            XCTFail("Failed to create date for Islamic calendar")
            return
        }

        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: date,
            calendar: cal
        )

        XCTAssertEqual(matrix.days.count, 42)
        XCTAssertEqual(matrix.yearMonthKey, 144509)
        XCTAssertFalse(matrix.monthTitle.isEmpty)

        let currentMonthDays = matrix.days.filter { $0.isCurrentMonth }
        // Islamic lunar months have 29 or 30 days
        XCTAssertTrue(currentMonthDays.count == 29 || currentMonthDays.count == 30)

        let day1 = matrix.days.first { $0.dateKey == 14450901 }
        XCTAssertNotNil(day1)
        XCTAssertEqual(day1?.dayNumber, 1)
        XCTAssertTrue(day1?.isCurrentMonth == true)
    }

    func testHebrewCalendar() {
        var cal = Calendar(identifier: .hebrew)
        cal.locale = Locale(identifier: "he_IL")
        cal.timeZone = TimeZone(identifier: "Asia/Jerusalem")!

        // Year 5784 Hebrew
        var comps = DateComponents()
        comps.year = 5784
        comps.month = 7 // Tishrei / Nisan depending on reckoning
        comps.day = 1
        guard let date = cal.date(from: comps) else {
            XCTFail("Failed to create date for Hebrew calendar")
            return
        }

        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: date,
            calendar: cal
        )

        XCTAssertEqual(matrix.days.count, 42)
        XCTAssertEqual(matrix.yearMonthKey, 578407)
        XCTAssertFalse(matrix.monthTitle.isEmpty)

        let currentMonthDays = matrix.days.filter { $0.isCurrentMonth }
        XCTAssertTrue(currentMonthDays.count >= 29 && currentMonthDays.count <= 30)

        let day1 = matrix.days.first { $0.dateKey == 57840701 }
        XCTAssertNotNil(day1)
        XCTAssertEqual(day1?.dayNumber, 1)
        XCTAssertTrue(day1?.isCurrentMonth == true)
    }

    // MARK: - 4. Year Boundary Transitions

    func testYearBoundaryDecemberToJanuaryContinuity() {
        let dec2024 = makeDate(year: 2024, month: 12, day: 31)
        let jan2025 = makeDate(year: 2025, month: 1, day: 1)

        let decMatrix = FastCalendarEngine.computeMonthMatrix(
            for: dec2024,
            calendar: gregorianCalendar
        )
        let janMatrix = FastCalendarEngine.computeMonthMatrix(
            for: jan2025,
            calendar: gregorianCalendar
        )

        XCTAssertEqual(decMatrix.days.count, 42)
        XCTAssertEqual(janMatrix.days.count, 42)

        // Dec matrix: Dec 31 is in current month, Jan 1 next year is in grid as non-current month
        let dec31InDec = decMatrix.days.first { $0.dateKey == 20241231 }
        XCTAssertNotNil(dec31InDec)
        XCTAssertTrue(dec31InDec!.isCurrentMonth)
        XCTAssertEqual(dec31InDec!.dayNumber, 31)

        let jan1InDec = decMatrix.days.first { $0.dateKey == 20250101 }
        XCTAssertNotNil(jan1InDec)
        XCTAssertFalse(jan1InDec!.isCurrentMonth)
        XCTAssertEqual(jan1InDec!.dayNumber, 1)

        // Jan matrix: Dec 31 previous year is in grid as non-current month, Jan 1 is in current month
        let dec31InJan = janMatrix.days.first { $0.dateKey == 20241231 }
        XCTAssertNotNil(dec31InJan)
        XCTAssertFalse(dec31InJan!.isCurrentMonth)
        XCTAssertEqual(dec31InJan!.dayNumber, 31)

        let jan1InJan = janMatrix.days.first { $0.dateKey == 20250101 }
        XCTAssertNotNil(jan1InJan)
        XCTAssertTrue(jan1InJan!.isCurrentMonth)
        XCTAssertEqual(jan1InJan!.dayNumber, 1)

        // Check strictly increasing dateKeys within both grids
        for i in 0..<decMatrix.days.count - 1 {
            XCTAssertLessThan(decMatrix.days[i].dateKey, decMatrix.days[i + 1].dateKey)
        }
        for i in 0..<janMatrix.days.count - 1 {
            XCTAssertLessThan(janMatrix.days[i].dateKey, janMatrix.days[i + 1].dateKey)
        }
    }

    func testRangeSelectionAcrossYearBoundary() {
        let decDate = makeDate(year: 2024, month: 12, day: 15)
        let startKey = 20241228
        let endKey = 20250105

        let decMatrix = FastCalendarEngine.computeMonthMatrix(
            for: decDate,
            calendar: gregorianCalendar,
            rangeBounds: (startKey, endKey)
        )

        let startCell = decMatrix.days.first { $0.dateKey == 20241228 }
        XCTAssertEqual(startCell?.rangePosition, .rangeStart)

        let midDecCell = decMatrix.days.first { $0.dateKey == 20241230 }
        XCTAssertEqual(midDecCell?.rangePosition, .rangeMiddle)

        let midJanCell = decMatrix.days.first { $0.dateKey == 20250102 }
        XCTAssertEqual(midJanCell?.rangePosition, .rangeMiddle)

        let endCell = decMatrix.days.first { $0.dateKey == 20250105 }
        XCTAssertEqual(endCell?.rangePosition, .rangeEnd)
    }

    // MARK: - 5. Matrix Computation Performance

    func testMatrixComputationPerformance120MonthsUnderProMotionBudget() {
        // Benchmark computing 120 consecutive months (10 years) under ProMotion 120fps frame budget (<10ms)
        let startDate = makeDate(year: 2020, month: 1, day: 1)
        let todayDate = makeDate(year: 2026, month: 9, day: 24)
        let selectedKeys: Set<Int> = [20240229, 20260924]
        let rangeBounds = (startKey: Optional(20241225), endKey: Optional(20250105))

        // Pre-generate month dates to measure pure engine computation
        var monthDates: [Date] = []
        monthDates.reserveCapacity(120)
        for offset in 0..<120 {
            if let date = gregorianCalendar.date(byAdding: .month, value: offset, to: startDate) {
                monthDates.append(date)
            }
        }
        XCTAssertEqual(monthDates.count, 120)

        // Warm up
        for date in monthDates.prefix(12) {
            _ = FastCalendarEngine.computeMonthMatrix(
                for: date,
                calendar: gregorianCalendar,
                todayDate: todayDate,
                selectedKeySet: selectedKeys,
                rangeBounds: rangeBounds
            )
        }

        let startTime = CFAbsoluteTimeGetCurrent()
        var totalCells = 0
        for date in monthDates {
            let matrix = FastCalendarEngine.computeMonthMatrix(
                for: date,
                calendar: gregorianCalendar,
                todayDate: todayDate,
                selectedKeySet: selectedKeys,
                rangeBounds: rangeBounds
            )
            totalCells += matrix.days.count
        }
        let duration = CFAbsoluteTimeGetCurrent() - startTime

        XCTAssertEqual(totalCells, 120 * 42, "Must produce exactly 42 cells per month (5040 cells total)")

        // ProMotion 120fps budget is 8.33ms per frame. A single month computation must be orders of magnitude below frame budget.
        let avgPerMonth = duration / Double(monthDates.count)
        XCTAssertLessThan(avgPerMonth, 0.00833, "Single month matrix average took \(avgPerMonth * 1000)ms, must be <8.33ms")

        #if DEBUG
        // In debug build (-Onone), un-inlined bridge calls have overhead; budget is <35ms for 120 months
        XCTAssertLessThan(duration, 0.035, "120 months matrix computation took \(duration * 1000)ms in debug mode")
        #else
        // In release build (-O), 120 months batch computation must complete in <10ms
        XCTAssertLessThan(duration, 0.010, "120 months matrix computation took \(duration * 1000)ms, must be <10ms for ProMotion 120fps budget")
        #endif
    }
}
