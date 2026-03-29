import XCTest
@testable import CalendarView

// MARK: - Date Extension Tests

final class DateExtensionTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.firstWeekday = 1 // Sunday
    }

    private func makeDate(
        year: Int, month: Int, day: Int,
        hour: Int = 0, minute: Int = 0, second: Int = 0
    ) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return calendar.date(from: components)!
    }

    // MARK: - startOfYear / endOfYear

    func testStartOfYear() {
        let date = makeDate(year: 2024, month: 6, day: 15, hour: 14)
        let result = date.startOfYear(using: calendar)
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: result)
        XCTAssertEqual(comps.year, 2024)
        XCTAssertEqual(comps.month, 1)
        XCTAssertEqual(comps.day, 1)
        XCTAssertEqual(comps.hour, 0)
    }

    func testEndOfYear() {
        let date = makeDate(year: 2024, month: 3, day: 10)
        let result = date.endOfYear(using: calendar)
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: result)
        XCTAssertEqual(comps.year, 2024)
        XCTAssertEqual(comps.month, 12)
        XCTAssertEqual(comps.day, 31)
        XCTAssertEqual(comps.hour, 23)
        XCTAssertEqual(comps.minute, 59)
        XCTAssertEqual(comps.second, 59)
    }

    func testStartOfYearOnJanFirst() {
        let date = makeDate(year: 2023, month: 1, day: 1)
        let result = date.startOfYear(using: calendar)
        XCTAssertEqual(
            calendar.dateComponents([.year, .month, .day], from: result),
            calendar.dateComponents([.year, .month, .day], from: date)
        )
    }

    func testEndOfYearOnDecThirtyFirst() {
        let date = makeDate(year: 2023, month: 12, day: 31)
        let result = date.endOfYear(using: calendar)
        let comps = calendar.dateComponents([.year, .month, .day], from: result)
        XCTAssertEqual(comps.year, 2023)
        XCTAssertEqual(comps.month, 12)
        XCTAssertEqual(comps.day, 31)
    }

    // MARK: - startOfMonth / endOfMonth

    func testStartOfMonth() {
        let date = makeDate(year: 2024, month: 7, day: 20, hour: 10)
        let result = date.startOfMonth(using: calendar)
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: result)
        XCTAssertEqual(comps.year, 2024)
        XCTAssertEqual(comps.month, 7)
        XCTAssertEqual(comps.day, 1)
        XCTAssertEqual(comps.hour, 0)
    }

    func testEndOfMonth_February_LeapYear() {
        let date = makeDate(year: 2024, month: 2, day: 10)
        let result = date.endOfMonth(using: calendar)
        let comps = calendar.dateComponents([.year, .month, .day], from: result)
        XCTAssertEqual(comps.month, 2)
        XCTAssertEqual(comps.day, 29) // 2024 is a leap year
    }

    func testEndOfMonth_February_NonLeapYear() {
        let date = makeDate(year: 2023, month: 2, day: 5)
        let result = date.endOfMonth(using: calendar)
        let comps = calendar.dateComponents([.day], from: result)
        XCTAssertEqual(comps.day, 28)
    }

    func testEndOfMonth_ThirtyDayMonth() {
        let date = makeDate(year: 2024, month: 4, day: 15)
        let result = date.endOfMonth(using: calendar)
        let comps = calendar.dateComponents([.day], from: result)
        XCTAssertEqual(comps.day, 30)
    }

    func testEndOfMonth_ThirtyOneDayMonth() {
        let date = makeDate(year: 2024, month: 1, day: 5)
        let result = date.endOfMonth(using: calendar)
        let comps = calendar.dateComponents([.day], from: result)
        XCTAssertEqual(comps.day, 31)
    }

    // MARK: - startOfWeek / endOfWeek

    func testStartOfWeek_SundayFirstDay() {
        // 2024-07-17 is Wednesday
        let date = makeDate(year: 2024, month: 7, day: 17)
        let result = date.startOfWeek(using: calendar)
        let comps = calendar.dateComponents([.year, .month, .day], from: result)
        XCTAssertEqual(comps.day, 14) // Sunday July 14
        XCTAssertEqual(calendar.component(.weekday, from: result), 1) // Sunday
    }

    func testEndOfWeek_SundayFirstDay() {
        let date = makeDate(year: 2024, month: 7, day: 17)
        let result = date.endOfWeek(using: calendar)
        let comps = calendar.dateComponents([.year, .month, .day], from: result)
        XCTAssertEqual(comps.day, 20) // Saturday July 20
        XCTAssertEqual(calendar.component(.weekday, from: result), 7) // Saturday
    }

    func testStartOfWeek_MondayFirstDay() {
        var mondayCal = calendar!
        mondayCal.firstWeekday = 2 // Monday
        let date = makeDate(year: 2024, month: 7, day: 17) // Wednesday
        let result = date.startOfWeek(using: mondayCal)
        let comps = mondayCal.dateComponents([.day], from: result)
        XCTAssertEqual(comps.day, 15) // Monday July 15
    }

    func testStartOfWeek_WhenDateIsSunday() {
        let date = makeDate(year: 2024, month: 7, day: 14) // Sunday
        let result = date.startOfWeek(using: calendar)
        let comps = calendar.dateComponents([.day], from: result)
        XCTAssertEqual(comps.day, 14) // Should be itself
    }

    // MARK: - startOf / endOf (generic component)

    func testStartOfDay() {
        let date = makeDate(year: 2024, month: 5, day: 10, hour: 15, minute: 30)
        let result = date.startOf(.day, using: calendar)
        let comps = calendar.dateComponents([.hour, .minute, .second], from: result)
        XCTAssertEqual(comps.hour, 0)
        XCTAssertEqual(comps.minute, 0)
        XCTAssertEqual(comps.second, 0)
    }

    func testEndOfDay() {
        let date = makeDate(year: 2024, month: 5, day: 10, hour: 8)
        let result = date.endOf(.day, using: calendar)
        let comps = calendar.dateComponents([.hour, .minute, .second], from: result)
        XCTAssertEqual(comps.hour, 23)
        XCTAssertEqual(comps.minute, 59)
        XCTAssertEqual(comps.second, 59)
    }

    func testStartOfMonthViaGeneric() {
        let date = makeDate(year: 2024, month: 8, day: 20)
        let specific = date.startOfMonth(using: calendar)
        let generic = date.startOf(.month, using: calendar)
        XCTAssertEqual(specific, generic)
    }

    func testEndOfYearViaGeneric() {
        let date = makeDate(year: 2024, month: 3, day: 10)
        let specific = date.endOfYear(using: calendar)
        let generic = date.endOf(.year, using: calendar)
        XCTAssertEqual(specific, generic)
    }

    // MARK: - isSameMonth / isSameWeek

    func testIsSameMonth_True() {
        let date1 = makeDate(year: 2024, month: 5, day: 1)
        let date2 = makeDate(year: 2024, month: 5, day: 31)
        XCTAssertTrue(date1.isSameMonth(as: date2, using: calendar))
    }

    func testIsSameMonth_False_DifferentMonth() {
        let date1 = makeDate(year: 2024, month: 5, day: 31)
        let date2 = makeDate(year: 2024, month: 6, day: 1)
        XCTAssertFalse(date1.isSameMonth(as: date2, using: calendar))
    }

    func testIsSameMonth_False_DifferentYear() {
        let date1 = makeDate(year: 2023, month: 5, day: 15)
        let date2 = makeDate(year: 2024, month: 5, day: 15)
        XCTAssertFalse(date1.isSameMonth(as: date2, using: calendar))
    }

    func testIsSameWeek_True() {
        // July 14 (Sun) and July 20 (Sat) are same week with Sunday start
        let date1 = makeDate(year: 2024, month: 7, day: 14)
        let date2 = makeDate(year: 2024, month: 7, day: 20)
        XCTAssertTrue(date1.isSameWeek(as: date2, using: calendar))
    }

    func testIsSameWeek_False() {
        let date1 = makeDate(year: 2024, month: 7, day: 13) // Saturday
        let date2 = makeDate(year: 2024, month: 7, day: 14) // Sunday (new week)
        XCTAssertFalse(date1.isSameWeek(as: date2, using: calendar))
    }

    // MARK: - formatted

    func testFormattedYearMonth() {
        let date = makeDate(year: 2024, month: 3, day: 15)
        let result = date.formatted(as: "yyyy-MM", locale: Locale(identifier: "en_US"))
        XCTAssertEqual(result, "2024-03")
    }

    func testFormattedDayOnly() {
        let date = makeDate(year: 2024, month: 12, day: 5)
        let result = date.formatted(as: "d")
        XCTAssertEqual(result, "5")
    }

    func testFormattedWithLocale() {
        let date = makeDate(year: 2024, month: 1, day: 15)
        let result = date.formatted(as: "MMMM", locale: Locale(identifier: "en_US"))
        XCTAssertEqual(result, "January")
    }

    // MARK: - weekDayName / weekDayShortName / dayName

    func testWeekDayNameAndShortName() {
        // 2024-01-01 is a Monday
        let date = makeDate(year: 2024, month: 1, day: 1)
        // These use the static DateFormatters which may use current locale,
        // so we just verify they return non-empty strings
        XCTAssertFalse(date.weekDayName.isEmpty)
        XCTAssertFalse(date.weekDayShortName.isEmpty)
    }

    func testDayName() {
        let date = makeDate(year: 2024, month: 7, day: 25)
        let result = date.dayName
        XCTAssertEqual(result, "25")
    }
}

