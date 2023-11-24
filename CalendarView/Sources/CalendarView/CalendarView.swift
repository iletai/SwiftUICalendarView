// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftUI
import SwiftUICommon

extension DateFormatter {
    static let monthAndYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return formatter
    }()

    static var day: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }

    static var weekDay: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter
    }
}

public struct CalendarView<DateView>: View where DateView: View {
    public let interval: DateInterval
    public var showHeaders = false
    public let onHeaderAppear: (Date) -> Void
    public let dateViewBuilder: (Date) -> DateView
    public var calendarLayout = Layout.vertical
    @Environment(\.sizeCategory) private var contentSize
    public var calendar = Calendar.current
    @State private var months = [Date]()
    @State private var days = [Date: [Date]]()

    private var columns: [GridItem] {
        let spacing: CGFloat = contentSize.isAccessibilityCategory ? 2 : 8
        return Array(repeating: GridItem(spacing: spacing), count: 7)
    }

    public init(
        interval: DateInterval,
        showHeaders: Bool = false,
        onHeaderAppear: @escaping (Date) -> Void,
        dateViewBuilder: @escaping (Date) -> DateView,
        calendarLayout: Layout = Layout.vertical,
        calendar: Foundation.Calendar = Calendar.current
    ) {
        self.interval = interval
        self.showHeaders = showHeaders
        self.onHeaderAppear = onHeaderAppear
        self.dateViewBuilder = dateViewBuilder
        self.calendarLayout = calendarLayout
        self.calendar = calendar
    }

    public var body: some View {
        layoutCalendar()
            .onAppear {
                months = calendar.parseDates(inside: interval)
                days = months.reduce(into: [:]) { current, month in
                    guard
                        let monthInterval = calendar.dateInterval(of: .month, for: month),
                        let monthFirstWeek = calendar.dateInterval(
                            of: .weekOfMonth, for: monthInterval.start),
                        let monthLastWeek = calendar.dateInterval(
                            of: .weekOfMonth, for: monthInterval.end)
                    else { return }

                    current[month] = calendar.parseDates(
                        inside: DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end),
                        matching: DateComponents(hour: 0, minute: 0, second: 0)
                    )
                }
            }
    }

    @ViewBuilder
    private func layoutCalendar() -> some View {
        switch calendarLayout {
        case .vertical:
            LazyVGrid(columns: columns) {
                buildContentCalendar()
            }
        case .horizontal:
            LazyHGrid(rows: columns) {
                buildContentCalendar()
            }
        }
    }

    private func buildContentCalendar() -> some View {
        ForEach(months, id: \.self) { month in
            Section(header: header(for: month)) {
                ForEach(days[month, default: []], id: \.self) { date in
                    if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                        dateViewBuilder(date).id(date)
                    } else {
                        dateViewBuilder(date).hidden()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func header(for month: Date) -> some View {
        if showHeaders {
            Text(DateFormatter.monthAndYear.string(from: month))
                .font(.title)
                .padding()
                .onAppear { onHeaderAppear(month) }
        }
    }
}

extension CalendarView: RootBuilder {
    public func setMonthView(month: [Date]) -> Self {
        mutating(\.months, value: month)
    }

    public func setIsShowHeader(_ isShow: Bool) -> Self {
        mutating(\.showHeaders, value: isShow)
    }

    public func firstWeekDay(_ first: Int) -> Self {
        mutating(\.calendar.firstWeekday, value: first)
    }

    public func calendarLocate(locale: Locale) -> Self {
        mutating(\.calendar.locale, value: locale)
    }

    public func calendarLayout(_ type: CalendarView.Layout) -> Self {
        mutating(\.calendarLayout, value: type)
    }
}

public extension CalendarView {
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

struct Calendar_Previews: PreviewProvider {
    static var previews: some View {
        let dateInterval = DateInterval(
            start: Date(timeIntervalSince1970: 1_617_316_527),
            end: Date(timeIntervalSince1970: 1_627_794_000)
        )
        CalendarView(
            interval: dateInterval,
            onHeaderAppear: { _ in
            },
            dateViewBuilder: { date in
                Text(date.parseString())
            }
        )
        .setIsShowHeader(true)
        .firstWeekDay(1)
        .calendarLayout(.vertical)
        .padding()
        .infinityFrame()
        .fixedSize()

    }
}

extension Date {
    public func parseString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
}
