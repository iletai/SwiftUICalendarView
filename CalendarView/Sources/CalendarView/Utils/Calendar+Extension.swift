//
//  File.swift
//  
//
//  Created by tailqt on 24/11/2023.
//

import SwiftUI

public extension Calendar {
    func parseDates(
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
}
