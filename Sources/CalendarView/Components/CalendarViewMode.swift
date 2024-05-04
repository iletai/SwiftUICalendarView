//
//  ViewMode.swift
//
//
//  Created by tailqt on 28/11/2023.
//

import Foundation
import SwiftUI
import SwiftDate

/// Represents the different modes of the calendar view.
public enum CalendarViewMode: CaseIterable {
    case month
    case week
    case year
    case single

    /// The corresponding `Calendar.Component` for each mode.
    var component: Calendar.Component {
        switch self {
        case .month:
            return .month
        case .week:
            return .weekOfMonth
        case .year:
            return .year
        case .single:
            return .day
        }
    }

    /// The corresponding `DateComponents` for each mode.
    var dateComponent: DateComponents {
        switch self {
        case .month, .single, .week:
            return DateComponents(day: 1)
        case .year:
            return DateComponents(month: 1)
        }
    }

    /// Determines if scrolling is enabled for the mode.
    var enableScroll: Bool {
        switch self {
        case .month, .week, .single:
            return false
        case .year:
            return true
        }
    }

    /// Determines if scrolling is disabled for the mode.
    var isDisableScroll: Bool { !enableScroll }

    /// The visibility of the scroll indicator for the mode.
    var enableScrollIndicator: ScrollIndicatorVisibility {
        switch self {
        case .month, .week, .single:
            return .never
        case .year:
            return .visible
        }
    }

    /// The type of date related to the mode.
    var dateRelatedType: DateRelatedType {
        switch self {
        case .month:
            return .nextMonth
        case .week:
            return .nextWeek
        case .year:
            return .nextYear
        case .single:
            return .nextWeekday(.sunday)
        }
    }
}
