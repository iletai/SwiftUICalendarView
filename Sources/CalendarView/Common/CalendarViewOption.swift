//
//  CalendarViewOption.swift
//
//
//  Created by Lê Quang Trọng Tài on 5/4/24.
//

import Foundation
import SwiftUI

/// A struct that represents the options for a calendar view.
public struct CalendarViewOption {
    public var isShowHeader: Bool
    public var isShowDateOut: Bool
    public var isShowDivider: Bool
    public var isHighlightToday: Bool
    public var calendar: Calendar
    public var backgroundStatus: CalendarBackground
    public var spacingBetweenDay: CGFloat
    public var viewMode: CalendarViewMode
    public var spaceBetweenColumns: CGFloat
    public var compactMonthCount = 3
    public var locale: Locale
    public var selectedDateRange: ClosedRange<Date>?
    public var onRangeSelected: ((ClosedRange<Date>) -> Void)?
    public var eventDates: Set<Date>?
    public var disabledDateRule: ((Date) -> Bool)?
    public let swapAnimation: Animation = .easeInOut(duration: 0.3)
    public let swapRight = AnyTransition.asymmetric(
        insertion: .scale(scale: 1.5, anchor: .center),
        removal: .opacity
    )
    public let swapLeft = AnyTransition.asymmetric(
        insertion: .scale(scale: 1.5, anchor: .center),
        removal: .opacity
    )

    /// Deprecated: Use `isHighlightToday` instead.
    @available(*, deprecated, renamed: "isHighlightToday")
    public var isShowHightLightToDay: Bool {
        get { isHighlightToday }
        set { isHighlightToday = newValue }
    }

    /// Deprecated: Use `locale` instead.
    @available(*, deprecated, renamed: "locale")
    public var locateForCalendar: Locale {
        get { locale }
        set { locale = newValue }
    }

    /// Initializes a new instance of `CalendarViewOption` with default values.
    init() {
        self.isShowHeader = true
        self.isShowDateOut = true
        self.isShowDivider = true
        self.isHighlightToday = true
        self.calendar = .gregorian
        self.backgroundStatus = .hidden
        self.spacingBetweenDay = 8.0
        self.viewMode = .year(.full)
        self.spaceBetweenColumns = 8.0
        self.locale = .vietnam
        self.selectedDateRange = nil
        self.onRangeSelected = nil
        self.eventDates = nil
        self.disabledDateRule = nil
    }
}

extension CalendarViewOption {
    /// The default `CalendarViewOption` instance.
    public static var defaultOption: CalendarViewOption {
        CalendarViewOption()
    }
}
