//
//  CalendarView+RootBuilder.swift
//
//
//  Created by iletai on 24/11/2023.
//

import Foundation

extension CalendarView: RootBuilder {
    public func setMonthView(month: [Date]) -> Self {
        mutating(\.months, value: month)
    }

    public func setIsShowHeader(_ isShow: Bool) -> Self {
        mutating(\.showHeaders, value: isShow)
    }

    public func firstWeekDay(_ first: Int) -> Self {
        mutating(\.calendar.firstWeekday, value: first)
    }

    public func calendarLocate(locale: Locale) -> Self {
        mutating(\.calendar.locale, value: locale)
    }

    public func calendarLayout(_ type: CalendarView.Layout) -> Self {
        mutating(\.calendarLayout, value: type)
    }

    public func nextMonth() -> Self {
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: date) {
            mutating(\.date, value: nextMonth)
        } else {
            mutating(\.date, value: date)
        }
    }

    public func showDateOut(_ isShow: Bool) -> Self {
        mutating(\.showDateOut, value: isShow)
    }
}
