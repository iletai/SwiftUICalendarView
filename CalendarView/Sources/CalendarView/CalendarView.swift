// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftUI
import SwiftUICommon

extension CalendarView: Equatable {
    public static func == (
        lhs: CalendarView<DateView, HeaderView, TitleView, DateOutView>,
        rhs: CalendarView<DateView, HeaderView, TitleView, DateOutView>
    ) -> Bool {
        lhs.calendar == rhs.calendar && lhs.date == rhs.date
    }

}

public struct CalendarView<DateView: View, HeaderView: View, TitleView: View, DateOutView: View>:
    View
{
    @State var date: Date = Date()
    let kWeekDefine = 7
    let interval: DateInterval
    var showHeaders = false
    // MARK: - View Builder
    var onHeaderAppear: (Date) -> Void
    let dateView: (Date) -> DateView
    let headerView: (Date) -> HeaderView
    let titleView: (Date) -> TitleView
    let dateOutView: (Date) -> DateOutView

    var calendarLayout = Layout.vertical
    var calendar: Calendar = .current
    @State var months = [Date]()
    @State var days = [Date: [Date]]()
    var weekDays = [Date]()
    var columns = Array(repeating: GridItem(), count: 7)

    public init(
        interval: DateInterval,
        showHeaders: Bool = true,
        onHeaderAppear: @escaping (Date) -> Void,
        @ViewBuilder dateView: @escaping (Date) -> DateView,
        @ViewBuilder headerView: @escaping (Date) -> HeaderView,
        @ViewBuilder titleView: @escaping (Date) -> TitleView,
        @ViewBuilder dateOutView: @escaping (Date) -> DateOutView,
        calendarLayout: CalendarView.Layout = CalendarView.Layout.vertical,
        calendar: Calendar = Calendar.current
    ) {
        self.interval = interval
        self.showHeaders = showHeaders
        self.onHeaderAppear = onHeaderAppear
        self.dateView = dateView
        self.calendarLayout = calendarLayout
        self.calendar = calendar
        self.headerView = headerView
        self.dateOutView = dateOutView
        self.titleView = titleView
    }

    public var body: some View {
        layoutCalendar
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
                // self.weekDays = makeDays()
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
    fileprivate var layoutCalendar: some View {
        switch calendarLayout {
        case .vertical:
            LazyVGrid(columns: columns) {
                ForEach(weekDays.prefix(kWeekDefine), id: \.self, content: headerView)
                buildContentCalendar()
            }
        case .horizontal:
            LazyHGrid(rows: columns) {
                buildContentCalendar()
            }
        }
    }

    @ViewBuilder
    fileprivate func buildContentCalendar() -> some View {
        ForEach(months, id: \.self) { month in
            Section(header: header(for: month)) {
                ForEach(days[month, default: []], id: \.self) { date in
                    if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                        dateView(date).id(date)
                    } else {
                        dateOutView(date)
                    }
                }
            }
        }
    }

    @ViewBuilder
    fileprivate func header(for month: Date) -> some View {
        if showHeaders {
            HStack {
                Text(DateFormatter.monthAndYear.string(from: month))
                    .font(.title)
                    .padding()
                    .onAppear { onHeaderAppear(month) }
                Spacer()
            }
        }
    }

    fileprivate func makeDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
            let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
            let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDays(for: dateInterval)
    }
}