// MARK: - Calendar Extension Tests

final class CalendarExtensionTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    func testGregorianCalendar() {
        let cal = Calendar.gregorian
        XCTAssertEqual(cal.identifier, .gregorian)
    }

    func testEnumerateDates_DayIncrement() {
        let start = makeDate(year: 2024, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 1, day: 5)
        let increment = DateComponents(day: 1)
        let dates = calendar.enumerateDates(from: start, to: end, increment: increment)
        XCTAssertEqual(dates.count, 5)
        for (i, date) in dates.enumerated() {
            XCTAssertEqual(calendar.component(.day, from: date), i + 1)
        }
    }

    func testEnumerateDates_MonthIncrement() {
        let start = makeDate(year: 2024, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 6, day: 1)
        let increment = DateComponents(month: 1)
        let dates = calendar.enumerateDates(from: start, to: end, increment: increment)
        XCTAssertEqual(dates.count, 6) // Jan through Jun
        for (i, date) in dates.enumerated() {
            XCTAssertEqual(calendar.component(.month, from: date), i + 1)
        }
    }

    func testEnumerateDates_WeekIncrement() {
        let start = makeDate(year: 2024, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 1, day: 29)
        let increment = DateComponents(day: 7)
        let dates = calendar.enumerateDates(from: start, to: end, increment: increment)
        // Jan 1, 8, 15, 22, 29
        XCTAssertEqual(dates.count, 5)
    }

    func testEnumerateDates_SingleDate() {
        let date = makeDate(year: 2024, month: 5, day: 10)
        let increment = DateComponents(day: 1)
        let dates = calendar.enumerateDates(from: date, to: date, increment: increment)
        XCTAssertEqual(dates.count, 1)
        XCTAssertEqual(dates.first, date)
    }

    func testEnumerateDates_StartAfterEnd_ReturnsEmpty() {
        let start = makeDate(year: 2024, month: 5, day: 10)
        let end = makeDate(year: 2024, month: 5, day: 5)
        let increment = DateComponents(day: 1)
        let dates = calendar.enumerateDates(from: start, to: end, increment: increment)
        XCTAssertTrue(dates.isEmpty)
    }

    func testEnumerateDates_EndInclusivity() {
        let start = makeDate(year: 2024, month: 3, day: 1)
        let end = makeDate(year: 2024, month: 3, day: 3)
        let increment = DateComponents(day: 1)
        let dates = calendar.enumerateDates(from: start, to: end, increment: increment)
        XCTAssertEqual(dates.count, 3)
        XCTAssertEqual(dates.last, end)
    }

    func testEnumerateDates_YearIncrement() {
        let start = makeDate(year: 2020, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 1, day: 1)
        let increment = DateComponents(year: 1)
        let dates = calendar.enumerateDates(from: start, to: end, increment: increment)
        XCTAssertEqual(dates.count, 5) // 2020..2024
    }
}

