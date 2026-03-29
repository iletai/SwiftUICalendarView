//
//  Calendar+Extension.swift
//
//
//  Created by iletai on 24/11/2023.
//

import Foundation

extension Calendar {
    public static var gregorian: Calendar {
        Calendar(identifier: .gregorian)
    }

    /// Enumerates dates from a start date to an end date with the given increment.
    ///
    /// - Parameters:
    ///   - start: The start date.
    ///   - end: The end date (inclusive).
    ///   - increment: The date components to increment by.
    /// - Returns: An array of dates from start to end.
    public func enumerateDates(
        from start: Date,
        to end: Date,
        increment: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        var current = start
        while current <= end {
            dates.append(current)
            guard let next = date(byAdding: increment, to: current) else { break }
            if next <= current { break }
            current = next
        }
        return dates
    }
}
