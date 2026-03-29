//
//  Date+Extension.swift
//
//
//  Created by Lê Quang Trọng Tài on 11/26/23.
//

import Foundation

/// Extension for `Date` providing additional utility methods.
extension Date {
    /// Returns the name of the week day for the date (thread-safe).
    public var weekDayName: String {
        self.formatted(.dateTime.weekday(.wide))
    }

    /// Returns the short name of the week day for the date (thread-safe).
    public var weekDayShortName: String {
        self.formatted(.dateTime.weekday(.abbreviated))
    }

    /// Returns the day number for the date (thread-safe).
    public var dayName: String {
        self.formatted(.dateTime.day())
    }

    /// Returns the start of the year for the date in the specified calendar.
    public func startOfYear(using calendar: Calendar) -> Date {
        calendar.dateInterval(of: .year, for: self)?.start ?? self
    }

    /// Returns the end of the year for the date in the specified calendar.
    public func endOfYear(using calendar: Calendar) -> Date {
        guard let interval = calendar.dateInterval(of: .year, for: self) else { return self }
        return calendar.date(byAdding: .second, value: -1, to: interval.end) ?? self
    }

    /// Returns the start of the month for the date in the specified calendar.
    public func startOfMonth(using calendar: Calendar) -> Date {
        calendar.dateInterval(of: .month, for: self)?.start ?? self
    }

    /// Returns the end of the month for the date in the specified calendar.
    public func endOfMonth(using calendar: Calendar) -> Date {
        guard let interval = calendar.dateInterval(of: .month, for: self) else { return self }
        return calendar.date(byAdding: .second, value: -1, to: interval.end) ?? self
    }

    /// Returns the start of the week for the date in the specified calendar.
    public func startOfWeek(using calendar: Calendar) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: self)?.start ?? self
    }

    /// Returns the end of the week for the date in the specified calendar.
    public func endOfWeek(using calendar: Calendar) -> Date {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: self) else { return self }
        return calendar.date(byAdding: .second, value: -1, to: interval.end) ?? self
    }

    /// Returns the start of the given calendar component for this date.
    public func startOf(_ component: Calendar.Component, using calendar: Calendar) -> Date {
        calendar.dateInterval(of: component, for: self)?.start ?? self
    }

    /// Returns the end of the given calendar component for this date.
    public func endOf(_ component: Calendar.Component, using calendar: Calendar) -> Date {
        guard let interval = calendar.dateInterval(of: component, for: self) else { return self }
        return calendar.date(byAdding: .second, value: -1, to: interval.end) ?? self
    }

    /// Checks if this date is in the same month as another date.
    public func isSameMonth(as other: Date, using calendar: Calendar) -> Bool {
        calendar.isDate(self, equalTo: other, toGranularity: .month)
    }

    /// Checks if this date is in the same week as another date.
    public func isSameWeek(as other: Date, using calendar: Calendar) -> Bool {
        calendar.isDate(self, equalTo: other, toGranularity: .weekOfYear)
    }

    /// Formats the date using the specified format string and locale.
    public func formatted(as format: String, locale: Locale? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let locale { formatter.locale = locale }
        return formatter.string(from: self)
    }
}
