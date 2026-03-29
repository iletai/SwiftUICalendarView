//
//  CalendarView.swift
//  CalendarView
//
//  Created by iletai on 24/11/2023.
//

import Foundation
import SwiftUI

/**
 A SwiftUI view that represents a calendar.

 Use the `CalendarView` struct to display a calendar with customizable date views,
 header views, and date out views.

 - Parameters:
   - DateView: The type of view to use for displaying individual dates.
   - HeaderView: The type of view to use for displaying the header.
   - DateOutView: The type of view to use for displaying dates outside the current month.
 */
@MainActor
public struct CalendarView<
    DateView: View,
    HeaderView: View,
    DateOutView: View
>: View {
    // MARK: - Type Aliases
    /// A closure type that is called when a date is selected.
    public typealias OnSelectedDate = (Date) -> Void

    /// A closure type that is called when dragging ends.
    public typealias OnEndDragAction = (Direction, CalendarViewMode) -> Void

    /// A type alias for a dictionary that stores the dates for each year.
    typealias YearData = [Date: [CalendarDay]]

    /// A type alias for an array of dates for a specific month.
    typealias MonthDateData = [CalendarDay]

    /// A type alias for an array of dates for a specific week.
    typealias WeekDataData = [CalendarDay]

    // MARK: - Properties

    /// The selected date.
    var date = Date()

    /// The options for the calendar view.
    var calendarOptions: CalendarViewOption

    // MARK: - View Builder

    /// The view builder for the date view.
    let dateView: (Date) -> DateView

    /// The view builder for the header view.
    let headerView: ([Date]) -> HeaderView

    /// The view builder for the date out view.
    let dateOutView: (Date) -> DateOutView

    /// The pinned header view.
    var pinnedHeaderView = PinnedScrollableViews()

    /// The closure that is called when a date is selected.
    var onSelected: OnSelectedDate = { _ in }

    /// The gesture state for tracking the dragging state.
    @GestureState var isGestureFinished = true

    /// The closure that is called when dragging ends.
    var onDraggingEnded: OnEndDragAction?

    /// An optional binding to the selected date.
    var dateBinding: Binding<Date>?

    /// The swipe gesture for navigating between dates.
    private var swipeGesture: some Gesture {
        DragGesture(
            minimumDistance: CalendarDefine.kSwipeDistance,
            coordinateSpace: .global
        )
        .updating($isGestureFinished) { _, state, _ in
            state = false
        }
        .onEnded { endedGesture in
            if (endedGesture.location.x - endedGesture.startLocation.x) > 0 {
                onDraggingEnded?(.backward, calendarOptions.viewMode)
            } else {
                onDraggingEnded?(.forward, calendarOptions.viewMode)
            }
        }
    }

    // MARK: - Initializer

    /**
     Initializes a new calendar view.

     - Parameters:
       - date: The selected date.
       - dateView: The view builder for the date view.
       - headerView: The view builder for the header view.
       - dateOutView: The view builder for the date out view.
     */
    public init(
        date: Date,
        @ViewBuilder dateView: @escaping (Date) -> DateView,
        @ViewBuilder headerView: @escaping ([Date]) -> HeaderView,
        @ViewBuilder dateOutView: @escaping (Date) -> DateOutView
    ) {
        self.dateView = dateView
        self.headerView = headerView
        self.dateOutView = dateOutView
        self.date = date
        self.calendarOptions = .defaultOption
    }

    /**
     Initializes a new calendar view with a date selection callback.

     - Parameters:
       - date: The selected date.
       - dateView: The view builder for the date view.
       - headerView: The view builder for the header view.
       - dateOutView: The view builder for the date out view.
       - onSelectedDate: A closure called when a date is selected.
     */
    public init(
        date: Date,
        @ViewBuilder dateView: @escaping (Date) -> DateView,
        @ViewBuilder headerView: @escaping ([Date]) -> HeaderView,
        @ViewBuilder dateOutView: @escaping (Date) -> DateOutView,
        onSelectedDate: @escaping OnSelectedDate
    ) {
        self.init(
            date: date,
            dateView: dateView,
            headerView: headerView,
            dateOutView: dateOutView
        )
        self.onSelected = onSelectedDate
    }

    /**
     Initializes a new calendar view with a binding to the selected date.

     When a date is tapped, the binding is automatically updated.

     - Parameters:
       - selectedDate: A binding to the selected date.
       - dateView: The view builder for the date view.
       - headerView: The view builder for the header view.
       - dateOutView: The view builder for the date out view.
     */
    public init(
        selectedDate: Binding<Date>,
        @ViewBuilder dateView: @escaping (Date) -> DateView,
        @ViewBuilder headerView: @escaping ([Date]) -> HeaderView,
        @ViewBuilder dateOutView: @escaping (Date) -> DateOutView
    ) {
        self.init(
            date: selectedDate.wrappedValue,
            dateView: dateView,
            headerView: headerView,
            dateOutView: dateOutView
        )
        self.dateBinding = selectedDate
        self.onSelected = { date in
            selectedDate.wrappedValue = date
        }
    }

    // MARK: - Main Body View
    public var body: some View {
        ScrollViewReader { proxy in
            LazyVGrid(
                columns: columnGridLayout,
                spacing: calendarOptions.spacingBetweenDay,
                pinnedViews: pinnedHeaderView
            ) {
                bodyContentView
            }
            .onAppear {
                if let scrollDate = calendarOptions.scrollToDateOnAppear {
                    withAnimation {
                        proxy.scrollTo(
                            scrollDate.startOfMonth(using: calendarOptions.calendar),
                            anchor: .top
                        )
                    }
                }
            }
        }
        .highPriorityGesture(swipeGesture)
        .padding(.all, calendarOptions.contentPadding)
        .background(backgroundCalendar)
        .animation(calendarOptions.swapAnimation, value: calendarOptions.viewMode)
        .overlay(alignment: .bottomTrailing) {
            if calendarOptions.showTodayButton {
                Button {
                    calendarOptions.onTodayTapped?()
                } label: {
                    Text("Today")
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
                .padding(8)
            }
        }
    }
}

// MARK: - ViewBuilder Private API
extension CalendarView {
    @ViewBuilder
    private var bodyContentView: some View {
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

    @ViewBuilder
    fileprivate func yearContentView() -> some View {
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
                        dateView(date)
                            .fixedSize(horizontal: false, vertical: true)
                            .highlightIfSelected(date, selectedDates: calendarOptions.selectedDates, calendar: calendarOptions.calendar)
                            .applyDateBounds(date, minimum: calendarOptions.minimumDate, maximum: calendarOptions.maximumDate, calendar: calendarOptions.calendar)
                            .highlightIfInRange(date, range: calendarOptions.selectedDateRange)
                            .eventIndicator(for: date, events: calendarOptions.eventDates)
                            .highlightTodayView(
                                calendar.isDateInToday(date)
                                && calendarOptions.isHighlightToday,
                                calendarOptions.theme.todayColor
                                )
                            .calendarDateAccessibility(
                                date: date,
                                isSelected: false,
                                calendar: calendar
                            )
                            .opacity(calendarOptions.disabledDateRule?(date) == true ? 0.3 : 1.0)
                            .allowsHitTesting(calendarOptions.disabledDateRule?(date) != true)
                    } else {
                        dateOutView(date)
                            .allowVisibleWith(calendarOptions.isShowDateOut)
                    }
                }
            }
        }
    }

    @ViewBuilder
    fileprivate func yearContentCompactView() -> some View {
        let calendar = calendarOptions.calendar
        ForEach(yearData.keys.sorted(), id: \.self) { month in
            LazyVStack(alignment: .leading, spacing: .zero) {
                monthTitle(for: month)
                Divider()
                    .allowVisibleWith(calendarOptions.isShowDivider)
                    .padding(.bottom, 2)
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: 0, alignment: .top),
                        count: CalendarDefine.kWeekDays
                    ),
                    alignment: .leading,
                    spacing: .zero
                ) {
                    ForEach(
                        yearData[month, default: []]
                    ) { calendarDay in
                        let date = calendarDay.date
                        if date.isSameMonth(as: month, using: calendar) {
                            dateView(date)
                                .fixedSize(horizontal: false, vertical: true)
                                .highlightIfSelected(date, selectedDates: calendarOptions.selectedDates, calendar: calendarOptions.calendar)
                                .applyDateBounds(date, minimum: calendarOptions.minimumDate, maximum: calendarOptions.maximumDate, calendar: calendarOptions.calendar)
                                .highlightIfInRange(date, range: calendarOptions.selectedDateRange)
                                .eventIndicator(for: date, events: calendarOptions.eventDates)
                                .highlightTodayView(
                                    calendar.isDateInToday(date)
                                    && calendarOptions.isHighlightToday,
                                    calendarOptions.theme.todayColor
                                    )
                                .calendarDateAccessibility(
                                    date: date,
                                    isSelected: false,
                                    calendar: calendar
                                )
                                .opacity(calendarOptions.disabledDateRule?(date) == true ? 0.3 : 1.0)
                                .allowsHitTesting(calendarOptions.disabledDateRule?(date) != true)
                        } else {
                            dateOutView(date)
                                .allowVisibleWith(calendarOptions.isShowDateOut)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    fileprivate func monthTitle(for month: Date) -> some View {
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
    fileprivate var backgroundCalendar: some View {
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

    @ViewBuilder
    fileprivate func calendarWeekView() -> some View {
        let calendar = calendarOptions.calendar
        Section(header: weekDayAndMonthView) {
            ForEach(weekData) { calendarDay in
                let date = calendarDay.date
                if date.isSameWeek(as: self.date, using: calendar) {
                    dateView(date)
                        .fixedSize(horizontal: false, vertical: true)
                        .highlightIfSelected(date, selectedDates: calendarOptions.selectedDates, calendar: calendarOptions.calendar)
                        .applyDateBounds(date, minimum: calendarOptions.minimumDate, maximum: calendarOptions.maximumDate, calendar: calendarOptions.calendar)
                        .highlightIfInRange(date, range: calendarOptions.selectedDateRange)
                        .eventIndicator(for: date, events: calendarOptions.eventDates)
                        .highlightTodayView(
                            calendar.isDateInToday(date)
                            && calendarOptions.isHighlightToday,
                            calendarOptions.theme.todayColor
                            )
                        .calendarDateAccessibility(
                            date: date,
                            isSelected: false,
                            calendar: calendar
                        )
                        .opacity(calendarOptions.disabledDateRule?(date) == true ? 0.3 : 1.0)
                        .allowsHitTesting(calendarOptions.disabledDateRule?(date) != true)
                } else {
                    dateOutView(date)
                        .allowVisibleWith(calendarOptions.isShowDateOut)
                }
            }
        }
    }

    @ViewBuilder
    fileprivate func monthContentView() -> some View {
        let calendar = calendarOptions.calendar
        Section(header: weekDayAndMonthView) {
            ForEach(monthData) { calendarDay in
                let date = calendarDay.date
                if date.isSameMonth(as: self.date, using: calendar) {
                    dateView(date)
                        .fixedSize(horizontal: false, vertical: true)
                        .highlightIfSelected(date, selectedDates: calendarOptions.selectedDates, calendar: calendarOptions.calendar)
                        .applyDateBounds(date, minimum: calendarOptions.minimumDate, maximum: calendarOptions.maximumDate, calendar: calendarOptions.calendar)
                        .highlightIfInRange(date, range: calendarOptions.selectedDateRange)
                        .eventIndicator(for: date, events: calendarOptions.eventDates)
                        .highlightTodayView(
                            calendar.isDateInToday(date)
                            && calendarOptions.isHighlightToday,
                            calendarOptions.theme.todayColor
                            )
                        .calendarDateAccessibility(
                            date: date,
                            isSelected: false,
                            calendar: calendar
                        )
                        .opacity(calendarOptions.disabledDateRule?(date) == true ? 0.3 : 1.0)
                        .allowsHitTesting(calendarOptions.disabledDateRule?(date) != true)
                } else {
                    dateOutView(date)
                        .allowVisibleWith(calendarOptions.isShowDateOut)
                }
            }
        }
    }

    @ViewBuilder
    private var weekDayAndMonthView: some View {
        VStack {
            monthTitle(for: date)
            Divider()
                .allowVisibleWith(calendarOptions.isShowDivider)
                .padding(.bottom, 4)
            headerView(headerDates)
        }
    }

    @ViewBuilder
    private func singleDayContentView() -> some View {
        let calendar = calendarOptions.calendar
        VStack {
            headerView(headerDates)
            Divider()
                .allowVisibleWith(calendarOptions.isShowDivider)
            dateView(date)
                .fixedSize(horizontal: false, vertical: true)
                .highlightIfSelected(date, selectedDates: calendarOptions.selectedDates, calendar: calendarOptions.calendar)
                .applyDateBounds(date, minimum: calendarOptions.minimumDate, maximum: calendarOptions.maximumDate, calendar: calendarOptions.calendar)
                .highlightIfInRange(date, range: calendarOptions.selectedDateRange)
                .eventIndicator(for: date, events: calendarOptions.eventDates)
                .highlightTodayView(
                    calendar.isDateInToday(date)
                    && calendarOptions.isHighlightToday,
                    calendarOptions.theme.todayColor
                    )
                .calendarDateAccessibility(
                    date: date,
                    isSelected: false,
                    calendar: calendar
                )
                .opacity(calendarOptions.disabledDateRule?(date) == true ? 0.3 : 1.0)
                .allowsHitTesting(calendarOptions.disabledDateRule?(date) != true)
        }
        .maxWidthAble()
        .maxHeightAble()
    }
}
