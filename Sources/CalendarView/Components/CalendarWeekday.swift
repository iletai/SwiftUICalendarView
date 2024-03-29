//
//  CalendarView+WeekDay.swift
//
//
//  Created by iletai on 27/03/2024.
//

import Foundation

public enum CalendarWeekday: Int, CustomStringConvertible {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    public var description: String {
        switch self {
        case .sunday:
            return "sunday"
        case .monday:
            return "monday"
        case .tuesday:
            return "tuesday"
        case .wednesday:
            return "wednesday"
        case .thursday:
            return "thursday"
        case .friday:
            return "friday"
        case .saturday:
            return "saturday"
        }
    }
}
