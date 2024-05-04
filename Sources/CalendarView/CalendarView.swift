//
//  CalendarView.swift
//  CalendarView
//
//  Created by iletai on 24/11/2023.
//

import Foundation
import SwiftDate
import SwiftUI

/**
 A SwiftUI view that represents a calendar.

 Use the `CalendarView` struct to display a calendar with customizable date views, header views, and date out views.

 - Parameters:
 - DateView: The type of view to use for displaying individual dates.
 - HeaderView: The type of view to use for displaying the header containing the month and year.
 - DateOutView: The type of view to use for displaying dates outside the current month.

 - Note: The `CalendarView` struct is a generic type that takes three type parameters: `DateView`, `HeaderView`,
 and `DateOutView`.
 - These type parameters determine the types of views used for displaying dates, 
 headers, and dates outside the current month, respectively.

 - Note: The `CalendarView` struct conforms to the `View` protocol, which means it can be used as a view in SwiftUI.

 - Note: The `CalendarView` struct is annotated with the `@MainActor` attribute, 
 which ensures that the view is always accessed from the main actor's context.

 - Note: The `CalendarView` struct has several associated type aliases: `OnSelectedDate`, 
 `OnEndDragAction`, `YearData`, `MonthDateData`, and `WeekDataData`
 . These aliases are used to define the types of closures and data structures used by the `CalendarView`.

 - Note: The `CalendarView` struct has several properties, including 
 `date`, `calendarOptions`, `dateView`, `headerView`, `dateOutView`, `pinedHeaderView`, `onSelected`,
 `isGestureFinished`, and `onDraggingEnded`.
 These properties control the behavior and appearance of the calendar view.

 - Note: The `CalendarView` struct has a `body`
 property that returns a `View` representing the content of the calendar view.

 - Note: The `CalendarView` struct uses a `ScrollView` and a `LazyVGrid` to display the calendar's content. 
 The `ScrollView` provides scrolling behavior, while the `LazyVGrid` arranges the date views in a grid layout.

 - Note: The `CalendarView` struct uses a `DragGesture` to detect swipe gestures on the calendar view. 
 When a swipe gesture is detected,
 the `onDraggingEnded` closure is called with the direction of the swipe and the current view mode of the calendar.

 - Note: The `CalendarView` struct provides several modifiers, 
 such as `marginDefault()`, `background(_:)`, `simultaneousGesture(_:)`,
 `scrollIndicators(_:)`, `scrollDisabled(_:)`, and `frameInfinity()`,
 that can be used to customize the appearance and behavior of the calendar view.
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
    typealias YearData = [Date: [Date]]

    /// A type alias for an array of dates for a specific month.
    typealias MonthDateData = [Date]

    /// A type alias for an array of dates for a specific week.
    typealias WeekDataData = [Date]

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
    var pinedHeaderView = PinnedScrollableViews()

    /// The closure that is called when a date is selected.
    var onSelected: OnSelectedDate = { _ in }

    /// The gesture state for tracking the dragging state.
    @GestureState var isGestureFinished = true

    /// The closure that is called when dragging ends.
    var onDraggingEnded: OnEndDragAction?

    /// The swipe gesture for navigating between dates.
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

    // MARK: - Main Body View
    public var body: some View {
        ScrollView {
            LazyVGrid(
                columns: columnGridLayout,
                spacing: calendarOptions.spacingBetweenDay,
                pinnedViews: pinedHeaderView
            ) {
                bodyContentView
            }
            .marginDefault()
            .background(backgroundCalendar)
            .simultaneousGesture(swipeGesture)
        }
        .scrollIndicators(calendarOptions.viewMode.enableScrollIndicator)
        .scrollDisabled(calendarOptions.viewMode.isDisableScroll)
        .frameInfinity()
    }
}

// MARK: - ViewBuilder Private API
/**
 A SwiftUI view representing a calendar view.

 This view displays a calendar with different view modes such as month, year, week, and single day.
 The calendar view can be customized with various options 
 such as showing headers, dividers, highlighting today's date, and more.

 - Author: Tai Le
 - Version: 1.4.8
 */
