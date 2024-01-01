//
//  CalendarView+MakeData.swift
//
//
//  Created by Lê Quang Trọng Tài on 1/1/24.
//

import Foundation
import SwiftDate

extension CalendarView {
    func generateDates(
        date: Date,
        withComponent: Calendar.Component = .month,
        dateComponents: DateComponents
    ) -> [Date] {
        let dateStart = date.dateAtStartOf(withComponent)
        var startOfWeek = Date()
        var interval: TimeInterval = 0
        _ = calendar.dateInterval(
            of: .weekOfMonth,
            start: &startOfWeek,
            interval: &interval,
            for: dateStart
        )
        startOfWeek = startOfWeek - 1
        let dateEnd = date.dateAtEndOf(withComponent)
        var endOfWeek = Date()
        _ = calendar.dateInterval(
            of: .weekOfMonth,
            start: &endOfWeek,
            interval: &interval,
            for: dateEnd
        )
        endOfWeek = endOfWeek.addingTimeInterval(interval - 1)

        let dateStartRegion = DateInRegion(
            startOfWeek,
            region: .current
        )
        let dateEndRegion = DateInRegion(
            endOfWeek,
            region: .current
        )
        var dates = DateInRegion.enumerateDates(
            from: dateStartRegion,
            to: dateEndRegion,
            increment: dateComponents
        ).map { $0.date }
        return dates
    }

}
