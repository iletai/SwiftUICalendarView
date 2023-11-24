//
//  DateFormatter.swift
//
//
//  Created by iletai on 24/11/2023.
//

import Foundation

public extension DateFormatter {
    static let monthAndYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return formatter
    }()

    static var day: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }

    static var weekDay: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter
    }
}