extension CalendarView {
    /**
     Returns the body content view based on the current view mode.

     The body content view is determined by the `calendarOptions.viewMode` property.
     - Returns: A SwiftUI `View` representing the body content.
     */
    @ViewBuilder
    private var bodyContentView: some View {
        switch calendarOptions.viewMode {
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

    /**
     Returns the year content view.

     The year content view displays the calendar organized by months.
     - Returns: A SwiftUI `View` representing the year content.
     */
    @ViewBuilder
    fileprivate func yearContentView() -> some View {
        ForEach(yearData.keys.sorted(), id: \.self) { month in
            Section(
                header:
                    LazyVStack(alignment: .center) {
                        HStack {
                            Spacer()
                            Text(month.monthName(.defaultStandalone) + " \(month.year)")
                                .font(.footnote)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .allowVisibleWith(calendarOptions.isShowHeader)
                        Divider()
                            .allowVisibleWith(calendarOptions.isShowDivider)
                            .padding(.bottom, 4)
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
                            .hightLightToDayView(date.isToday && calendarOptions.isShowHightLightToDay)
                    } else {
                        dateOutView(date)
                            .allowVisibleWith(calendarOptions.isShowDateOut)
                    }
                }
            }
        }
    }

    /**
     Returns the month title view for a given month.

     The month title view displays the name of the month and the year.
     - Parameter month: The month for which to display the title.
     - Returns: A SwiftUI `View` representing the month title.
     */
    @ViewBuilder
    fileprivate func monthTitle(for month: Date) -> some View {
        HStack {
            Spacer()
            Text(month.monthName(.defaultStandalone) + " \(month.year)")
                .font(.footnote)
                .fontWeight(.bold)
            Spacer()
        }
        .allowVisibleWith(calendarOptions.isShowHeader)
    }

    /**
     Returns the background calendar view.

     The background calendar view displays the background color and corner radius of the calendar.
     - Returns: A SwiftUI `View` representing the background calendar.
     */
    @ViewBuilder
    fileprivate var backgroundCalendar: some View {
        if case let .visible(conner, backgroundColor) = calendarOptions.backgroundStatus {
            backgroundColor.withRounderConner(conner)
        }
    }

    /**
     Returns the calendar week view.

     The calendar week view displays the calendar organized by weeks.
     - Returns: A SwiftUI `View` representing the calendar week view.
     */
    @ViewBuilder
    fileprivate func calendarWeekView() -> some View {
        Section(header: weekDayAndMonthView) {
            ForEach(weekData, id: \.self) { date in
                if date.compare(.isSameWeek(self.date)) {
                    dateView(date)
                        .hightLightToDayView(date.isToday && calendarOptions.isShowHightLightToDay)
                } else {
                    dateOutView(date)
                        .allowVisibleWith(calendarOptions.isShowDateOut)
                }
            }
        }
    }

    /**
     Returns the month content view.

     The month content view displays the calendar organized by months.
     - Returns: A SwiftUI `View` representing the month content.
     */
    @ViewBuilder
    fileprivate func monthContentView() -> some View {
        Section(header: weekDayAndMonthView) {
            ForEach(monthData, id: \.self) { date in
                if date.compare(.isSameMonth(self.date)) {
                    dateView(date)
                        .hightLightToDayView(date.isToday && calendarOptions.isShowHightLightToDay)
                } else {
                    dateOutView(date)
                        .allowVisibleWith(calendarOptions.isShowDateOut)
                }
            }
        }
    }

    /**
     Returns the week day and month view.

     The week day and month view displays the month title, divider, and header view.
     - Returns: A SwiftUI `View` representing the week day and month view.
     */
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

    /**
     Returns the single day content view.

     The single day content view displays the header view and the date view for a single day.
     - Returns: A SwiftUI `View` representing the single day content.
     */
    @ViewBuilder
    private func singleDayContentView() -> some View {
        VStack {
            headerView(headerDates)
            Divider()
                .allowVisibleWith(calendarOptions.isShowDivider)
            dateView(date)
                .hightLightToDayView(date.isToday && calendarOptions.isShowHightLightToDay)
        }
        .maxWidthAble()
        .maxHeightAble()
    }
}
