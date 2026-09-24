//
//  CalendarView.swift
//  CalendarView
//
//  Created by iletai on 24/11/2023.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A high-performance, declarative calendar view for SwiftUI with native ergonomics.
public struct CalendarView<DayContent: View, HeaderContent: View, WeekdayContent: View>: View {
    @Environment(\.calendar) private var envCalendar
    @Environment(\.locale) private var envLocale
    @Environment(\.calendarViewMode) private var viewMode
    @Environment(\.calendarDisabledRule) private var disabledRule
    @Environment(\.calendarEvents) private var eventsMap
    @Environment(\.calendarHapticsEnabled) private var hapticsEnabled
    @Environment(\.calendarFirstWeekdayOverride) private var firstWeekdayOverride

    private var externalDisplayDate: Binding<Date>?
    @State private var internalDisplayDate: Date

    private let selectedKeySet: Set<Int>
    private let rangeBounds: (startKey: Int?, endKey: Int?)
    private let selectedKeySetProvider: ((Calendar) -> Set<Int>)?
    private let rangeBoundsProvider: ((Calendar) -> (startKey: Int?, endKey: Int?))?
    private let onDateTapped: (Date) -> Void

    private let dayContent: (CalendarDayState) -> DayContent
    private let headerContent: (FastMonthMatrix, @escaping () -> Void, @escaping () -> Void) -> HeaderContent
    private let weekdayContent: (Calendar) -> WeekdayContent

    private var currentDisplayDate: Binding<Date> {
        if let external = externalDisplayDate {
            return external
        }
        return $internalDisplayDate
    }

    // MARK: - Initializer (Custom ViewBuilder)
    public init(
        displayDate: Binding<Date>,
        selectedKeySet: Set<Int> = [],
        rangeBounds: (startKey: Int?, endKey: Int?) = (nil, nil),
        onDateTapped: @escaping (Date) -> Void = { _ in },
        @ViewBuilder dayCell: @escaping (CalendarDayState) -> DayContent,
        @ViewBuilder header: @escaping (FastMonthMatrix, @escaping () -> Void, @escaping () -> Void) -> HeaderContent,
        @ViewBuilder weekday: @escaping (Calendar) -> WeekdayContent
    ) {
        self.externalDisplayDate = displayDate
        self._internalDisplayDate = State(initialValue: displayDate.wrappedValue)
        self.selectedKeySet = selectedKeySet
        self.rangeBounds = rangeBounds
        self.selectedKeySetProvider = nil
        self.rangeBoundsProvider = nil
        self.onDateTapped = onDateTapped
        self.dayContent = dayCell
        self.headerContent = header
        self.weekdayContent = weekday
    }

    private init(
        displayDate: Binding<Date>?,
        internalDate: Date,
        selectedKeySet: Set<Int>,
        rangeBounds: (startKey: Int?, endKey: Int?),
        selectedKeySetProvider: ((Calendar) -> Set<Int>)?,
        rangeBoundsProvider: ((Calendar) -> (startKey: Int?, endKey: Int?))?,
        onDateTapped: @escaping (Date) -> Void,
        dayCell: @escaping (CalendarDayState) -> DayContent,
        header: @escaping (FastMonthMatrix, @escaping () -> Void, @escaping () -> Void) -> HeaderContent,
        weekday: @escaping (Calendar) -> WeekdayContent
    ) {
        self.externalDisplayDate = displayDate
        self._internalDisplayDate = State(initialValue: internalDate)
        self.selectedKeySet = selectedKeySet
        self.rangeBounds = rangeBounds
        self.selectedKeySetProvider = selectedKeySetProvider
        self.rangeBoundsProvider = rangeBoundsProvider
        self.onDateTapped = onDateTapped
        self.dayContent = dayCell
        self.headerContent = header
        self.weekdayContent = weekday
    }

    // MARK: - Body
    public var body: some View {
        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: currentDisplayDate.wrappedValue,
            calendar: effectiveCalendar,
            todayDate: Date(),
            selectedKeySet: computedSelectedKeySet,
            rangeBounds: computedRangeBounds,
            disabledRule: disabledRule,
            eventsMap: eventKeysMap
        )

