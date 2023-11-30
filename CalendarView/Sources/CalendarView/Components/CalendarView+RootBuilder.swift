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
    /// Show Header Calendar View
    /// - Parameter isEnable: Is Enable
    /// - Returns: Self - View
    public func enableHeader(_ isEnable: Bool) -> Self {
        mutating(\.showHeaders, value: isEnable)
    }

    /// Enable Show Date Out Of Month
    /// - Parameter isShow: Is Show
    /// - Returns: Self - View
    public func enableDateOut(_ isShow: Bool) -> Self {
        mutating(\.showDateOut, value: isShow)
    }

    /// Set Background Calendar Color/Radius
    /// - Parameter status: Enum Background Status
    /// - Returns: Self - View
    public func backgroundCalendar(_ status: BackgroundCalendar) -> Self {
        mutating(\.calendarBackgroundStatus, value: status)
    }

    /// Spacing Between Each Rows Calendar
    /// - Parameter spacing: Space
    /// - Returns: Self - View
    public func rowsSpacing(_ spacing: CGFloat) -> Self {
        mutating(\.spacingBetweenDay, value: spacing)
    }

    /// Collumns Spacing Calendar View
    /// - Parameter spacing: Spacing
    /// - Returns: Self - View
    public func columnSpacing(_ spacing: CGFloat) -> Self {
        mutating(\.spaceBetweenColumns, value: spacing)
    }

    /// Day Start First of Week
    /// - Parameter first: First Date
    /// - Returns: Self - View
    public func firstWeekDay(_ first: Int) -> Self {
        mutating(\.calendar.firstWeekday, value: first)
    }

    /// Set Locale For Current Calendar
    /// - Parameter locale: Locals
    /// - Returns: Self - View
    public func calendarLocate(locale: Locale) -> Self {
        mutating(\.calendar.locale, value: locale)
    }

    /// Set View Mode For Calendar
    /// - Parameter mode: Mode Display
    /// - Returns: Self - View
    public func setViewMode(_ mode: CalendarViewMode) -> Self {
        mutating(\.viewMode, value: mode)
    }

    /// This Still In Development. So Please Don't Use It.
    /// Events On Drag Calendar View
    /// - Parameter callback: Action Drag
    /// - Returns: Self - View
    public func onDraggingEnded(_ callback: (() -> Void)?) -> Self {
        mutating(\.onDraggingEnded, value: callback)
    }

    /// Is Allow Pinded View WeekDays
    /// - Parameter view: Pined View
    /// - Returns: Self - View
    public func enablePinedView(_ view: PinnedScrollableViews) -> Self {
        mutating(\.pinedHeaderView, value: [view])
    }
}
