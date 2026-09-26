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
        switch viewMode {
        case .month:
            monthView
        case .year(let displayMode):
            yearView(displayMode: displayMode)
        case .week:
            weekView
        case .single:
            singleView
        }
    }

    // MARK: - Month View
    private var monthView: some View {
        let matrix = makeMonthMatrix(for: currentDisplayDate.wrappedValue)

        return VStack(spacing: 8) {
            headerContent(matrix, { navigate(by: -1) }, { navigate(by: 1) })
            weekdayContent(effectiveCalendar)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 2) {
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
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Year View
    private func yearView(displayMode: YearDisplayMode) -> some View {
        let cal = effectiveCalendar
        let year = cal.component(.year, from: currentDisplayDate.wrappedValue)
        let currentMonthKey = cal.component(.year, from: Date()) * 100 + cal.component(.month, from: Date())

        return ScrollViewReader { proxy in
            VStack(spacing: 8) {
                HStack {
                    Text(String(year))
                        .font(.title.bold())
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    HStack(spacing: 16) {
                        Button { navigate(by: -1) } label: {
                            Image(systemName: "chevron.left").font(.body.bold())
                        }
                        .accessibilityLabel("Previous Year")
                        Button { navigate(by: 1) } label: {
                            Image(systemName: "chevron.right").font(.body.bold())
                        }
                        .accessibilityLabel("Next Year")
                    }
                    .foregroundColor(.primary)
                }
                .padding(.horizontal)

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 20) {
                        ForEach(1...12, id: \.self) { month in
                            let monthDate = cal.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
                            let matrix = makeMonthMatrix(for: monthDate)

                            VStack(spacing: 4) {
                                Text(monthDate.formatted(.dateTime.month(.wide).locale(cal.locale ?? .current)))
                                    .font(.caption.bold())
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if displayMode == .full {
                                    miniWeekdayHeader
                                }

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 2) {
                                    ForEach(matrix.days) { day in
                                        miniDayCell(day: day, compact: displayMode == .compact)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                guard day.isSelectable else { return }
                                                triggerHaptic()
                                                onDateTapped(day.date)
                                            }
                                    }
                                }
                            }
                            .id(matrix.yearMonthKey)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
            .onAppear {
                withAnimation {
                    proxy.scrollTo(currentMonthKey, anchor: .center)
                }
            }
        }
    }

    // MARK: - Week View
    private var weekView: some View {
        let days = FastCalendarEngine.computeWeekMatrix(
            for: currentDisplayDate.wrappedValue,
            calendar: effectiveCalendar,
            todayDate: Date(),
            selectedKeySet: computedSelectedKeySet,
            rangeBounds: computedRangeBounds,
            disabledRule: disabledRule,
            eventsMap: eventKeysMap
        )

        let weekRange = weekRangeTitle(from: days)

        return VStack(spacing: 12) {
            HStack {
                Text(weekRange)
                    .font(.title3.bold())
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                HStack(spacing: 16) {
                    Button { navigate(by: -1) } label: {
                        Image(systemName: "chevron.left").font(.body.bold())
                    }
                    .accessibilityLabel("Previous Week")
                    Button { navigate(by: 1) } label: {
                        Image(systemName: "chevron.right").font(.body.bold())
                    }
                    .accessibilityLabel("Next Week")
                }
                .foregroundColor(.primary)
            }
            .padding(.horizontal)

            weekdayContent(effectiveCalendar)

            HStack(spacing: 0) {
                ForEach(days) { day in
                    dayContent(day)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard day.isSelectable else { return }
                            triggerHaptic()
                            onDateTapped(day.date)
                        }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Single Day View
    private var singleView: some View {
        let matrix = makeMonthMatrix(for: currentDisplayDate.wrappedValue)
        let todayKey = CalendarDateKey.key(for: currentDisplayDate.wrappedValue, using: effectiveCalendar)
        let dayState = matrix.days.first { $0.dateKey == todayKey }

        return VStack(spacing: 12) {
            HStack {
                Text(currentDisplayDate.wrappedValue.formatted(.dateTime.year().month(.wide).day().weekday(.wide).locale(effectiveCalendar.locale ?? .current)))
                    .font(.title3.bold())
                Spacer()
                HStack(spacing: 16) {
                    Button { navigate(by: -1) } label: {
                        Image(systemName: "chevron.left").font(.body.bold())
                    }
                    .accessibilityLabel("Previous Day")
                    Button { navigate(by: 1) } label: {
                        Image(systemName: "chevron.right").font(.body.bold())
                    }
                    .accessibilityLabel("Next Day")
                }
                .foregroundColor(.primary)
            }
            .padding(.horizontal)

            if let state = dayState {
                dayContent(state)
                    .frame(width: 80, height: 80)

                if !state.events.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(state.events) { event in
                            HStack(spacing: 8) {
                                Circle().fill(event.color).frame(width: 8, height: 8)
                                Text(event.title ?? "Event").font(.subheadline)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
            }
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

    private func navigate(by value: Int) {
        let component: Calendar.Component
        switch viewMode {
        case .month: component = .month
        case .year: component = .year
        case .week: component = .weekOfYear
        case .single: component = .day
        }
        if let newDate = effectiveCalendar.date(byAdding: component, value: value, to: currentDisplayDate.wrappedValue) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentDisplayDate.wrappedValue = newDate
            }
        }
    }

    private func makeMonthMatrix(for date: Date) -> FastMonthMatrix {
        FastCalendarEngine.computeMonthMatrix(
            for: date,
            calendar: effectiveCalendar,
            todayDate: Date(),
            selectedKeySet: computedSelectedKeySet,
            rangeBounds: computedRangeBounds,
            disabledRule: disabledRule,
            eventsMap: eventKeysMap
        )
    }

    @ViewBuilder
    private var miniWeekdayHeader: some View {
        let symbols = DefaultCalendarWeekdayHeader(calendar: effectiveCalendar).weekdaySymbols
        HStack(spacing: 0) {
            ForEach(0..<min(7, symbols.count), id: \.self) { i in
                Text(String(symbols[i].prefix(1)))
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private func miniDayCell(day: CalendarDayState, compact: Bool) -> some View {
        Text("\(day.dayNumber)")
            .font(.system(size: compact ? 8 : 9, weight: day.isSelected || day.isToday ? .bold : .regular))
            .foregroundColor(miniDayCellColor(day: day))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .frame(height: compact ? 12 : 14)
            .background(
                Group {
                    if day.isSelected {
                        Circle().fill(Color.accentColor)
                    } else if day.isToday {
                        Circle().stroke(Color.accentColor, lineWidth: 1)
                    }
                }
            )
            .opacity(day.isCurrentMonth ? 1.0 : 0.25)
    }

    private func miniDayCellColor(day: CalendarDayState) -> Color {
        if day.isSelected { return .white }
        if !day.isCurrentMonth { return .secondary }
        return .primary
    }

    private func weekRangeTitle(from days: [CalendarDayState]) -> String {
        guard let first = days.first, let last = days.last else { return "" }
        let cal = effectiveCalendar
        let locale = cal.locale ?? .current
        let start = first.date.formatted(.dateTime.month(.abbreviated).day().locale(locale))
        let end = last.date.formatted(.dateTime.month(.abbreviated).day().year().locale(locale))
        return "\(start) – \(end)"
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

#Preview("Month View") {
    CalendarView(selection: .constant(Date()))
        .padding()
}

#Preview("Week View") {
    CalendarView(selection: .constant(Date()))
        .calendarViewMode(.week)
        .padding()
}

#Preview("Booking Range") {
    let today = Date()
    let start = Calendar.current.date(byAdding: .day, value: 2, to: today)!
    let end = Calendar.current.date(byAdding: .day, value: 6, to: today)!
    return CalendarView(selection: .constant(start...end))
        .padding()
}


