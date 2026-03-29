//
//  CalendarView+RootBuilder.swift
//
//
//  Created by iletai on 24/11/2023.
//

import Foundation
import SwiftUI

@MainActor
extension CalendarView: RootBuilder {
    /// Enables or disables the header in the calendar view.
    public func enableHeader(_ isEnable: Bool) -> Self {
        mutating(\.calendarOptions.isShowHeader, value: isEnable)
    }

    /// Enables or disables the display of dates outside the current month.
    public func enableDateOut(_ isShow: Bool) -> Self {
        mutating(\.calendarOptions.isShowDateOut, value: isShow)
    }

    /// Sets the background style for the calendar view.
    public func backgroundCalendar(_ status: CalendarBackground) -> Self {
        mutating(\.calendarOptions.backgroundStatus, value: status)
    }

    /// Deprecated: Use `backgroundCalendar(_:)` instead.
    @available(*, deprecated, renamed: "backgroundCalendar")
    public func background(_ status: CalendarBackground) -> Self {
        backgroundCalendar(status)
    }

    /// Sets the spacing between rows in the calendar view.
    public func rowsSpacing(_ spacing: CGFloat) -> Self {
        mutating(\.calendarOptions.spacingBetweenDay, value: spacing)
    }

    /// Sets the spacing between columns in the calendar view.
    public func columnSpacing(_ spacing: CGFloat) -> Self {
        mutating(\.calendarOptions.spaceBetweenColumns, value: spacing)
    }

    /// Sets the first day of the week in the calendar view.
    public func firstWeekDay(_ first: CalendarWeekday) -> Self {
        mutating(\.calendarOptions.calendar.firstWeekday, value: first.rawValue)
    }

    /// Sets the locale for the calendar view.
    public func calendarLocale(_ locale: Locale) -> Self {
        mutating(\.calendarOptions.calendar.locale, value: locale)
    }

    /// Deprecated: Use `calendarLocale(_:)` instead.
    @available(*, deprecated, renamed: "calendarLocale")
    public func calendarLocate(locale: Locale) -> Self {
        calendarLocale(locale)
    }

    /// Sets the view mode for the calendar view.
    public func setViewMode(_ mode: CalendarViewMode) -> Self {
        mutating(\.calendarOptions.viewMode, value: mode)
    }

    /// Sets the callback for when dragging ends in the calendar view.
    public func onDraggingEnded(_ callback: OnEndDragAction?) -> Self {
        mutating(\.onDraggingEnded, value: callback)
    }

    /// Enables the pinned view in the calendar view.
    public func enablePinnedView(_ view: PinnedScrollableViews) -> Self {
        mutating(\.pinnedHeaderView, value: [view])
    }

    /// Deprecated: Use `enablePinnedView(_:)` instead.
    @available(*, deprecated, renamed: "enablePinnedView")
    public func enablePinedView(_ view: PinnedScrollableViews) -> Self {
        enablePinnedView(view)
    }

    /// Sets a callback closure to be executed when a date is selected.
    /// When a date binding is present, the binding is updated alongside the callback.
    public func onSelectDate(_ callback: @escaping OnSelectedDate) -> Self {
        if let binding = dateBinding {
            return mutating(\.onSelected, value: { date in
                binding.wrappedValue = date
                callback(date)
            })
        }
        return mutating(\.onSelected, value: callback)
    }

    /// Enables or disables the divider in the calendar view.
    public func enableDivider(_ isEnable: Bool) -> Self {
        mutating(\.calendarOptions.isShowDivider, value: isEnable)
    }

    /// Enables or disables the highlight effect on the current day.
    public func enableHighlightToday(_ isEnable: Bool) -> Self {
        mutating(\.calendarOptions.isHighlightToday, value: isEnable)
    }

    /// Deprecated: Use `enableHighlightToday(_:)` instead.
    @available(*, deprecated, renamed: "enableHighlightToday")
    public func enableHighlightToDay(_ isEnable: Bool) -> Self {
        enableHighlightToday(isEnable)
    }

    /// Sets the initial date to be displayed in the calendar view.
    func setDate(_ date: Date) -> Self {
        mutating(\.date, value: date)
    }

    /// Sets the selected date range for highlighting.
    public func selectedRange(_ range: ClosedRange<Date>?) -> Self {
        mutating(\.calendarOptions.selectedDateRange, value: range)
    }

    /// Sets the callback for when a date range is selected.
    public func onRangeSelected(_ callback: @escaping (ClosedRange<Date>) -> Void) -> Self {
        mutating(\.calendarOptions.onRangeSelected, value: callback)
    }

    /// Sets the dates that have events for indicator display.
    public func eventDates(_ dates: Set<Date>) -> Self {
        mutating(\.calendarOptions.eventDates, value: dates)
    }

    /// Sets a rule to determine which dates should be disabled in the calendar.
    public func disabledDates(_ rule: @escaping (Date) -> Bool) -> Self {
        mutating(\.calendarOptions.disabledDateRule, value: rule)
    }
}
