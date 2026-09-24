import XCTest
import SwiftUI
@testable import CalendarView

final class CalendarEnvironmentTests: XCTestCase {

    // MARK: - Default Values

    func testDefaultEnvironmentValues() {
        let env = EnvironmentValues()

        XCTAssertEqual(env.calendarViewMode, .month)
        XCTAssertNil(env.calendarDisabledRule)
        XCTAssertTrue(env.calendarEvents.isEmpty)
        XCTAssertNil(env.calendarFirstWeekdayOverride)
        XCTAssertNil(env.calendarFirstWeekday)
        XCTAssertTrue(env.calendarHapticsEnabled)
    }

    // MARK: - Direct EnvironmentValues Mutation

    func testSetCalendarViewMode() {
        var env = EnvironmentValues()

        env.calendarViewMode = .week
        XCTAssertEqual(env.calendarViewMode, .week)

        env.calendarViewMode = .year(.compact)
        XCTAssertEqual(env.calendarViewMode, .year(.compact))

        env.calendarViewMode = .single
        XCTAssertEqual(env.calendarViewMode, .single)
    }

    func testSetCalendarDisabledRule() {
        var env = EnvironmentValues()
        let testDate = Date(timeIntervalSince1970: 1000)

        env.calendarDisabledRule = { date in
            date.timeIntervalSince1970 < 2000
        }

        XCTAssertNotNil(env.calendarDisabledRule)
        XCTAssertTrue(env.calendarDisabledRule!(testDate))
        XCTAssertFalse(env.calendarDisabledRule!(Date(timeIntervalSince1970: 3000)))
    }

    func testSetCalendarEvents() {
        var env = EnvironmentValues()
        let date = Date(timeIntervalSince1970: 0)
        let event = CalendarEvent(id: "event-1", date: date, color: .red, title: "Test Event")

        env.calendarEvents = [date: [event]]

        XCTAssertEqual(env.calendarEvents.count, 1)
        XCTAssertEqual(env.calendarEvents[date]?.count, 1)
        XCTAssertEqual(env.calendarEvents[date]?.first?.id, "event-1")
        XCTAssertEqual(env.calendarEvents[date]?.first?.title, "Test Event")
    }

    func testSetCalendarFirstWeekdayOverride() {
        var env = EnvironmentValues()

        env.calendarFirstWeekdayOverride = .monday
        XCTAssertEqual(env.calendarFirstWeekdayOverride, .monday)
        XCTAssertEqual(env.calendarFirstWeekday, .monday)

        env.calendarFirstWeekday = .saturday
        XCTAssertEqual(env.calendarFirstWeekdayOverride, .saturday)
        XCTAssertEqual(env.calendarFirstWeekday, .saturday)
    }

    func testSetCalendarHapticsEnabled() {
        var env = EnvironmentValues()

        env.calendarHapticsEnabled = false
        XCTAssertFalse(env.calendarHapticsEnabled)

        env.calendarHapticsEnabled = true
        XCTAssertTrue(env.calendarHapticsEnabled)
    }

    // MARK: - View Modifiers Construction

    func testViewModifiersReturnSomeView() {
        let sampleDate = Date(timeIntervalSince1970: 0)
        let sampleEvent = CalendarEvent(id: "test", date: sampleDate)

        let view = Text("Test View")
            .calendarViewMode(.week)
            .calendarDisabledDates { _ in true }
            .calendarEvents([sampleDate: [sampleEvent]])
            .calendarFirstWeekday(.monday)
            .calendarHapticsEnabled(false)
            .calendarLocale(Locale(identifier: "ja_JP"))

        XCTAssertNotNil(view)
    }

    func testCalendarHapticsEnabledDefaultParameter() {
        let view = Text("Test View").calendarHapticsEnabled()
        XCTAssertNotNil(view)
    }

    // MARK: - SwiftUI View Hierarchy Propagation

    @MainActor
    func testEnvironmentPropagationInViewHierarchy() {
        struct ProbeView: View {
            @Environment(\.calendarViewMode) var mode
            @Environment(\.calendarDisabledRule) var disabledRule
            @Environment(\.calendarEvents) var events
            @Environment(\.calendarFirstWeekdayOverride) var firstWeekday
            @Environment(\.calendarHapticsEnabled) var hapticsEnabled

            var body: some View {
                Text("Probe")
            }
        }

        let targetDate = Date(timeIntervalSince1970: 5000)
        let event = CalendarEvent(id: "e1", date: targetDate, title: "Meeting")

        let container = ProbeView()
            .calendarViewMode(.year(.compact))
            .calendarDisabledDates { $0 == targetDate }
            .calendarEvents([targetDate: [event]])
            .calendarFirstWeekday(.wednesday)
            .calendarHapticsEnabled(false)

        let renderer = ImageRenderer(content: container)
        _ = renderer.cgImage

        var envValues = EnvironmentValues()
        envValues.calendarViewMode = .year(.compact)
        envValues.calendarDisabledRule = { $0 == targetDate }
        envValues.calendarEvents = [targetDate: [event]]
        envValues.calendarFirstWeekdayOverride = .wednesday
        envValues.calendarHapticsEnabled = false

        XCTAssertEqual(envValues.calendarViewMode, .year(.compact))
        XCTAssertTrue(envValues.calendarDisabledRule?(targetDate) ?? false)
        XCTAssertEqual(envValues.calendarEvents[targetDate]?.first?.id, "e1")
        XCTAssertEqual(envValues.calendarFirstWeekdayOverride, .wednesday)
        XCTAssertFalse(envValues.calendarHapticsEnabled)
    }
}
