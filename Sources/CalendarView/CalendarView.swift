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
