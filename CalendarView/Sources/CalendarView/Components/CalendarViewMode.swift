//
//  ViewMode.swift
//
//
//  Created by tailqt on 28/11/2023.
//

import Foundation
import SwiftUI

/// Define Mode Display Of CalendarView
public enum CalendarViewMode: CaseIterable {
    /// Month View
    case month
    /// Week View
    case week
    /// Year View
    case year
    
    /// Calendar Component
    var component: Calendar.Component {
        switch self {
        case .month:
            return .month
        case .week:
            return .weekOfMonth
        case .year:
            return .year
        }
    }

    /// DateComponents
    var dateComponent: DateComponents {
        switch self {
        case .month,
        .week:
            return DateComponents.create {
                $0.day = 1
                $0.hour = 0
                $0.minute = 0
            }
        case .year:
            return DateComponents.create {
                $0.month = 1
                $0.day = 0
                $0.hour = 0
                $0.minute = 0
            }
        }
    }
    
    /// Status Allow Scroll View
    var enableScroll: Bool {
        switch self {
        case .month:
            return false
        case .week:
            return false
        case .year:
            return true
        }
    }
    
    /// Status Show Scroll Indicator
    var enableScrollIndicator: ScrollIndicatorVisibility {
        switch self {
        case .month:
            return .never
        case .week:
            return .never
        case .year:
            return .visible
        }
    }
}
