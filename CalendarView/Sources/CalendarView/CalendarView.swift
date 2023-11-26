// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftUI
import SwiftUICommon
import SwiftDate

@MainActor
public struct CalendarView<DateView: View, HeaderView: View, TitleView: View, DateOutView: View>:
    View
{
    let interval: DateInterval
    var showHeaders = false
    var showDateOut = true

    // MARK: - View Builder
    let dateView: (Date) -> DateView
    let headerView: (Date) -> HeaderView
    let titleView: (Date) -> TitleView
    let dateOutView: (Date) -> DateOutView

    var calendarLayout = Layout.vertical
    var calendar = Calendar.current
    var calendarBackgroundStatus = BackgroundCalendar.hidden
    var spacingBetweenDay = 8.0
    var viewMode = ViewMode.month

    @State var months = [Date]()
    @State var days = [Date: [Date]]()
    var columns = Array(repeating: GridItem(), count: 7)
    @State var listDay = [Date]()
    public init(
        interval: DateInterval,
        showHeaders: Bool = true,
        @ViewBuilder dateView: @escaping (Date) -> DateView,
        @ViewBuilder headerView: @escaping (Date) -> HeaderView,
        @ViewBuilder titleView: @escaping (Date) -> TitleView,
        @ViewBuilder dateOutView: @escaping (Date) -> DateOutView,
        calendarLayout: CalendarView.Layout = CalendarView.Layout.vertical,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) {
        self.showHeaders = showHeaders
        self.dateView = dateView
        self.calendarLayout = calendarLayout
        self.calendar = calendar
        self.headerView = headerView
        self.dateOutView = dateOutView
        self.titleView = titleView
        self.interval = interval
    }

    public init(
        date: Date,
        showHeaders: Bool = true,
        @ViewBuilder dateView: @escaping (Date) -> DateView,
        @ViewBuilder headerView: @escaping (Date) -> HeaderView,
        @ViewBuilder titleView: @escaping (Date) -> TitleView,
        @ViewBuilder dateOutView: @escaping (Date) -> DateOutView,
        calendarLayout: CalendarView.Layout = CalendarView.Layout.vertical,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) {
        self.showHeaders = showHeaders
        self.dateView = dateView
        self.calendarLayout = calendarLayout
        self.calendar = calendar
        self.headerView = headerView
        self.dateOutView = dateOutView
        self.titleView = titleView
        self.interval = DateInterval(start: date.dateAtStartOf(.year), end: date.dateAtEndOf(.year))
    }

    public var body: some View {
        LazyVGrid(
            columns: columns,
            spacing: spacingBetweenDay,
            pinnedViews: [.sectionHeaders]
        ) {
            buildContentCalendar()
        }
        .marginAll3()
        .background(backgroundCalendar())
        .onAppear {
            self.months = calendar.parseDates(inside: interval)
            self.days = months.reduce(into: [:]) { current, month in
                guard
                    let monthInterval = calendar.dateInterval(of: .month, for: month),
                    let monthFirstWeek = calendar.dateInterval(
                        of: .weekOfMonth,
                        for: monthInterval.start
                    ),
                    let monthLastWeek = calendar.dateInterval(
                        of: .weekOfMonth,
                        for: monthInterval.end
                    )
                else {
                    return
                }

                current[month] = calendar.parseDates(
                    inside: DateInterval(
                        start: monthFirstWeek.start,
                        end: monthLastWeek.end
                    ),
                    matching: DateComponents(hour: 0, minute: 0, second: 0)
                )
            }
        }
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

    public enum Layout {
        case vertical
        case horizontal
    }

    public enum BackgroundCalendar {
        case hidden
        case visible(CGFloat, Color)
    }

    public enum ViewMode {
        case month
        case week
        case year

        var component: Calendar.Component {
            switch self {
            case .month:
                return .month
            case .week:
                return .weekOfMonth
            case .year:
                return .year
            }
        }

        var enableDayOut: Bool {
            switch self {
            case .month:
                return true
            case .week:
                return false
            case .year:
                return true
            }
        }
    }
}

// MARK: - ViewBuilder Private API
extension CalendarView {

    @ViewBuilder
    fileprivate func buildContentCalendar() -> some View {
        ForEach(months, id: \.self) { month in
            Section(header: monthTitle(for: month)) {
                ForEach(days[month, default: []].prefix(CalendarDefine.kWeekDays), id: \.self) {
                    headerView($0)
                }
                ForEach(days[month, default: []], id: \.self) { date in
                    if calendar.isDate(date, equalTo: month, toGranularity: viewMode.component) {
                        dateView(date)
                    } else {
                        if viewMode.enableDayOut {
                            if showDateOut {
                                dateOutView(date)
                            } else {
                                Circle()
                                    .fill(.gray)
                                    .frame(width: 4)
                                    .clipped()
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    fileprivate func monthTitle(for month: Date) -> some View {
        if showHeaders {
            HStack {
                Text(DateFormatter.monthAndYear.string(from: month))
                    .font(.headline)
                    .padding()
                Spacer()
            }
        }
    }

    @ViewBuilder
    fileprivate func backgroundCalendar() -> some View {
        if case let .visible(cornerRadius, backgroundColorCalendar) = calendarBackgroundStatus{
            backgroundColorCalendar.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

extension CalendarView: Equatable {
    public static func == (
        lhs: CalendarView<DateView, HeaderView, TitleView, DateOutView>,
        rhs: CalendarView<DateView, HeaderView, TitleView, DateOutView>
    ) -> Bool {
        lhs.interval == rhs.interval
        && lhs.calendar == rhs.calendar
        && lhs.days == rhs.days
        && lhs.months == rhs.months
    }
}
