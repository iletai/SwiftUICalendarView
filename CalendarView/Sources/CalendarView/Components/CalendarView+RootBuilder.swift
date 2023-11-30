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

    public func enableHeader(_ isEnable: Bool) -> Self {
        mutating(\.showHeaders, value: isEnable)
    }

    public func enableDateOut(_ isShow: Bool) -> Self {
        mutating(\.showDateOut, value: isShow)
    }

    public func backgroundCalendar(_ status: BackgroundCalendar) -> Self {
        mutating(\.calendarBackgroundStatus, value: status)
    }

    public func rowsSpacing(_ spacing: CGFloat) -> Self {
        mutating(\.spacingBetweenDay, value: spacing)
    }

    public func columnSpacing(_ spacing: CGFloat) -> Self {
        mutating(\.spaceBetweenColumns, value: spacing)
    }

    public func firstWeekDay(_ first: Int) -> Self {
        mutating(\.calendar.firstWeekday, value: first)
    }

    public func calendarLocate(locale: Locale) -> Self {
        mutating(\.calendar.locale, value: locale)
    }

    public func setViewMode(_ mode: CalendarViewMode) -> Self {
        mutating(\.viewMode, value: mode)
    }

    public func onDraggingEnded(_ callback: (() -> Void)?) -> Self {
        mutating(\.onDraggingEnded, value: callback)
    }

    public func enablePinedView(_ view: PinnedScrollableViews) -> Self {
        mutating(\.pinedHeaderView, value: [view])
    }
}