        VStack(spacing: 12) {
            headerContent(matrix, { changeMonth(by: -1) }, { changeMonth(by: 1) })
            weekdayContent(effectiveCalendar)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                ForEach(matrix.days) { day in
                    dayContent(day)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard day.isSelectable else { return }
                            triggerHaptic()
                            onDateTapped(day.date)
                        }
                }
            }
            .padding(.horizontal, 8)
        }
    }

    // MARK: - Helpers
    private var effectiveCalendar: Calendar {
        var cal = envCalendar
        cal.locale = envLocale
        if let override = firstWeekdayOverride {
            switch override {
            case .sunday: cal.firstWeekday = 1
            case .monday: cal.firstWeekday = 2
            case .tuesday: cal.firstWeekday = 3
            case .wednesday: cal.firstWeekday = 4
            case .thursday: cal.firstWeekday = 5
            case .friday: cal.firstWeekday = 6
            case .saturday: cal.firstWeekday = 7
            @unknown default: break
            }
        }
        return cal
    }

    private var computedSelectedKeySet: Set<Int> {
        if let provider = selectedKeySetProvider {
            return provider(effectiveCalendar)
        }
        return selectedKeySet
    }

    private var computedRangeBounds: (startKey: Int?, endKey: Int?) {
        if let provider = rangeBoundsProvider {
            return provider(effectiveCalendar)
        }
        return rangeBounds
    }

    private var eventKeysMap: [Int: [CalendarEvent]] {
        var result: [Int: [CalendarEvent]] = [:]
        for (date, events) in eventsMap {
            let key = CalendarDateKey.key(for: date, using: effectiveCalendar)
            result[key, default: []].append(contentsOf: events)
        }
        return result
    }

    private func changeMonth(by value: Int) {
        if let newDate = effectiveCalendar.date(byAdding: .month, value: value, to: currentDisplayDate.wrappedValue) {
            currentDisplayDate.wrappedValue = newDate
        }
    }

    private func triggerHaptic() {
        #if os(iOS)
        if hapticsEnabled {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        #endif
    }
}

// MARK: - Slot Customization Modifiers
public extension CalendarView {
    func calendarDayCell<NewDayContent: View>(
        @ViewBuilder _ content: @escaping (CalendarDayState) -> NewDayContent
    ) -> CalendarView<NewDayContent, HeaderContent, WeekdayContent> {
        CalendarView<NewDayContent, HeaderContent, WeekdayContent>(
            displayDate: externalDisplayDate,
            internalDate: _internalDisplayDate.wrappedValue,
            selectedKeySet: selectedKeySet,
            rangeBounds: rangeBounds,
            selectedKeySetProvider: selectedKeySetProvider,
            rangeBoundsProvider: rangeBoundsProvider,
            onDateTapped: onDateTapped,
            dayCell: content,
            header: headerContent,
            weekday: weekdayContent
        )
    }

    func calendarHeader<NewHeaderContent: View>(
        @ViewBuilder _ content: @escaping (FastMonthMatrix, @escaping () -> Void, @escaping () -> Void) -> NewHeaderContent
    ) -> CalendarView<DayContent, NewHeaderContent, WeekdayContent> {
        CalendarView<DayContent, NewHeaderContent, WeekdayContent>(
            displayDate: externalDisplayDate,
            internalDate: _internalDisplayDate.wrappedValue,
            selectedKeySet: selectedKeySet,
            rangeBounds: rangeBounds,
            selectedKeySetProvider: selectedKeySetProvider,
            rangeBoundsProvider: rangeBoundsProvider,
            onDateTapped: onDateTapped,
            dayCell: dayContent,
            header: content,
            weekday: weekdayContent
        )
    }

    func calendarWeekdayHeader<NewWeekdayContent: View>(
        @ViewBuilder _ content: @escaping (Calendar) -> NewWeekdayContent
    ) -> CalendarView<DayContent, HeaderContent, NewWeekdayContent> {
        CalendarView<DayContent, HeaderContent, NewWeekdayContent>(
            displayDate: externalDisplayDate,
            internalDate: _internalDisplayDate.wrappedValue,
            selectedKeySet: selectedKeySet,
            rangeBounds: rangeBounds,
            selectedKeySetProvider: selectedKeySetProvider,
            rangeBoundsProvider: rangeBoundsProvider,
            onDateTapped: onDateTapped,
            dayCell: dayContent,
            header: headerContent,
            weekday: content
        )
    }
}

