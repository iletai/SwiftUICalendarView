//
//  CalendarViewOption.swift
//
//
//  Created by Lê Quang Trọng Tài on 5/4/24.
//

import Foundation
import SwiftDate
import SwiftUI

/// A struct that represents the options for a calendar view.
public struct CalendarViewOption {
    public var isShowHeader: Bool
    public var isShowDateOut: Bool
    public var isShowDivider: Bool
    public var isShowHightLightToDay: Bool
    public var calendar: Calendar
    public var backgroundStatus: CalendarBackground
    public var spacingBetweenDay: CGFloat
    public var viewMode: CalendarViewMode
    public var spaceBetweenColumns: CGFloat
    public var compactMonthCount = 3
    public var locateForCalendar: Locale
    public let swapAnimation: Animation = .easeInOut(duration: 0.3)
    public let swapRight = AnyTransition.asymmetric(
        insertion: .scale(scale: 1.5, anchor: .center),
        removal: .opacity
    )
    public let swapLeft = AnyTransition.asymmetric(
        insertion: .scale(scale: 1.5, anchor: .center),
        removal: .opacity
    )

    /// Initializes a new instance of `CalendarViewOption` with default values.
    init() {
        self.isShowHeader = true
        self.isShowDateOut = true
        self.isShowDivider = true
        self.isShowHightLightToDay = true
        self.calendar = .gregorian
        self.backgroundStatus = .hidden
        self.spacingBetweenDay = 8.0
        self.viewMode = .year(.full)
        self.spaceBetweenColumns = 8.0
        self.locateForCalendar = Locale.vietnam.toLocale()
    }
}

extension CalendarViewOption {
    /// The default `CalendarViewOption` instance.
    public static var defaultOption: CalendarViewOption {
        var options = CalendarViewOption()
        options.backgroundStatus = .hidden
        options.calendar = .gregorian
        options.isShowHightLightToDay = true
        options.isShowDateOut = true
        options.isShowHeader = true
        options.spaceBetweenColumns = 8.0
        options.spacingBetweenDay = 8.0
        options.viewMode = .year(.full)
        options.isShowDivider = true
        options.compactMonthCount = 3
        options.locateForCalendar = Locale.vietnam.toLocale()
        return options
    }
}