// MARK: - CalendarViewOption Tests

final class CalendarViewOptionTests: XCTestCase {
    func testDefaultOption_ShowFlags() {
        let option = CalendarViewOption.defaultOption
        XCTAssertTrue(option.isShowHeader)
        XCTAssertTrue(option.isShowDateOut)
        XCTAssertTrue(option.isShowDivider)
        XCTAssertTrue(option.isHighlightToday)
    }

    func testDefaultOption_Calendar() {
        let option = CalendarViewOption.defaultOption
        XCTAssertEqual(option.calendar.identifier, .gregorian)
    }

    func testDefaultOption_Spacing() {
        let option = CalendarViewOption.defaultOption
        XCTAssertEqual(option.spacingBetweenDay, 8.0)
        XCTAssertEqual(option.spaceBetweenColumns, 8.0)
    }

    func testDefaultOption_ViewMode() {
        let option = CalendarViewOption.defaultOption
        XCTAssertEqual(option.viewMode, .year(.full))
    }

    func testDefaultOption_BackgroundHidden() {
        let option = CalendarViewOption.defaultOption
        if case .hidden = option.backgroundStatus {
            // pass
        } else {
            XCTFail("Expected .hidden background status")
        }
    }

    func testDefaultOption_Locale() {
        let option = CalendarViewOption.defaultOption
        XCTAssertEqual(option.locale.identifier, "vi")
    }

