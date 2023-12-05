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
    let headerView: (Date) -> HeaderView
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
    var onDraggingEnded: (() -> Void)?
    var swipeGesture: some Gesture {
        DragGesture(minimumDistance: CalendarDefine.kDistaneSwipeBack, coordinateSpace: .global)
            .updating($isGestureFinished) { _, state, _ in
                state = false
            }
            .onChanged({ value in
            })
    }

    public init(
        date: Date,
        @ViewBuilder dateView: @escaping (Date) -> DateView,
        @ViewBuilder headerView: @escaping (Date) -> HeaderView,
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
            .onChange(of: isGestureFinished) { _, value in
                if value {
                    // onDraggingEnded?()
                }
            }
            

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
                        Button {
                        } label: {
                            Text("Previous")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.gray)
                        }
                        Spacer()
                        Text(month.monthName(.defaultStandalone))
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                        } label: {
                            Text("Next")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(
                                .flexible(),
                                spacing: spaceBetweenColumns),
                            count: CalendarDefine.kWeekDays
                        ),
                        spacing: spacingBetweenDay
                    ) {
                        ForEach(chunkEachMonthsData()[
                                month, default: []
                            ].prefix(CalendarDefine.kWeekDays),
                                id: \.self
                        ) {
                            headerView($0)
                        }
                    }
                }
            ) {
                ForEach(
                    chunkEachMonthsData()[month, default: []], id: \.self
                ) { date in
                    dateView(date)
                        .background(date.isToday ? .red : .clear)
                        .onTapGesture {
                            onSelected(date)
                        }
                }
            }
        }
    }

    @ViewBuilder
    fileprivate func monthTitle(for month: Date) -> some View {
        HStack {
            Button {
                // setDate(date.dateAt(.prevYear))
            } label: {
                Text("Previous")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.gray)
            }
            Spacer()
            Text(month.monthName(.defaultStandalone))
                .font(.footnote)
                .fontWeight(.bold)
            Spacer()
            Button {
                // setDate(date.dateAt(.prevYear))
            } label: {
                Text("Next")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.gray)
            }
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
            ForEach(
                generateDateByViewMode(),
                id: \.self
            ) { date in
                dateView(date)
            }
        }
    }

    @ViewBuilder
    fileprivate func monthContentView() -> some View {
        Section(header: weekDayAndMonthView) {
            ForEach(generateDateByViewMode(), id: \.self) { date in
                dateView(date)
            }
        }
    }

    @ViewBuilder
    fileprivate var weekDayAndMonthView: some View {
        VStack {
            monthTitle(for: date)
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(
                        .flexible(),
                        spacing: spaceBetweenColumns),
                    count: CalendarDefine.kWeekDays
                )
            ) {
                ForEach(
                    generateDateByViewMode()
                        .prefix(CalendarDefine.kWeekDays),
                    id: \.self
                ) {
                    headerView($0)
                }
            }
        }
    }
}
