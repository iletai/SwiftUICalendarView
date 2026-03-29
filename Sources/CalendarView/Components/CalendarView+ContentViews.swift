//
//  CalendarView+ContentViews.swift
//
//
//  Created by iletai on 24/11/2023.
//

import Foundation
import SwiftUI

// MARK: - Styled Date View Helper
extension CalendarView {
    /// Applies all standard modifiers and tap gesture to a date cell.
    @ViewBuilder
    func styledDateView(_ date: Date) -> some View {
        let cal = calendarOptions.calendar
        dateView(date)
            .fixedSize(horizontal: false, vertical: true)
            .highlightIfSelected(
                date,
                selectedDates: calendarOptions.selectedDates,
                calendar: cal
            )
            .applyDateBounds(
                date,
                minimum: calendarOptions.minimumDate,
                maximum: calendarOptions.maximumDate,
                calendar: cal
            )
            .highlightIfInRange(
                date,
                range: calendarOptions.selectedDateRange,
                calendar: cal
            )
            .eventIndicator(
                for: date,
                events: calendarOptions.eventDates,
                calendar: cal
            )
            .highlightTodayView(
                cal.isDateInToday(date)
                    && calendarOptions.isHighlightToday,
                calendarOptions.theme.todayColor
            )
            .calendarDateAccessibility(
                date: date,
                isSelected: false,
                calendar: cal
            )
            .opacity(
                calendarOptions.disabledDateRule?(date) == true
                    ? 0.3 : 1.0
            )
            .allowsHitTesting(
                calendarOptions.disabledDateRule?(date) != true
            )
            .onTapGesture { onSelected(date) }
    }
}

// MARK: - Body Content View
extension CalendarView {
    @ViewBuilder
    var bodyContentView: some View {
        switch calendarOptions.viewMode {
        case .month:
            monthContentView()
                .transition(calendarOptions.swapRight)
        case .year(let displayMode):
            switch displayMode {
            case .compact:
                yearContentCompactView()
                    .transition(calendarOptions.swapRight)
            case .full:
                yearContentView()
                    .transition(calendarOptions.swapLeft)
            }
        case .week:
            calendarWeekView()
                .transition(calendarOptions.swapLeft)
        case .single:
            singleDayContentView()
                .transition(calendarOptions.swapLeft)
        }
    }
}

// MARK: - Year Content Views
extension CalendarView {
    @ViewBuilder
    func yearContentView() -> some View {
        let calendar = calendarOptions.calendar
        ForEach(yearData.keys.sorted(), id: \.self) { month in
            Section(
                header:
                    LazyVStack(alignment: .leading) {
                        monthTitle(for: month)
                        Divider()
                            .allowVisibleWith(calendarOptions.isShowDivider)
                            .padding(.bottom, 4)
                        headerView(headerDates)
                    }
                    .maxWidthAble()
                    .id(month)
            ) {
                ForEach(
                    yearData[month, default: []]
                ) { calendarDay in
                    let date = calendarDay.date
                    if date.isSameMonth(as: month, using: calendar) {
                        styledDateView(date)
                    } else {
                        dateOutView(date)
                            .allowVisibleWith(calendarOptions.isShowDateOut)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func yearContentCompactView() -> some View {
        let calendar = calendarOptions.calendar
        ForEach(yearData.keys.sorted(), id: \.self) { month in
            LazyVStack(alignment: .leading, spacing: .zero) {
                monthTitle(for: month)
                Divider()
                    .allowVisibleWith(calendarOptions.isShowDivider)
                    .padding(.bottom, 2)
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(
                            .flexible(), spacing: 0, alignment: .top
                        ),
                        count: CalendarDefine.kWeekDays
                    ),
                    alignment: .leading,
                    spacing: .zero
                ) {
                    ForEach(
                        yearData[month, default: []]
                    ) { calendarDay in
                        let date = calendarDay.date
                        if date.isSameMonth(
                            as: month, using: calendar
                        ) {
                            styledDateView(date)
                        } else {
                            dateOutView(date)
                                .allowVisibleWith(
                                    calendarOptions.isShowDateOut
                                )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Month Title & Header
extension CalendarView {
    @ViewBuilder
    func monthTitle(for month: Date) -> some View {
        HStack {
            Spacer()
            if calendarOptions.enableMonthYearPicker {
                Button {
                    calendarOptions.onMonthYearChanged?(month)
                } label: {
                    HStack(spacing: 4) {
                        Text(
                            month.formatted(
                                as: "MMM yyyy",
                                locale: calendarOptions.calendar.locale
                            )
                            .uppercased()
                        )
                        .font(fontTitle)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                }
                .buttonStyle(.plain)
            } else {
                Text(
                    month.formatted(
                        as: "MMM",
                        locale: calendarOptions.calendar.locale
                    )
                    .uppercased()
                )
                .font(fontTitle)
            }
            Spacer()
        }
        .allowVisibleWith(calendarOptions.isShowHeader)
        .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    var weekDayAndMonthView: some View {
        VStack {
            monthTitle(for: date)
            Divider()
                .allowVisibleWith(calendarOptions.isShowDivider)
                .padding(.bottom, 4)
            headerView(headerDates)
        }
    }
}

// MARK: - Month & Week Content Views
extension CalendarView {
    @ViewBuilder
    func monthContentView() -> some View {
        let calendar = calendarOptions.calendar
        Section(header: weekDayAndMonthView) {
            ForEach(monthData) { calendarDay in
                let date = calendarDay.date
                if date.isSameMonth(as: self.date, using: calendar) {
                    styledDateView(date)
                } else {
                    dateOutView(date)
                        .allowVisibleWith(calendarOptions.isShowDateOut)
                }
            }
        }
    }

    @ViewBuilder
    func calendarWeekView() -> some View {
        let calendar = calendarOptions.calendar
        Section(header: weekDayAndMonthView) {
            ForEach(weekData) { calendarDay in
                let date = calendarDay.date
                if date.isSameWeek(
                    as: self.date, using: calendar
                ) {
                    styledDateView(date)
                } else {
                    dateOutView(date)
                        .allowVisibleWith(calendarOptions.isShowDateOut)
                }
            }
        }
    }

    @ViewBuilder
    func singleDayContentView() -> some View {
        VStack {
            headerView(headerDates)
            Divider()
                .allowVisibleWith(calendarOptions.isShowDivider)
            styledDateView(date)
        }
        .maxWidthAble()
        .maxHeightAble()
    }
}

// MARK: - Background
extension CalendarView {
    @ViewBuilder
    var backgroundCalendar: some View {
        switch calendarOptions.backgroundStatus {
        case .visible(let cornerRadius, let backgroundColor):
            backgroundColor.withRoundedCorner(cornerRadius)
        case .image(let imageName):
            Image(imageName)
                .resizable()
                .scaledToFill()
                .clipped()
        case .hidden:
            EmptyView()
        }
    }
}
