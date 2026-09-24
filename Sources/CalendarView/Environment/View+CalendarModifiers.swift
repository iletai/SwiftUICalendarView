import SwiftUI

public extension View {
    func calendarViewMode(_ mode: CalendarViewMode) -> some View {
        environment(\.calendarViewMode, mode)
    }

    func calendarDisabledDates(_ rule: @escaping @Sendable (Date) -> Bool) -> some View {
        environment(\.calendarDisabledRule, rule)
    }

    func calendarEvents(_ events: [Date: [CalendarEvent]]) -> some View {
        environment(\.calendarEvents, events)
    }

    func calendarFirstWeekday(_ weekday: Locale.Weekday) -> some View {
        environment(\.calendarFirstWeekdayOverride, weekday)
    }

    func calendarHapticsEnabled(_ enabled: Bool = true) -> some View {
        environment(\.calendarHapticsEnabled, enabled)
    }

    func calendarLocale(_ locale: Locale) -> some View {
        environment(\.locale, locale)
    }
}
