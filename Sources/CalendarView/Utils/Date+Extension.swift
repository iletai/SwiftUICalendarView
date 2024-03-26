//
//  Date+Extension.swift
//
//
//  Created by Lê Quang Trọng Tài on 11/26/23.
//

import Foundation
import SwiftDate

/// Extension for `Date` providing additional utility methods.
extension Date {
    /// Returns the name of the week day for the date.
    public var weekDayName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locales.vietnamese.toLocale()
        return dateFormatter.string(from: self)
    }

    /// Returns the short name of the week day for the date.
    public var weekDayShortName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        dateFormatter.locale = Locales.vietnamese.toLocale()
        return dateFormatter.string(from: self)
    }

    /// Returns the day name for the date.
    public var dayName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        dateFormatter.locale = Locales.vietnamese.toLocale()
        return dateFormatter.string(from: self)
    }

    /// Returns the start of the year for the date in the specified calendar.
    ///
    /// - Parameter inCalendar: The calendar to use.
    /// - Returns: The start of the year for the date.
    public func startOfYear(_ inCalendar: Calendar) -> DateInRegion {
        currentDateInRegion(inCalendar).dateAtStartOf(.year)
    }

    /// Returns the start of the month for the date in the specified calendar.
    ///
    /// - Parameter inCalendar: The calendar to use.
    /// - Returns: The start of the month for the date.
    public func startOfMonth(_ inCalendar: Calendar) -> DateInRegion {
        currentDateInRegion(inCalendar).dateAtStartOf(.month)
    }

    /// Returns the end of the year for the date in the specified calendar.
    ///
    /// - Parameter inCalendar: The calendar to use.
    /// - Returns: The end of the year for the date.
    public func endOfYear(_ inCalendar: Calendar) -> DateInRegion {
        currentDateInRegion(inCalendar).dateAtEndOf(.year)
    }

    /// Returns the current date in the specified calendar.
    ///
    /// - Parameter calendar: The calendar to use.
    /// - Returns: The current date in the specified calendar.
    public func currentDateInRegion(_ calendar: Calendar) -> DateInRegion {
        DateInRegion(self, region: .currentIn(calendar: calendar))
    }
}
