//
//  CalendarView+ParseData.swift
//
//
//  Created by iletai on 30/11/2023.
//

import SwiftDate
import Foundation

extension CalendarView {
    /// Return list of date by ViewMode
    /// - Returns: [Date] With Type Year/Month/Week
    func generateDateByViewMode() -> [Date] {
        generateDates(
            date: date,
            withComponent: viewMode.component,
            dateComponents: viewMode.dateComponent
        )
    }

    func generateDates(
        date: Date,
        withComponent: Calendar.Component = .month,
        dateComponents: DateComponents
    ) -> [Date] {
        let dateStartRegion = DateInRegion(date.dateAtStartOf(withComponent), region: .current)
        let dateEndRegion = DateInRegion(date.dateAtEndOf(withComponent), region: .current)
        let dates = DateInRegion.enumerateDates(
            from: dateStartRegion, to: dateEndRegion, increment: dateComponents
        )
            .map {
                $0.date
            }
        return dates
    }

    func chunkEachMonthsData() -> [Date: [Date]] {
        generateDateByViewMode().reduce(into: [:]) { month, date in
            month[date] = generateDates(
                date: date,
                dateComponents: CalendarViewMode.month.dateComponent
            )
        }
    }
}
