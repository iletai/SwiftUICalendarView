//
//  DateFormatter.swift
//
//
//  Created by iletai on 24/11/2023.
//

import Foundation
import SwiftDate

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
    
    static func toLunarDateString(forDate: Date, format: String = "MMdd") -> String {
        let dateFormat = DateFormatter()
        dateFormat.locale = Locales.vietnamese.toLocale()
        dateFormat.setLocalizedDateFormatFromTemplate(format)
        dateFormat.calendar = Calendar(identifier: .chinese)
        if dateFormat.calendar.component(.day, from: forDate) == 1 {
            dateFormat.setLocalizedDateFormatFromTemplate("d/M")
        }
        return dateFormat.string(from: forDate)
    }
    
    static func format(_ date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locales.vietnamese.toLocale()
        dateFormatter.setLocalizedDateFormatFromTemplate(format)
        return dateFormatter.string(from: date)
    }
}