// MARK: - Ergonomic Out-of-the-Box Initializers
public extension CalendarView where DayContent == DefaultCalendarDayCell,
                                    HeaderContent == DefaultCalendarHeader,
                                    WeekdayContent == DefaultCalendarWeekdayHeader {

    /// 1. Single Date Selection
    init(selection: Binding<Date>, displayDate: Binding<Date>? = nil) {
        self.init(
            displayDate: displayDate,
            internalDate: displayDate?.wrappedValue ?? selection.wrappedValue,
            selectedKeySet: [],
            rangeBounds: (nil, nil),
            selectedKeySetProvider: { cal in
                [CalendarDateKey.key(for: selection.wrappedValue, using: cal)]
            },
            rangeBoundsProvider: nil,
            onDateTapped: { date in
                selection.wrappedValue = date
            },
            dayCell: { DefaultCalendarDayCell(state: $0) },
            header: { matrix, prev, next in
                DefaultCalendarHeader(title: matrix.monthTitle, onPrevious: prev, onNext: next)
            },
            weekday: { DefaultCalendarWeekdayHeader(calendar: $0) }
        )
    }

    /// 2. Date Range Selection with smart range expansion
    init(selection: Binding<ClosedRange<Date>?>, displayDate: Binding<Date>? = nil) {
        self.init(
            displayDate: displayDate,
            internalDate: displayDate?.wrappedValue ?? selection.wrappedValue?.lowerBound ?? Date(),
            selectedKeySet: [],
            rangeBounds: (nil, nil),
            selectedKeySetProvider: nil,
            rangeBoundsProvider: { cal in
                let startKey = selection.wrappedValue.map { CalendarDateKey.key(for: $0.lowerBound, using: cal) }
                let endKey = selection.wrappedValue.map { CalendarDateKey.key(for: $0.upperBound, using: cal) }
                return (startKey, endKey)
            },
            onDateTapped: { tappedDate in
                if let range = selection.wrappedValue {
                    if range.lowerBound == range.upperBound && tappedDate >= range.lowerBound {
                        selection.wrappedValue = range.lowerBound...tappedDate
                    } else {
                        selection.wrappedValue = tappedDate...tappedDate
                    }
                } else {
                    selection.wrappedValue = tappedDate...tappedDate
                }
            },
            dayCell: { DefaultCalendarDayCell(state: $0) },
            header: { matrix, prev, next in
                DefaultCalendarHeader(title: matrix.monthTitle, onPrevious: prev, onNext: next)
            },
            weekday: { DefaultCalendarWeekdayHeader(calendar: $0) }
        )
    }

    /// 3. Multi-Date Selection with toggle semantics
    init(selection: Binding<Set<Date>>, displayDate: Binding<Date>? = nil) {
        self.init(
            displayDate: displayDate,
            internalDate: displayDate?.wrappedValue ?? selection.wrappedValue.first ?? Date(),
            selectedKeySet: [],
            rangeBounds: (nil, nil),
            selectedKeySetProvider: { cal in
                Set(selection.wrappedValue.map { CalendarDateKey.key(for: $0, using: cal) })
            },
            rangeBoundsProvider: nil,
            onDateTapped: { tappedDate in
                let cal = Calendar.current
                let key = CalendarDateKey.key(for: tappedDate, using: cal)
                if let existing = selection.wrappedValue.first(where: { CalendarDateKey.key(for: $0, using: cal) == key }) {
                    selection.wrappedValue.remove(existing)
                } else {
                    selection.wrappedValue.insert(tappedDate)
                }
            },
            dayCell: { DefaultCalendarDayCell(state: $0) },
            header: { matrix, prev, next in
                DefaultCalendarHeader(title: matrix.monthTitle, onPrevious: prev, onNext: next)
            },
            weekday: { DefaultCalendarWeekdayHeader(calendar: $0) }
        )
    }

    /// 4. Display-Only / Agenda
    init(displayDate: Binding<Date>) {
        self.init(
            displayDate: displayDate,
            selectedKeySet: [],
            rangeBounds: (nil, nil),
            onDateTapped: { _ in },
            dayCell: { DefaultCalendarDayCell(state: $0) },
            header: { matrix, prev, next in
                DefaultCalendarHeader(title: matrix.monthTitle, onPrevious: prev, onNext: next)
            },
            weekday: { DefaultCalendarWeekdayHeader(calendar: $0) }
        )
    }
}
