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

    /// Sets the locale for the calendar view (syncs both calendar and option).
    public func calendarLocale(_ locale: Locale) -> Self {
        var copy = self
        copy.calendarOptions.calendar.locale = locale
        copy.calendarOptions.locale = locale
        return copy
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

    /// Sets the date to scroll to when the calendar appears (year mode).
    public func scrollToDate(_ date: Date) -> Self {
        mutating(\.calendarOptions.scrollToDateOnAppear, value: date)
    }

    /// Enables or disables the floating "Today" button overlay.
    public func showTodayButton(_ show: Bool) -> Self {
        mutating(\.calendarOptions.showTodayButton, value: show)
    }

    /// Sets the callback for the "Today" button.
    public func onTodayTapped(_ callback: @escaping () -> Void) -> Self {
        mutating(\.calendarOptions.onTodayTapped, value: callback)
    }

    /// Enables or disables the month/year picker on the month title.
    public func enableMonthYearPicker(_ enable: Bool) -> Self {
        mutating(\.calendarOptions.enableMonthYearPicker, value: enable)
    }

    /// Sets the callback for when the month/year picker selection changes.
    public func onMonthYearChanged(_ callback: @escaping (Date) -> Void) -> Self {
        mutating(\.calendarOptions.onMonthYearChanged, value: callback)
    }

    /// Sets the content padding for the calendar view.
    public func contentPadding(_ padding: CGFloat) -> Self {
        mutating(\.calendarOptions.contentPadding, value: padding)
    }

    /// Sets the selection mode for the calendar view.
    public func selectionMode(_ mode: CalendarSelectionMode) -> Self {
        mutating(\.calendarOptions.selectionMode, value: mode)
    }

    /// Sets the currently selected dates.
    public func selectedDates(_ dates: Set<Date>) -> Self {
        mutating(\.calendarOptions.selectedDates, value: dates)
    }

    /// Sets the callback for when the selection changes.
    public func onSelectionChanged(_ callback: @escaping ([Date]) -> Void) -> Self {
        mutating(\.calendarOptions.onSelectionChanged, value: callback)
    }

    /// Sets the minimum and/or maximum allowed dates.
    public func dateRange(minimum: Date? = nil, maximum: Date? = nil) -> Self {
        var copy = self
        copy.calendarOptions.minimumDate = minimum
        copy.calendarOptions.maximumDate = maximum
        return copy
    }

    /// Sets the theme for the calendar view.
    public func calendarTheme(_ theme: CalendarTheme) -> Self {
        mutating(\.calendarOptions.theme, value: theme)
    }
}
