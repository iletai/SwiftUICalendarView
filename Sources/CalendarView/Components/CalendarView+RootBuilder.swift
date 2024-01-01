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
    /// - Parameter isEnable: A boolean value indicating whether to enable or disable the header.
    /// - Returns: An instance of `Self` with the updated configuration.
    public func enableHeader(_ isEnable: Bool) -> Self {
        mutating(\.showHeaders, value: isEnable)
    }

    /// Enables or disables the display of dates outside the current month in the calendar view.
    /// - Parameter isShow: A boolean value indicating whether to show or hide dates outside the current month.
    /// - Returns: An instance of `Self` with the updated configuration.
    public func enableDateOut(_ isShow: Bool) -> Self {
        mutating(\.showDateOut, value: isShow)
    }

    /// Sets the background style for the calendar view.
    /// - Parameter status: The background style for the calendar view.
    /// - Returns: An instance of `Self` with the updated configuration.
    public func backgroundCalendar(_ status: BackgroundCalendar) -> Self {
        mutating(\.calendarBackgroundStatus, value: status)
    }

    /// Sets the spacing between rows in the calendar view.
    /// - Parameter spacing: The spacing between rows.
    /// - Returns: An instance of `Self` with the updated configuration.
    public func rowsSpacing(_ spacing: CGFloat) -> Self {
        mutating(\.spacingBetweenDay, value: spacing)
    }

    /// Sets the spacing between columns in the calendar view.
    /// - Parameter spacing: The spacing between columns.
    /// - Returns: An instance of `Self` with the updated configuration.
    public func columnSpacing(_ spacing: CGFloat) -> Self {
        mutating(\.spaceBetweenColumns, value: spacing)
    }

    /// Sets the first day of the week in the calendar view.
    /// - Parameter first: The index of the first day of the week (1 for Sunday, 2 for Monday, etc.).
    /// - Returns: An instance of `Self` with the updated configuration.
    public func firstWeekDay(_ first: Int) -> Self {
        mutating(\.calendar.firstWeekday, value: first)
    }

    /// Sets the locale for the calendar view.
    /// - Parameter locale: The locale to be used for the calendar view.
    /// - Returns: An instance of `Self` with the updated configuration.
    public func calendarLocate(locale: Locale) -> Self {
        mutating(\.calendar.locale, value: locale)
    }

    /// Sets the view mode for the calendar view.
    /// - Parameter mode: The view mode for the calendar view.
    /// - Returns: An instance of `Self` with the updated configuration.
    public func setViewMode(_ mode: CalendarViewMode) -> Self {
        mutating(\.viewMode, value: mode)
    }

    /// Sets the callback for when dragging ends in the calendar view.
    /// - Parameter callback: A closure that takes a `Direction` parameter and has no return value.
    /// - Returns: An instance of `Self` with the updated configuration.
    public func onDraggingEnded(_ callback: ((Direction) -> Void)?) -> Self {
        mutating(\.onDraggingEnded, value: callback)
    }

    /// Enables the pinned view in the calendar view.
    /// - Parameter view: The pinned view to be enabled.
    /// - Returns: An instance of `Self` with the updated configuration.
    public func enablePinedView(_ view: PinnedScrollableViews) -> Self {
        mutating(\.pinedHeaderView, value: [view])
    }
}
