//
//  CalendarView.swift
//  CalendarView
//
//  Created by iletai on 24/11/2023.
//

import Foundation
import SwiftDate
import SwiftUI

@MainActor
public struct CalendarView<
    DateView: View,
    HeaderView: View,
    DateOutView: View
>: View {
    public typealias OnSelectedDate = (Date) -> Void
    public typealias OnEndDragAction = (Direction, CalendarViewMode) -> Void
    typealias YearData = [Date: [Date]]
    typealias MonthDateData = [Date]
    typealias WeekDataData = [Date]

    var date = Date()
    var showHeaders = false
    var showDateOut = true
    var showDivider = true
    var hightLightToDay = true

    // MARK: - View Builder
    let dateView: (Date) -> DateView
    let headerView: ([Date]) -> HeaderView
    let dateOutView: (Date) -> DateOutView

    var calendar = Calendar.gregorian
    var backgroundStatus = Background.hidden
    var spacingBetweenDay = 8.0
    var viewMode = CalendarViewMode.month
    var spaceBetweenColumns = 8.0
    var pinedHeaderView = PinnedScrollableViews()
    var onSelected: OnSelectedDate = { _ in }

    @GestureState var isGestureFinished = true
    var onDraggingEnded: OnEndDragAction?

    private var swipeGesture: some Gesture {
        DragGesture(
            minimumDistance: CalendarDefine.kDistaneSwipeBack,
            coordinateSpace: .global
        )
        .updating($isGestureFinished) { _, state, _ in
            state = false
        }
        .onEnded { endedGesture in
            if (endedGesture.location.x - endedGesture.startLocation.x) > 0 {
                onDraggingEnded?(.backward, viewMode)
            } else {
                onDraggingEnded?(.forward, viewMode)
            }
        }
    }

    public init(
        date: Date,
        @ViewBuilder dateView: @escaping (Date) -> DateView,
        @ViewBuilder headerView: @escaping ([Date]) -> HeaderView,
        @ViewBuilder dateOutView: @escaping (Date) -> DateOutView,
        calendar: Calendar = Calendar.gregorian
    ) {
        self.dateView = dateView
        self.calendar = calendar
        self.headerView = headerView
        self.dateOutView = dateOutView
        self.date = date
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(
                columns: columnGridLayout,
                spacing: spacingBetweenDay,
                pinnedViews: pinedHeaderView
            ) {
                bodyContentView
            }
            .marginDefault()
            .background(backgroundCalendar)
            .highPriorityGesture(swipeGesture)
            .onChange(of: isGestureFinished) { _ in }
        }
        .scrollIndicators(viewMode.enableScrollIndicator)
        .scrollDisabled(viewMode.isDisableScroll)
        .frameInfinity()
    }
}

// MARK: - ViewBuilder Private API
extension CalendarView {
    @ViewBuilder
    private var bodyContentView: some View {
        switch viewMode {
        case .month:
            monthContentView()
        case .year:
            yearContentView()
        case .week:
            calendarWeekView()
        }
    }

    @ViewBuilder
    fileprivate func yearContentView() -> some View {
        ForEach(yearData.keys.sorted(), id: \.self) { month in
            Section(
                header:
                    LazyVStack {
                        HStack {
                            Spacer()
                            Text(month.monthName(.defaultStandalone) + " \(month.year)")
                                .font(.footnote)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .opacity(showHeaders ? 1.0 : 0.0)
                        if showDivider {
                            Divider()
                        }
                        headerView(headerDates)
                    }
                    .maxWidthAble()
            ) {
                ForEach(
                    yearData[month, default: []], id: \.self
                ) { date in
                    if date.isInside(date: date, granularity: .month) {
                        if date.isToday, hightLightToDay {
                            dateView(date).hightLightToDayView()
                        } else {
                            dateView(date)
                                .onTapGesture {
                                    onSelected(date)
                                }
                        }
                    } else {
                        dateOutView(date)
                            .opacity(showDateOut ? 1.0 : 0.0)
                    }
                }
            }
        }
    }

    @ViewBuilder
    fileprivate func monthTitle(for month: Date) -> some View {
        HStack {
            Spacer()
            Text(month.monthName(.defaultStandalone) + " \(month.year)")
                .font(.footnote)
                .fontWeight(.bold)
            Spacer()
        }
        .opacity(showHeaders ? 1.0 : 0.0)
    }

    @ViewBuilder
    fileprivate var backgroundCalendar: some View {
        if case let .visible(conner, backgroundColor) = backgroundStatus {
            backgroundColor.withRounderConner(conner)
        }
    }

    @ViewBuilder
    fileprivate func calendarWeekView() -> some View {
        Section(header: weekDayAndMonthView) {
            ForEach(weekData, id: \.self) { date in
                if date.compare(.isSameWeek(self.date)) {
                    if date.isToday, hightLightToDay {
                        dateView(date)
                            .hightLightToDayView()
                    } else {
                        dateView(date)
                    }
                } else {
                    dateOutView(date)
                        .opacity(showDateOut ? 1.0 : 0.0)
                }
            }
        }
    }

    @ViewBuilder
    fileprivate func monthContentView() -> some View {
        Section(header: weekDayAndMonthView) {
            ForEach(monthData, id: \.self) { date in
                if date.compare(.isSameMonth(self.date)) {
                    if date.isToday, hightLightToDay {
                        dateView(date)
                            .hightLightToDayView()
                    } else {
                        dateView(date)
                    }
                } else {
                    dateOutView(date)
                        .opacity(showDateOut ? 1.0 : 0.0)
                }
            }
        }
    }

    @ViewBuilder
    private var weekDayAndMonthView: some View {
        VStack {
            monthTitle(for: date)
            if showDivider {
                Divider()
            }
            headerView(headerDates)
        }
    }
}

extension View {
    @ViewBuilder
    func hightLightToDayView(_ color: Color = .orange) -> some View {
        background(color.clipShape(Circle()))
    }
}

// MARK: - Data For Calendar
private extension CalendarView {
    var yearData: YearData {
        let dates = DateInRegion.enumerateDates(
            from: date.startOfYear(calendar),
            to: date.endOfYear(calendar),
            increment: DateComponents(month: 1)
        )
            .map {
                $0.date
            }
        return dates.reduce(into: [:]) { month, date in
            month[date] = generateDates(
                date: date.startOfMonth(calendar).date,
                dateComponents: CalendarViewMode.month.dateComponent
            )
        }
    }

    var columnGridLayout: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: spaceBetweenColumns),
            count: CalendarDefine.kWeekDays
        )
    }

    var monthData: MonthDateData {
        generateDates(
            date: date,
            withComponent: .month,
            dateComponents: DateComponents(day: 1)
        )
    }

    var weekData: WeekDataData {
        generateDates(
            date: date,
            withComponent: .weekOfMonth,
            dateComponents: DateComponents(day: 1)
        )
    }

    var headerDates: [Date] {
        switch viewMode {
        case .month, .week:
            return Array(monthData.prefix(CalendarDefine.kWeekDays))
        case .year:
            return Array(yearData[date.dateAtStartOf(.year), default: []].prefix(CalendarDefine.kWeekDays))
        }
    }
}
