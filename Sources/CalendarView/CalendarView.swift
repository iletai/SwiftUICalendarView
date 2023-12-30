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
public struct CalendarView<DateView: View, HeaderView: View, DateOutView: View>:
    View
{
    var date = Date()
    var showHeaders = false
    var showDateOut = true
    // MARK: - View Builder
    let dateView: (Date) -> DateView
    let headerView: ([Date]) -> HeaderView
    let dateOutView: (Date) -> DateOutView
    var calendar = Calendar.current
    var calendarBackgroundStatus = BackgroundCalendar.hidden
    var spacingBetweenDay = 8.0
    var viewMode = CalendarViewMode.month
    var spaceBetweenColumns = 8.0
    var pinedHeaderView = PinnedScrollableViews()
    var onSelected: (Date) -> Void = { _ in }

    @GestureState var isGestureFinished = true
    @State var listDay = [Date]()
    var onDraggingEnded: ((Direction) -> Void)?

    var swipeGesture: some Gesture {
        DragGesture(
            minimumDistance: CalendarDefine.kDistaneSwipeBack,
            coordinateSpace: .global
        )
        .updating($isGestureFinished) { _, state, _ in
            state = false
        }
        .onChanged { value in
            if value.translation.width >= 50 { // Increase this value
                onDraggingEnded?(.backward)
            }
        }
        .onEnded { endDrag in
            if endDrag.translation.width  > 100 { // Increase this value
                onDraggingEnded?(.forward)
            } else if endDrag.translation.width < -100 { // Increase this value
                onDraggingEnded?(.backward)
            }
        }
    }

    public init(
        date: Date,
        @ViewBuilder dateView: @escaping (Date) -> DateView,
        @ViewBuilder headerView: @escaping ([Date]) -> HeaderView,
        @ViewBuilder dateOutView: @escaping (Date) -> DateOutView,
        onSelectedDate: @escaping (Date) -> Void,
        calendar: Calendar = Calendar.gregorian
    ) {
        self.dateView = dateView
        self.calendar = calendar
        self.headerView = headerView
        self.dateOutView = dateOutView
        self.onSelected = onSelectedDate
        self.date = date
    }
    
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
        let dateStart = date.dateAtStartOf(withComponent)
        
        // Find the first day of the week for the first day of the month
        var startOfWeek: Date = Date()
        var interval: TimeInterval = 0
        _ = calendar.dateInterval(
            of: .weekOfYear,
            start: &startOfWeek,
            interval: &interval,
            for: dateStart
        )
        
        // Find the last day of the month
        let dateEnd = date.dateAtEndOf(withComponent)
        
        // Find the last day of the week for the last day of the month
        var endOfWeek: Date = Date()
        _ = calendar.dateInterval(
            of: .weekOfYear,
            start: &endOfWeek,
            interval: &interval,
            for: dateEnd
        )
        endOfWeek = endOfWeek.addingTimeInterval(interval - 1)
        
        let dateStartRegion = DateInRegion(
            startOfWeek,
            region: .currentIn(
                locale: Locales.vietnamese.toLocale(),
                calendar: calendar
            )
        )
        let dateEndRegion = DateInRegion(
            endOfWeek,
            region: .currentIn(
                locale: Locales.vietnamese.toLocale(),
                calendar: calendar
            )
        )
        var dates = DateInRegion.enumerateDates(
            from: dateStartRegion, to: dateEndRegion, increment: dateComponents
        ).map { $0.date }
        
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

    public var body: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(
                        .flexible(),
                        spacing: spaceBetweenColumns),
                    count: CalendarDefine.kWeekDays
                ),
                spacing: spacingBetweenDay,
                pinnedViews: [.sectionHeaders, .sectionFooters]
            ) {
                switch viewMode {
                case .month:
                    monthContentView()
                case .year:
                    yearContentView()
                case .week:
                    calendarWeekView()
                }
            }
            .padding(.all, 16)
            .background(backgroundCalendar)
            .highPriorityGesture(swipeGesture)
            .onChange(of: isGestureFinished) { value in }
        }
        .scrollIndicators(viewMode.enableScrollIndicator)
        .scrollDisabled(!viewMode.enableScroll)
        .frame(maxWidth: .infinity)
    }
}

extension CalendarView {
    /// `Direction` determines the direction of the swipe gesture
    public enum Direction {
        /// Swiping  from left to right
        case forward
        /// Swiping from right to left
        case backward
    }

    public enum BackgroundCalendar {
        case hidden
        case visible(CGFloat, Color)
    }

}

// MARK: - ViewBuilder Private API
extension CalendarView {
    @ViewBuilder
    fileprivate func yearContentView() -> some View {
        ForEach(chunkEachMonthsData().keys.sorted(), id: \.self) { month in
            Section(header:
                LazyVStack {
                    HStack {
                        Spacer()
                        Text(month.monthName(.defaultStandalone))
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    headerView(
                        Array(
                            chunkEachMonthsData()[month, default: []].prefix(CalendarDefine.kWeekDays)
                        )
                    )
                }
                .frame(maxWidth: .infinity)
            ) {
                ForEach(
                    chunkEachMonthsData()[month, default: []], id: \.self
                ) { date in
                    if date.isInside(date: month, granularity: .month) {
                        dateView(date)
                            .onTapGesture {
                                onSelected(date)
                            }
                    } else {
                        dateOutView(date)
                    }
                }
            }
        }
    }

    @ViewBuilder
    fileprivate func monthTitle(for month: Date) -> some View {
        HStack {
            Spacer()
            Text(month.monthName(.defaultStandalone))
                .font(.footnote)
                .fontWeight(.bold)
            Spacer()
        }
        .opacity(showHeaders ? 1.0 : 0.0)
    }

    @ViewBuilder
    fileprivate var backgroundCalendar: some View {
        if case let .visible(
            cornerRadius,
            backgroundColorCalendar
        ) = calendarBackgroundStatus {
            backgroundColorCalendar
                .clipShape(
                    RoundedRectangle(cornerRadius: cornerRadius)
                )
        }
    }

    @ViewBuilder
    fileprivate func calendarWeekView() -> some View {
        Section(header: weekDayAndMonthView) {
            ForEach(generateDateByViewMode(), id: \.self) { date in
                if date.compare(.isThisMonth) {
                    dateView(date)
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
            ForEach(generateDateByViewMode(), id: \.self) { date in
                if date.compare(.isThisMonth) {
                    dateView(date)
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
            headerView(
                Array(
                    generateDateByViewMode().prefix(CalendarDefine.kWeekDays)
                )
            )
        }
    }
}
