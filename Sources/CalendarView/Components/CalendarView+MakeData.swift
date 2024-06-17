//
//  CalendarView+MakeData.swift
//
//
//  Created by Lê Quang Trọng Tài on 1/1/24.
//

import Foundation
import SwiftDate
import SwiftUI

extension CalendarView {
    /// Generates an array of dates based on the given parameters.
    ///
    /// - Parameters:
    ///   - date: The base date.
    ///   - withComponent: The calendar component to generate dates for. Default is `.month`.
    ///   - dateComponents: The date components to increment by.
    /// - Returns: An array of dates.
    func generateDates(
        date: Date,
        withComponent: Calendar.Component = .month,
        dateComponents: DateComponents
    ) -> [Date] {
        SwiftDate.defaultRegion = Region(calendar: calendarOptions.calendar)
        let dateStart = date.dateAtStartOf(withComponent)
        let dateEnd = date.dateAtEndOf(withComponent)
        let dateStartRegion = DateInRegion(
            dateStart.dateAt(.startOfWeek),
            region: .currentIn(calendar: calendarOptions.calendar)
        )
        let dateEndRegion = DateInRegion(
            dateEnd.dateAt(.endOfWeek),
            region: .currentIn(calendar: calendarOptions.calendar)
        )
        let dates = DateInRegion.enumerateDates(
            from: dateStartRegion,
            to: dateEndRegion,
            increment: dateComponents
        ).map { $0.date }
        return dates
    }
}

// MARK: - Data For Calendar
extension CalendarView {
    /// Computes the year data for the calendar.
    var yearData: YearData {
        DateInRegion.enumerateDates(
            from: date.startOfYear(calendarOptions.calendar),
            to: date.endOfYear(calendarOptions.calendar),
            increment: DateComponents(month: 1)
        )
        .map {
            $0.date
        }
        .reduce(into: [:]) { month, date in
            month[date] = generateDates(
                date: date.startOfMonth(calendarOptions.calendar).date,
                dateComponents: CalendarViewMode.month.dateComponent
            )
        }
    }

    /// Computes the grid layout for the calendar columns.
    var columnGridLayout: [GridItem] {
        switch calendarOptions.viewMode {
        case .single:
            return Array(
                repeating: GridItem(.flexible()),
                count: 1
            )
        case .year(let mode):
        switch mode {
        case .compact:
            return Array(
                repeating: GridItem(.flexible(), spacing: calendarOptions.spaceBetweenColumns, alignment: .top),
                count: calendarOptions.compactMonthCount
            )
        case .full:
                return Array(
                    repeating: GridItem(.flexible(), spacing: calendarOptions.spaceBetweenColumns, alignment: .top),
                    count: CalendarDefine.kWeekDays
                )
        }
        default:
            return Array(
                repeating: GridItem(.flexible(), spacing: calendarOptions.spaceBetweenColumns, alignment: .top),
                count: CalendarDefine.kWeekDays
            )
        }
    }

    /// Computes the month data for the calendar.
    var monthData: MonthDateData {
        generateDates(
            date: date,
            withComponent: .month,
            dateComponents: DateComponents(day: 1)
        )
    }

    /// Computes the week data for the calendar.
    var weekData: WeekDataData {
        generateDates(
            date: date,
            withComponent: .weekOfMonth,
            dateComponents: DateComponents(day: 1)
        )
    }

    /// Computes the header dates for the calendar.
    var headerDates: [Date] {
        switch calendarOptions.viewMode {
        case .month, .week:
            return Array(monthData.prefix(CalendarDefine.kWeekDays))
        case .year:
            return Array(
                yearData[date.dateAtStartOf(.year), default: []].prefix(CalendarDefine.kWeekDays)
            )
        case .single:
            return [date]
        }
    }

    var fontTitle: Font {
        switch calendarOptions.viewMode {
        case .month,
        .single,
        .year(.full):
            return .footnote.bold()
        case .year(.compact):
            return .system(size: 10, weight: .semibold)
        default: return .footnote.bold()
        }
    }
}
