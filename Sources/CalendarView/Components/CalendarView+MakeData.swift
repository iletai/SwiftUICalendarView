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
        SwiftDate.defaultRegion = Region(calendar: calendar)
        let dateStart = date.dateAtStartOf(withComponent)
        let dateEnd = date.dateAtEndOf(withComponent)
        let dateStartRegion = DateInRegion(
            dateStart.dateAt(.startOfWeek),
            region: .currentIn(calendar: calendar)
        )
        let dateEndRegion = DateInRegion(
            dateEnd.dateAt(.endOfWeek),
            region: .currentIn(calendar: calendar)
        )
        let dates = DateInRegion.enumerateDates(
            from: dateStartRegion,
            to: dateEndRegion,
            increment: dateComponents
        ).map { $0.date }
        return dates
    }

}
