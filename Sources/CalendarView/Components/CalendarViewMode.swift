//
//  ViewMode.swift
//
//
//  Created by tailqt on 28/11/2023.
//

import Foundation
import SwiftUI
import SwiftDate

public enum CalendarViewMode: CaseIterable {
    case month
    case week
    case year

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

    var dateComponent: DateComponents {
        switch self {
        case .month,
        .week:
            return DateComponents(day: 1)
        case .year:
            return DateComponents(month: 1)
        }
    }
    
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

    var isDisableScroll: Bool { !enableScroll }

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

    var dateRelatedType: DateRelatedType {
        switch self {
        case .month:
            return .nextMonth
        case .week:
            return .nextWeek
        case .year:
            return .nextYear
        }
    }
}
