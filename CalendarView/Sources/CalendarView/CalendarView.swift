// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftUI
import SwiftUICommon

@MainActor
public struct CalendarView<DateView: View, HeaderView: View, TitleView: View, DateOutView: View>:
    View
{
    let kWeekDefine = 7
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
    @State var months = [Date]()
    @State var days = [Date: [Date]]()
    var columns = Array(repeating: GridItem(), count: 7)

    public init(
        interval: DateInterval,
        showHeaders: Bool = true,
        @ViewBuilder dateView: @escaping (Date) -> DateView,
        @ViewBuilder headerView: @escaping (Date) -> HeaderView,
        @ViewBuilder titleView: @escaping (Date) -> TitleView,
        @ViewBuilder dateOutView: @escaping (Date) -> DateOutView,
        calendarLayout: CalendarView.Layout = CalendarView.Layout.vertical,
        calendar: Calendar = Calendar.current
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
        calendar: Calendar = Calendar.current
    ) {
        self.showHeaders = showHeaders
        self.dateView = dateView
        self.calendarLayout = calendarLayout
        self.calendar = calendar
        self.headerView = headerView
        self.dateOutView = dateOutView
        self.titleView = titleView
        self.interval = DateInterval(start: date.startOfMonth(), end: date.endOfMonth())
    }

    public var body: some View {
        LazyVGrid(columns: columns, spacing: 8, pinnedViews: [.sectionHeaders]) {
            buildContentCalendar()
                .frame(maxWidth: .infinity)
        }
        .marginAll3()
        .background(Color.gray.opacity(0.1).cornerRadius(20))
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
}

// MARK: - ViewBuilder Private API
extension CalendarView {

    @ViewBuilder
    fileprivate func buildContentCalendar() -> some View {
        ForEach(months, id: \.self) { month in
            Section(header: monthTitle(for: month)) {
                ForEach(days[month, default: []].prefix(kWeekDefine), id: \.self) {
                    headerView($0)
                }
                ForEach(days[month, default: []], id: \.self) { date in
                    if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                        dateView(date)
                    } else {
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
}

extension Date {
    public func startOfMonth() -> Date {
        return Calendar.current.date(
            from: Calendar
                .current
                .dateComponents(
                    [.year, .month],
                    from: Calendar.current.startOfDay(for: self)
                )
        )!
    }

    public func endOfMonth() -> Date {
        return Calendar.current.date(
            byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }

    public func endOfCurrentMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self)!
    }
}

extension CalendarView: Equatable {
    public static func == (lhs: CalendarView<DateView, HeaderView, TitleView, DateOutView>, rhs: CalendarView<DateView, HeaderView, TitleView, DateOutView>) -> Bool {
        lhs.interval == rhs.interval
        && lhs.calendar == rhs.calendar
        && lhs.days == rhs.days
        && lhs.months == rhs.months
    }
}
