//
//  CalendarView+MakeData.swift
//
//
//  Created by Lê Quang Trọng Tài on 1/1/24.
//

import Foundation
import SwiftUI

extension CalendarView {
    /// Generates an array of dates for the calendar grid.
    ///
    /// - Parameters:
    ///   - date: The base date.
    ///   - withComponent: The calendar component to generate dates for. Default is `.month`.
    ///   - dateComponents: The date components to increment by.
    /// - Returns: An array of dates covering the full calendar grid.
    func generateDates(
        date: Date,
        withComponent: Calendar.Component = .month,
        dateComponents: DateComponents
    ) -> [CalendarDay] {
        let calendar = calendarOptions.calendar
        let componentStart = date.startOf(withComponent, using: calendar)
        let componentEnd = date.endOf(withComponent, using: calendar)
        let gridStart = componentStart.startOfWeek(using: calendar)
        let gridEnd = componentEnd.endOfWeek(using: calendar)
        let dates = calendar.enumerateDates(
            from: gridStart,
            to: gridEnd,
            increment: dateComponents
        )
        return dates.map { CalendarDay(date: $0, monthContext: date) }
    }
}

// MARK: - Data For Calendar
extension CalendarView {
    /// Computes the year data for the calendar.
    var yearData: YearData {
        let calendar = calendarOptions.calendar
        let yearStart = date.startOfYear(using: calendar)
        let yearEnd = date.endOfYear(using: calendar)
        let months = calendar.enumerateDates(
            from: yearStart,
            to: yearEnd,
            increment: DateComponents(month: 1)
        )
        return months.reduce(into: [:]) { result, monthDate in
            let monthStart = monthDate.startOfMonth(using: calendar)
            result[monthDate] = generateDates(
                date: monthStart,
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
                    repeating: GridItem(
                        .flexible(),
                        spacing: calendarOptions.spaceBetweenColumns,
                        alignment: .top
                    ),
                    count: calendarOptions.compactMonthCount
                )
            case .full:
                return Array(
                    repeating: GridItem(
                        .flexible(),
                        spacing: calendarOptions.spaceBetweenColumns,
                        alignment: .top
                    ),
                    count: CalendarDefine.kWeekDays
                )
            }
        default:
            return Array(
                repeating: GridItem(
                    .flexible(),
                    spacing: calendarOptions.spaceBetweenColumns,
                    alignment: .top
                ),
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
            return Array(monthData.prefix(CalendarDefine.kWeekDays).map(\.date))
        case .year:
            let yearStart = date.startOfYear(using: calendarOptions.calendar)
            return Array(
                yearData[yearStart, default: []].prefix(CalendarDefine.kWeekDays).map(\.date)
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
            return calendarOptions.theme.titleFont
        case .year(.compact):
            return .system(size: 10, weight: .semibold)
        default: return calendarOptions.theme.titleFont
        }
    }
}
