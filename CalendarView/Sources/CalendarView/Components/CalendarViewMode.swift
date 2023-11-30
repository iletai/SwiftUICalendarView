//
//  ViewMode.swift
//
//
//  Created by tailqt on 28/11/2023.
//

import Foundation
import SwiftUI

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
