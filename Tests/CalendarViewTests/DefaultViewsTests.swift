import XCTest
import SwiftUI
@testable import CalendarView

final class DefaultViewsTests: XCTestCase {

    // MARK: - DefaultCalendarWeekdayHeader Tests

    func testWeekdayHeaderSundayFirst() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.firstWeekday = 1 // Sunday

        let header = DefaultCalendarWeekdayHeader(calendar: calendar)
        let symbols = header.weekdaySymbols

        XCTAssertEqual(symbols.count, 7)
        XCTAssertEqual(symbols.first, "Sun")
        XCTAssertEqual(symbols.last, "Sat")
    }

    func testWeekdayHeaderMondayFirst() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.firstWeekday = 2 // Monday

        let header = DefaultCalendarWeekdayHeader(calendar: calendar)
        let symbols = header.weekdaySymbols

        XCTAssertEqual(symbols.count, 7)
        XCTAssertEqual(symbols.first, "Mon")
        XCTAssertEqual(symbols.last, "Sun")
    }

    func testWeekdayHeaderWednesdayFirst() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.firstWeekday = 4 // Wednesday

        let header = DefaultCalendarWeekdayHeader(calendar: calendar)
        let symbols = header.weekdaySymbols

        XCTAssertEqual(symbols.count, 7)
        XCTAssertEqual(symbols.first, "Wed")
        XCTAssertEqual(symbols[1], "Thu")
        XCTAssertEqual(symbols[2], "Fri")
        XCTAssertEqual(symbols[3], "Sat")
        XCTAssertEqual(symbols[4], "Sun")
        XCTAssertEqual(symbols[5], "Mon")
        XCTAssertEqual(symbols[6], "Tue")
    }

    @MainActor
    func testWeekdayHeaderRendering() {
        let header = DefaultCalendarWeekdayHeader()
        let renderer = ImageRenderer(content: header)
        _ = renderer.cgImage
        XCTAssertNotNil(header.body)
    }

    // MARK: - DefaultCalendarDayCell Tests

    func testDayCellAccessibilityWithoutEvents() {
        let calendar = Calendar(identifier: .gregorian)
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 9
        comps.day = 24
        guard let date = calendar.date(from: comps) else {
            XCTFail("Failed to build date")
            return
        }

        let state = CalendarDayState(
            dateKey: 20260924,
            date: date,
            dayNumber: 24,
            isCurrentMonth: true,
            isToday: true,
            isSelected: false,
            events: []
        )

        let cell = DefaultCalendarDayCell(state: state)
        let formattedDate = date.formatted(.dateTime.year().month().day())
        XCTAssertEqual(cell.accessibilityText, formattedDate)
    }

    func testDayCellAccessibilityWithEvents() {
        let calendar = Calendar(identifier: .gregorian)
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 9
        comps.day = 24
        guard let date = calendar.date(from: comps) else {
            XCTFail("Failed to build date")
            return
        }

        let events = [
            CalendarEvent(id: "e1", date: date, color: .red, title: "Standup"),
            CalendarEvent(id: "e2", date: date, color: .blue, title: "Sprint Review")
        ]

        let state = CalendarDayState(
            dateKey: 20260924,
            date: date,
            dayNumber: 24,
            isCurrentMonth: true,
            isToday: false,
            isSelected: true,
            events: events
        )

        let cell = DefaultCalendarDayCell(state: state)
        let formattedDate = date.formatted(.dateTime.year().month().day())
        XCTAssertEqual(cell.accessibilityText, "\(formattedDate), 2 events")
    }

    func testDayCellTextColorStates() {
        let date = Date()

        // 1. Selected state -> white text
        let selectedState = CalendarDayState(
            dateKey: 20260924,
            date: date,
            dayNumber: 24,
            isCurrentMonth: true,
            isToday: false,
            isSelected: true
        )
        let selectedCell = DefaultCalendarDayCell(state: selectedState)
        XCTAssertEqual(selectedCell.textColor, .white)

        // 2. Disabled state -> secondary opacity
        let disabledState = CalendarDayState(
            dateKey: 20260924,
            date: date,
            dayNumber: 24,
            isCurrentMonth: true,
            isToday: false,
            isSelected: false,
            isDisabled: true
        )
        let disabledCell = DefaultCalendarDayCell(state: disabledState)
        XCTAssertEqual(disabledCell.textColor, .secondary.opacity(0.5))

        // 3. Current month -> primary
        let currentMonthState = CalendarDayState(
            dateKey: 20260924,
            date: date,
            dayNumber: 24,
            isCurrentMonth: true,
            isToday: false,
            isSelected: false
        )
        let currentMonthCell = DefaultCalendarDayCell(state: currentMonthState)
        XCTAssertEqual(currentMonthCell.textColor, .primary)

        // 4. Date out (not current month) -> secondary
        let outOfMonthState = CalendarDayState(
            dateKey: 20260924,
            date: date,
            dayNumber: 24,
            isCurrentMonth: false,
            isToday: false,
            isSelected: false
        )
        let outOfMonthCell = DefaultCalendarDayCell(state: outOfMonthState)
        XCTAssertEqual(outOfMonthCell.textColor, .secondary)
    }

    @MainActor
    func testDayCellRenderingAcrossStates() {
        let date = Date()
        let positions: [RangeSelectionPosition] = [.none, .singleDay, .rangeStart, .rangeMiddle, .rangeEnd, .rowStart, .rowEnd]

        for pos in positions {
            let state = CalendarDayState(
                dateKey: 20260924,
                date: date,
                dayNumber: 24,
                isCurrentMonth: true,
                isToday: true,
                isSelected: pos != .none,
                rangePosition: pos,
                events: [CalendarEvent(id: "1", date: date, color: .purple)]
            )
            let cell = DefaultCalendarDayCell(state: state, accentColor: .purple)
            let renderer = ImageRenderer(content: cell)
            _ = renderer.cgImage
            XCTAssertNotNil(cell.body)
        }
    }

    // MARK: - DefaultCalendarHeader Tests

    func testHeaderTitleAndButtonActions() {
        var prevTapped = false
        var nextTapped = false

        let header = DefaultCalendarHeader(
            title: "September 2026",
            onPrevious: { prevTapped = true },
            onNext: { nextTapped = true }
        )

        XCTAssertEqual(header.title, "September 2026")

        header.onPrevious()
        XCTAssertTrue(prevTapped)
        XCTAssertFalse(nextTapped)

        header.onNext()
        XCTAssertTrue(nextTapped)
    }

    @MainActor
    func testHeaderRendering() {
        let header = DefaultCalendarHeader(
            title: "October 2026",
            onPrevious: {},
            onNext: {}
        )
        let renderer = ImageRenderer(content: header)
        _ = renderer.cgImage
        XCTAssertNotNil(header.body)
    }
}
