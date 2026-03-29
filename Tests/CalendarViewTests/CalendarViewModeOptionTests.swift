import XCTest
@testable import CalendarView

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
        let sunday = calendar.date(
            from: DateComponents(year: 2024, month: 1, day: 7)
        )!
        XCTAssertEqual(
            calendar.component(.weekday, from: sunday),
            CalendarWeekday.sunday.rawValue
        )
        let monday = calendar.date(
            from: DateComponents(year: 2024, month: 1, day: 8)
        )!
        XCTAssertEqual(
            calendar.component(.weekday, from: monday),
            CalendarWeekday.monday.rawValue
        )
        let saturday = calendar.date(
            from: DateComponents(year: 2024, month: 1, day: 13)
        )!
        XCTAssertEqual(
            calendar.component(.weekday, from: saturday),
            CalendarWeekday.saturday.rawValue
        )
    }
}
