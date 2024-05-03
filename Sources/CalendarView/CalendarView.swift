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
        case .single:
            singleDayContentView()
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
                    yearData[month, default: []],
                    id: \.self
                ) { date in
                    if date.compare(.isSameMonth(month)) {
                        dateView(date)
                            .hightLightToDayView(date.isToday && hightLightToDay)
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
                    dateView(date)
                        .hightLightToDayView(date.isToday && hightLightToDay)
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
                    dateView(date)
                        .hightLightToDayView(date.isToday && hightLightToDay)
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

    @ViewBuilder
    private func singleDayContentView() -> some View {
        VStack(spacing: 0) {
            Text(date.dayName)
                .font(.headline)
            Text(date.toString(.date(.full)))
                .font(.headline)
                .maxWidthAble()
                .maxHeightAble()
        }
        .maxWidthAble()
        .maxHeightAble()
    }
}

extension View {
    @ViewBuilder
    func hightLightToDayView(_ isToday: Bool, _ color: Color = .orange) -> some View {
        if isToday {
            background(color.clipShape(Circle()))
        } else {
            self
        }
    }
}

// MARK: - Data For Calendar
extension CalendarView {
    fileprivate var yearData: YearData {
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

    fileprivate var columnGridLayout: [GridItem] {
        switch viewMode {
        case .single:
            return Array(
                repeating: GridItem(.flexible()),
                count: 1
            )
        default:
            return Array(
                repeating: GridItem(.flexible(), spacing: spaceBetweenColumns),
                count: CalendarDefine.kWeekDays
            )
        }
    }

    fileprivate var monthData: MonthDateData {
        generateDates(
            date: date,
            withComponent: .month,
            dateComponents: DateComponents(day: 1)
        )
    }

    fileprivate var weekData: WeekDataData {
        generateDates(
            date: date,
            withComponent: .weekOfMonth,
            dateComponents: DateComponents(day: 1)
        )
    }

    fileprivate var headerDates: [Date] {
        switch viewMode {
        case .month, .week:
            return Array(monthData.prefix(CalendarDefine.kWeekDays))
        case .year:
            return Array(
                yearData[date.dateAtStartOf(.year), default: []].prefix(CalendarDefine.kWeekDays)
            )
        case .single:
            return Array(arrayLiteral: date)
        }
    }
}
