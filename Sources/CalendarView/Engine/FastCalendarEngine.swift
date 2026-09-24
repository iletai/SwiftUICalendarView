import Foundation

public enum FastCalendarEngine {
    public static func computeMonthMatrix(
        for baseDate: Date,
        calendar: Calendar,
        todayDate: Date = Date(),
        selectedKeySet: Set<Int> = [],
        rangeBounds: (startKey: Int?, endKey: Int?) = (nil, nil),
        disabledRule: (@Sendable (Date) -> Bool)? = nil,
        eventsMap: [Int: [CalendarEvent]] = [:]
    ) -> FastMonthMatrix {
        let cal = calendar
        let baseComps = cal.dateComponents([.year, .month], from: baseDate)
        guard let startOfMonth = cal.date(from: baseComps) else {
            return FastMonthMatrix(yearMonthKey: 0, monthDate: baseDate, monthTitle: "", days: [])
        }

        let firstWeekday = cal.component(.weekday, from: startOfMonth)
        let calFirstWeekday = cal.firstWeekday
        let leadDays = (firstWeekday - calFirstWeekday + 7) % 7
        let totalCells = 42

        guard let gridStartDate = cal.date(byAdding: .day, value: -leadDays, to: startOfMonth) else {
            return FastMonthMatrix(yearMonthKey: 0, monthDate: baseDate, monthTitle: "", days: [])
        }

        let todayKey = CalendarDateKey.key(for: todayDate, using: cal)
        let targetYear = baseComps.year ?? 0
        let targetMonth = baseComps.month ?? 0

        var days: [CalendarDayState] = []
        days.reserveCapacity(totalCells)

        for offset in 0..<totalCells {
            guard let currentDate = cal.date(byAdding: .day, value: offset, to: gridStartDate) else { continue }
            let comps = cal.dateComponents([.year, .month, .day], from: currentDate)
            let y = comps.year ?? 0
            let m = comps.month ?? 0
            let d = comps.day ?? 0
            let key = CalendarDateKey.makeKey(year: y, month: m, day: d)

            let isCurrentMonth = (y == targetYear && m == targetMonth)
            let isToday = (key == todayKey)
            let isSelected = selectedKeySet.contains(key)
            let isDisabled = disabledRule?(currentDate) ?? false

            var pos: RangeSelectionPosition = .none
            if let start = rangeBounds.startKey, let end = rangeBounds.endKey {
                if start == end && key == start {
                    pos = .singleDay
                } else if key == start {
                    pos = .rangeStart
                } else if key == end {
                    pos = .rangeEnd
                } else if key > start && key < end {
                    pos = .rangeMiddle
                }
            } else if let start = rangeBounds.startKey, key == start {
                pos = .singleDay
            }

            let cellEvents = eventsMap[key] ?? []

            days.append(
                CalendarDayState(
                    dateKey: key,
                    date: currentDate,
                    dayNumber: d,
                    isCurrentMonth: isCurrentMonth,
                    isToday: isToday,
                    isSelected: isSelected,
                    isSelectable: !isDisabled,
                    isDisabled: isDisabled,
                    rangePosition: pos,
                    events: cellEvents
                )
            )
        }

        let title = startOfMonth.formatted(.dateTime.year().month(.wide).locale(cal.locale ?? .current))

        return FastMonthMatrix(
            yearMonthKey: targetYear * 100 + targetMonth,
            monthDate: startOfMonth,
            monthTitle: title,
            days: days
        )
    }
}
