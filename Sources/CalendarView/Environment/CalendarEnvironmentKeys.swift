import SwiftUI

private struct CalendarViewModeKey: EnvironmentKey {
    static let defaultValue: CalendarViewMode = .month
}

private struct CalendarDisabledRuleKey: EnvironmentKey {
    static let defaultValue: (@Sendable (Date) -> Bool)? = nil
}

private struct CalendarEventsKey: EnvironmentKey {
    static let defaultValue: [Date: [CalendarEvent]] = [:]
}

private struct CalendarFirstWeekdayOverrideKey: EnvironmentKey {
    static let defaultValue: Locale.Weekday? = nil
}

private struct CalendarHapticsEnabledKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

public extension EnvironmentValues {
    var calendarViewMode: CalendarViewMode {
        get { self[CalendarViewModeKey.self] }
        set { self[CalendarViewModeKey.self] = newValue }
    }

    var calendarDisabledRule: (@Sendable (Date) -> Bool)? {
        get { self[CalendarDisabledRuleKey.self] }
        set { self[CalendarDisabledRuleKey.self] = newValue }
    }

    var calendarEvents: [Date: [CalendarEvent]] {
        get { self[CalendarEventsKey.self] }
        set { self[CalendarEventsKey.self] = newValue }
    }

    var calendarFirstWeekdayOverride: Locale.Weekday? {
        get { self[CalendarFirstWeekdayOverrideKey.self] }
        set { self[CalendarFirstWeekdayOverrideKey.self] = newValue }
    }

    var calendarFirstWeekday: Locale.Weekday? {
        get { self.calendarFirstWeekdayOverride }
        set { self.calendarFirstWeekdayOverride = newValue }
    }

    var calendarHapticsEnabled: Bool {
        get { self[CalendarHapticsEnabledKey.self] }
        set { self[CalendarHapticsEnabledKey.self] = newValue }
    }
}
