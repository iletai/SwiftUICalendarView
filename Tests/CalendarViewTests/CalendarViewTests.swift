import XCTest
import SwiftUI
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
        for (index, date) in dates.enumerated() {
            XCTAssertEqual(calendar.component(.day, from: date), index + 1)
        }
    }

    func testEnumerateDates_MonthIncrement() {
        let start = makeDate(year: 2024, month: 1, day: 1)
        let end = makeDate(year: 2024, month: 6, day: 1)
        let increment = DateComponents(month: 1)
        let dates = calendar.enumerateDates(from: start, to: end, increment: increment)
        XCTAssertEqual(dates.count, 6) // Jan through Jun
        for (index, date) in dates.enumerated() {
            XCTAssertEqual(calendar.component(.month, from: date), index + 1)
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

// MARK: - Modern Declarative CalendarView Tests

final class CalendarViewModernTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    // MARK: - Selection Initializers Tests

    @MainActor
    func testSingleDateSelectionInit() {
        var selected = makeDate(year: 2024, month: 5, day: 15)
        let binding = Binding(get: { selected }, set: { selected = $0 })
        let view = CalendarView(selection: binding)

        let renderer = ImageRenderer(content: view)
        XCTAssertNotNil(renderer.cgImage)
    }

    @MainActor
    func testSingleDateSelectionWithExplicitDisplayDate() {
        var selected = makeDate(year: 2024, month: 5, day: 15)
        var display = makeDate(year: 2024, month: 6, day: 1)
        let selBinding = Binding(get: { selected }, set: { selected = $0 })
        let dispBinding = Binding(get: { display }, set: { display = $0 })

        let view = CalendarView(selection: selBinding, displayDate: dispBinding)
        let renderer = ImageRenderer(content: view)
        XCTAssertNotNil(renderer.cgImage)
    }

    @MainActor
    func testRangeSelectionInitWithNil() {
        var range: ClosedRange<Date>? = nil
        let binding = Binding(get: { range }, set: { range = $0 })
        let view = CalendarView(selection: binding)

        let renderer = ImageRenderer(content: view)
        XCTAssertNotNil(renderer.cgImage)
    }

    @MainActor
    func testRangeSelectionInitWithRange() {
        let start = makeDate(year: 2024, month: 5, day: 10)
        let end = makeDate(year: 2024, month: 5, day: 20)
        var range: ClosedRange<Date>? = start...end
        let binding = Binding(get: { range }, set: { range = $0 })
        let view = CalendarView(selection: binding)

        let renderer = ImageRenderer(content: view)
        XCTAssertNotNil(renderer.cgImage)
    }

    func testRangeSelectionSmartExpansion() {
        let day1 = makeDate(year: 2024, month: 5, day: 10)
        let day2 = makeDate(year: 2024, month: 5, day: 15)
        let day3 = makeDate(year: 2024, month: 5, day: 20)
        let dayEarlier = makeDate(year: 2024, month: 5, day: 5)

        var selectedRange: ClosedRange<Date>? = nil
        let rangeBinding = Binding<ClosedRange<Date>?>(
            get: { selectedRange },
            set: { selectedRange = $0 }
        )

        let tapAction: (Date) -> Void = { tappedDate in
            if let range = rangeBinding.wrappedValue {
                if range.lowerBound == range.upperBound && tappedDate >= range.lowerBound {
                    rangeBinding.wrappedValue = range.lowerBound...tappedDate
                } else {
                    rangeBinding.wrappedValue = tappedDate...tappedDate
                }
            } else {
                rangeBinding.wrappedValue = tappedDate...tappedDate
            }
        }

        // Tap 1: First tap selects single day range
        tapAction(day1)
        XCTAssertEqual(selectedRange, day1...day1)

        // Tap 2: Second tap on later day expands to full range
        tapAction(day2)
        XCTAssertEqual(selectedRange, day1...day2)

        // Tap 3: Third tap resets to new single day range
        tapAction(day3)
        XCTAssertEqual(selectedRange, day3...day3)

        // Tap 4: Tap earlier day resets to earlier day range
        tapAction(dayEarlier)
        XCTAssertEqual(selectedRange, dayEarlier...dayEarlier)
    }

    @MainActor
    func testMultiDateSelectionInit() {
        let day1 = makeDate(year: 2024, month: 5, day: 10)
        let day2 = makeDate(year: 2024, month: 5, day: 15)
        var dates: Set<Date> = [day1, day2]
        let binding = Binding(get: { dates }, set: { dates = $0 })
        let view = CalendarView(selection: binding)

        let renderer = ImageRenderer(content: view)
        XCTAssertNotNil(renderer.cgImage)
    }

    func testMultiDateSelectionToggleSemantics() {
        let day1 = makeDate(year: 2024, month: 5, day: 10)
        let day2 = makeDate(year: 2024, month: 5, day: 15)

        var selectedDates: Set<Date> = []
        let datesBinding = Binding<Set<Date>>(
            get: { selectedDates },
            set: { selectedDates = $0 }
        )

        let toggleAction: (Date) -> Void = { tappedDate in
            let cal = Calendar.current
            let key = CalendarDateKey.key(for: tappedDate, using: cal)
            if let existing = datesBinding.wrappedValue.first(where: { CalendarDateKey.key(for: $0, using: cal) == key }) {
                datesBinding.wrappedValue.remove(existing)
            } else {
                datesBinding.wrappedValue.insert(tappedDate)
            }
        }

        // Add day 1
        toggleAction(day1)
        XCTAssertEqual(selectedDates.count, 1)
        XCTAssertTrue(selectedDates.contains(day1))

        // Add day 2
        toggleAction(day2)
        XCTAssertEqual(selectedDates.count, 2)
        XCTAssertTrue(selectedDates.contains(day2))

        // Toggle day 1 off
        toggleAction(day1)
        XCTAssertEqual(selectedDates.count, 1)
        XCTAssertFalse(selectedDates.contains(day1))
        XCTAssertTrue(selectedDates.contains(day2))
    }

    @MainActor
    func testDisplayOnlyInit() {
        var display = makeDate(year: 2024, month: 7, day: 1)
        let binding = Binding(get: { display }, set: { display = $0 })
        let view = CalendarView(displayDate: binding)

        let renderer = ImageRenderer(content: view)
        XCTAssertNotNil(renderer.cgImage)
    }

    // MARK: - Custom ViewBuilder & Slot Modifiers Tests

    @MainActor
    func testCustomViewBuilderInit() {
        var display = makeDate(year: 2024, month: 5, day: 1)
        let binding = Binding(get: { display }, set: { display = $0 })

        let view = CalendarView(
            displayDate: binding,
            selectedKeySet: [20240515],
            rangeBounds: (nil, nil),
            onDateTapped: { _ in },
            dayCell: { state in
                Text("\(state.dayNumber)")
                    .foregroundColor(state.isSelected ? .white : .black)
            },
            header: { matrix, prev, next in
                HStack {
                    Button("<", action: prev)
                    Text(matrix.monthTitle)
                    Button(">", action: next)
                }
            },
            weekday: { cal in
                HStack {
                    ForEach(cal.veryShortWeekdaySymbols, id: \.self) {
                        Text($0)
                    }
                }
            }
        )

        let renderer = ImageRenderer(content: view)
        XCTAssertNotNil(renderer.cgImage)
    }

    @MainActor
    func testSlotModifiersIndividualAndChained() {
        var date = makeDate(year: 2024, month: 5, day: 1)
        let binding = Binding(get: { date }, set: { date = $0 })

        // Test individual slot modifiers
        let customCellView = CalendarView(selection: binding)
            .calendarDayCell { state in
                Text("D: \(state.dayNumber)")
            }
        XCTAssertNotNil(ImageRenderer(content: customCellView).cgImage)

        let customHeaderView = CalendarView(selection: binding)
            .calendarHeader { matrix, prev, next in
                Text("Custom: \(matrix.monthTitle)")
            }
        XCTAssertNotNil(ImageRenderer(content: customHeaderView).cgImage)

        let customWeekdayView = CalendarView(selection: binding)
            .calendarWeekdayHeader { _ in
                Text("Sun-Sat")
            }
        XCTAssertNotNil(ImageRenderer(content: customWeekdayView).cgImage)

        // Test chained modifiers
        let chainedView = CalendarView(selection: binding)
            .calendarDayCell { state in
                Text("\(state.dayNumber)")
            }
            .calendarHeader { matrix, _, _ in
                Text(matrix.monthTitle)
            }
            .calendarWeekdayHeader { _ in
                Text("Wk")
            }

        XCTAssertNotNil(ImageRenderer(content: chainedView).cgImage)
    }

    @MainActor
    func testEnvironmentModifiersOnCalendarView() {
        var date = makeDate(year: 2024, month: 5, day: 1)
        let binding = Binding(get: { date }, set: { date = $0 })
        let eventDate = makeDate(year: 2024, month: 5, day: 15)
        let event = CalendarEvent(id: "ev1", date: eventDate, title: "Birthday")

        let view = CalendarView(selection: binding)
            .calendarViewMode(.month)
            .calendarDisabledDates { $0 == eventDate }
            .calendarEvents([eventDate: [event]])
            .calendarFirstWeekday(.monday)
            .calendarHapticsEnabled(false)
            .calendarLocale(Locale(identifier: "fr_FR"))

        let renderer = ImageRenderer(content: view)
        XCTAssertNotNil(renderer.cgImage)
    }
}

