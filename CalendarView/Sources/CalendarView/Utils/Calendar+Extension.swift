//
//  Calendar+Extension.swift
//
//
//  Created by iletai on 24/11/2023.
//

import SwiftUI

extension Calendar {
    public func parseDates(
        inside interval: DateInterval,
        matching components: DateComponents = DateComponents(day: 1, hour: 0, minute: 0, second: 0)
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        return dates
    }

    func generateDates(
        inside range: ClosedRange<Date>,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        var currentDate = range.lowerBound

        while currentDate <= range.upperBound {
            if let date = self.date(
                bySettingHour: components.hour ?? 0, minute: components.minute ?? 0,
                second: components.second ?? 0, of: currentDate)
            {
                dates.append(date)
            }

            guard let nextDate = self.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return dates
    }

    func generateDays(for dateInterval: DateInterval) -> [Date] {
        parseDates(
            inside: dateInterval,
            matching: dateComponents([.hour, .minute, .second], from: dateInterval.start)
        )
    }
}
