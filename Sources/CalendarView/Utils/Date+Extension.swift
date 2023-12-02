//
//  Date+Extension.swift
//
//
//  Created by Lê Quang Trọng Tài on 11/26/23.
//

import Foundation
import SwiftDate

extension Date {
    public var weekDayName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locales.vietnamese.toLocale()
        return dateFormatter.string(from: self)
    }

    public var weekDayShortName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        dateFormatter.locale = Locales.vietnamese.toLocale()
        return dateFormatter.string(from: self)
    }

    public var dayName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        dateFormatter.locale = Locales.vietnamese.toLocale()
        return dateFormatter.string(from: self)
    }
}
