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
    case single

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

    var dateComponent: DateComponents {
        switch self {
        case .month,
        .single,
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
        case .single:
            return false
        }
    }

    var isDisableScroll: Bool { !enableScroll }

    var enableScrollIndicator: ScrollIndicatorVisibility {
        switch self {
        case .month,
        .single,
        .week:
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
        case .single:
            return .nextWeekday(.sunday)
        }
    }
}
