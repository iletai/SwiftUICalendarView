//
//  ViewMode.swift
//
//
//  Created by tailqt on 28/11/2023.
//

import Foundation
import SwiftUI

/// Represents the different modes of the calendar view.
public enum CalendarViewMode: CaseIterable, Hashable {
    public static var allCases: [CalendarViewMode] {
        [
            CalendarViewMode.year(.full),
            CalendarViewMode.year(.compact),
            CalendarViewMode.month,
            CalendarViewMode.week,
            CalendarViewMode.single
        ]
    }

    case month
    case week
    case year(YearDisplayMode)
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

    /// The visibility of the scroll indicator for the mode.
    var enableScrollIndicator: ScrollIndicatorVisibility {
        switch self {
        case .month, .week, .single:
            return .never
        case .year:
            return .visible
        }
    }
}

extension CalendarViewMode: Equatable {}

public enum YearDisplayMode {
    case compact
    case full
}