    func testDefaultOption_CompactMonthCount() {
        let option = CalendarViewOption.defaultOption
        XCTAssertEqual(option.compactMonthCount, 3)
    }
}

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
        XCTAssertEqual(CalendarViewMode.month.dateComponent, DateComponents(day: 1))
    }

    func testWeekDateComponent() {
        XCTAssertEqual(CalendarViewMode.week.dateComponent, DateComponents(day: 1))
    }

    func testSingleDateComponent() {
        XCTAssertEqual(CalendarViewMode.single.dateComponent, DateComponents(day: 1))
    }

    func testYearDateComponent() {
        XCTAssertEqual(CalendarViewMode.year(.full).dateComponent, DateComponents(month: 1))
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
        XCTAssertEqual(CalendarViewMode.year(.full), CalendarViewMode.year(.full))
        XCTAssertNotEqual(CalendarViewMode.year(.full), CalendarViewMode.year(.compact))
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

// MARK: - CalendarWeekday Tests

final class CalendarWeekdayTests: XCTestCase {
    // MARK: - Raw Values

    func testRawValues() {
        XCTAssertEqual(CalendarWeekday.sunday.rawValue, 1)
        XCTAssertEqual(CalendarWeekday.monday.rawValue, 2)
        XCTAssertEqual(CalendarWeekday.tuesday.rawValue, 3)
        XCTAssertEqual(CalendarWeekday.wednesday.rawValue, 4)
        XCTAssertEqual(CalendarWeekday.thursday.rawValue, 5)
        XCTAssertEqual(CalendarWeekday.friday.rawValue, 6)
        XCTAssertEqual(CalendarWeekday.saturday.rawValue, 7)
    }

    // MARK: - Descriptions

    func testDescriptions() {
        XCTAssertEqual(CalendarWeekday.sunday.description, "sunday")
        XCTAssertEqual(CalendarWeekday.monday.description, "monday")
        XCTAssertEqual(CalendarWeekday.tuesday.description, "tuesday")
        XCTAssertEqual(CalendarWeekday.wednesday.description, "wednesday")
        XCTAssertEqual(CalendarWeekday.thursday.description, "thursday")
        XCTAssertEqual(CalendarWeekday.friday.description, "friday")
        XCTAssertEqual(CalendarWeekday.saturday.description, "saturday")
    }

    // MARK: - Init from RawValue

    func testInitFromRawValue() {
        XCTAssertEqual(CalendarWeekday(rawValue: 1), .sunday)
        XCTAssertEqual(CalendarWeekday(rawValue: 4), .wednesday)
        XCTAssertEqual(CalendarWeekday(rawValue: 7), .saturday)
        XCTAssertNil(CalendarWeekday(rawValue: 0))
        XCTAssertNil(CalendarWeekday(rawValue: 8))
    }

    // MARK: - Alignment with Calendar weekday values

    func testRawValuesMatchCalendarWeekdays() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        // 2024-01-07 is a Sunday
        let sunday = calendar.date(from: DateComponents(year: 2024, month: 1, day: 7))!
        XCTAssertEqual(calendar.component(.weekday, from: sunday), CalendarWeekday.sunday.rawValue)
        // 2024-01-08 is a Monday
        let monday = calendar.date(from: DateComponents(year: 2024, month: 1, day: 8))!
        XCTAssertEqual(calendar.component(.weekday, from: monday), CalendarWeekday.monday.rawValue)
        // 2024-01-13 is a Saturday
        let saturday = calendar.date(from: DateComponents(year: 2024, month: 1, day: 13))!
        XCTAssertEqual(calendar.component(.weekday, from: saturday), CalendarWeekday.saturday.rawValue)
    }
}
