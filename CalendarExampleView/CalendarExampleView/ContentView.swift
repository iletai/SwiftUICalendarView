//
//  ContentView.swift
//  CalendarExampleView
//
//  Created by iletai on 24/11/2023.
//

import CalendarView
import SwiftUI

struct ContentView: View {
    // MARK: - State
    @State private var selectedDate = Date()
    @State private var viewMode = CalendarViewMode.month
    @State private var selectionMode = CalendarSelectionMode.single
    @State private var selectedDates = Set<Date>()
    @State private var selectedRange: ClosedRange<Date>?

    @State private var isShowHeader = true
    @State private var isShowDateOut = true
    @State private var isShowDivider = false
    @State private var isHighlightToday = true
    @State private var useDarkTheme = false
    @State private var disableWeekends = false

    // MARK: - Computed Properties
    private var isCompact: Bool {
        viewMode == .year(.compact)
    }

    private var currentTheme: CalendarTheme {
        useDarkTheme ? .dark : .default
    }

    private var sampleEventDates: Set<Date> {
        let cal = Calendar.current
        let today = Date()
        var dates = Set<Date>()
        for offset in [2, 5, 8, 14, 21] {
            if let day = cal.date(byAdding: .day, value: offset, to: today) {
                dates.insert(cal.startOfDay(for: day))
            }
        }
        return dates
    }

    private var minDate: Date {
        Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
    }

    private var maxDate: Date {
        Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack {
                        CalendarView(
                            date: selectedDate,
                            dateView: { date in
                                Text(date.dayName)
                                    .font(
                                        isCompact
                                            ? .system(size: 9)
                                            : currentTheme.dayFont
                                    )
                                    .foregroundColor(dayColor(for: date))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: isCompact ? 14 : 30)
                                    .background(
                                        isCompact
                                            ? .clear
                                            : dayBackground(for: date)
                                    )
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: isCompact ? 0 : 6
                                        )
                                    )
                            },
                            headerView: { dates in
                                HStack {
                                    ForEach(dates, id: \.self) { day in
                                        Text(
                                            day.weekDayShortName
                                                .uppercased()
                                        )
                                        .font(currentTheme.headerFont)
                                        .foregroundColor(
                                            Calendar.current
                                                .isDateInWeekend(day)
                                                ? currentTheme.weekendColor
                                                : .primary
                                        )
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            },
                            dateOutView: { date in
                                Text(date.dayName)
                                    .font(
                                        isCompact
                                            ? .system(size: 9)
                                            : currentTheme.dayFont
                                    )
                                    .foregroundColor(
                                        currentTheme.dateOutColor
                                    )
                                    .frame(maxWidth: .infinity)
                                    .frame(height: isCompact ? 14 : 30)
                            }
                        )
                        .enableHeader(isShowHeader)
                        .enableDateOut(isShowDateOut)
                        .enableDivider(isShowDivider)
                        .enableHighlightToday(isHighlightToday)
                        .firstWeekDay(.monday)
                        .setViewMode(viewMode)
                        .rowsSpacing(6)
                        .columnSpacing(4)
                        .contentPadding(12)
                        .backgroundCalendar(.visible(12, .gray.opacity(0.1)))
                        .calendarTheme(currentTheme)
                        // Wave 2: Selection mode
                        .selectionMode(selectionMode)
                        .selectedDates(selectedDates)
                        .onSelectionChanged { dates in
                            selectedDates = Set(dates)
                        }
                        // Wave 2: Date range selection
                        .selectedRange(selectedRange)
                        .onRangeSelected { range in
                            selectedRange = range
                        }
                        // Wave 2: Event markers
                        .eventDates(sampleEventDates)
                        // Wave 2: Date range limits (±3 months)
                        .dateRange(minimum: minDate, maximum: maxDate)
                        // Wave 2: Disabled dates (weekends)
                        .disabledDates { date in
                            disableWeekends && Calendar.current.isDateInWeekend(date)
                        }
                        // Wave 2: Today button
                        .showTodayButton(true)
                        .onTodayTapped {
                            withAnimation { selectedDate = Date() }
                        }
                        // Wave 2: Month/Year picker
                        .enableMonthYearPicker(true)
                        .onMonthYearChanged { date in
                            withAnimation { selectedDate = date }
                        }
                        // Wave 2: Scroll to today on appear
                        .scrollToDate(Date())
                        .onDraggingEnded { direction, mode in
                            let component: Calendar.Component = mode == .month ? .month : .weekOfYear
                            let value = direction == .forward ? 1 : -1
                            withAnimation(.easeInOut) {
                                selectedDate = Calendar.gregorian.date(
                                    byAdding: component, value: value, to: selectedDate
                                ) ?? selectedDate
                            }
                        }
                        .onSelectDate { date in
                            selectedDate = date
                        }
                        .marginDefault()
                        .allowsTightening(true)
                    }
                    .frame(maxWidth: .infinity)
                }

                controlPanel
            }
            .navigationTitle("Calendar Demo")
            .navigationBarTitleDisplayMode(.inline)
            .background(useDarkTheme ? Color.black : Color(.systemGroupedBackground))
            .preferredColorScheme(useDarkTheme ? .dark : .light)
        }
    }

    // MARK: - Day Styling Helpers
    private func dayColor(for date: Date) -> Color {
        if Calendar.current.isDateInWeekend(date) {
            return currentTheme.weekendColor
        }
        return .primary
    }

    private func dayBackground(for date: Date) -> Color {
        let cal = Calendar.current
        let normalized = cal.startOfDay(for: date)
        if selectedDates.contains(normalized) {
            return currentTheme.selectedColor
        }
        if cal.isDateInToday(date) && isHighlightToday {
            return currentTheme.todayColor.opacity(0.25)
        }
        return .clear
    }

    // MARK: - Control Panel
    private var controlPanel: some View {
        VStack(spacing: 8) {
            // Selection mode picker
            HStack {
                Text("Selection")
                    .font(.caption.bold())
                Picker("Selection", selection: $selectionMode) {
                    Text("Single").tag(CalendarSelectionMode.single)
                    Text("Multi").tag(CalendarSelectionMode.multiple)
                    Text("Range").tag(CalendarSelectionMode.range)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)

            // View mode picker
            HStack {
                Text("View")
                    .font(.caption.bold())
                Picker("Mode", selection: $viewMode) {
                    ForEach(CalendarViewMode.allCases, id: \.self) { option in
                        Text(String(describing: option).uppercased())
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)

            // Feature toggles
            Grid(horizontalSpacing: 6, verticalSpacing: 6) {
                GridRow {
                    Toggle("Header", isOn: $isShowHeader)
                        .toggleStyle(.button)
                        .font(.caption)
                    Toggle("DateOut", isOn: $isShowDateOut)
                        .toggleStyle(.button)
                        .font(.caption)
                    Toggle("Divider", isOn: $isShowDivider)
                        .toggleStyle(.button)
                        .font(.caption)
                }
                GridRow {
                    Toggle("Today", isOn: $isHighlightToday)
                        .toggleStyle(.button)
                        .font(.caption)
                    Toggle("🌙 Dark", isOn: $useDarkTheme)
                        .toggleStyle(.button)
                        .font(.caption)
                    Toggle("No Wknd", isOn: $disableWeekends)
                        .toggleStyle(.button)
                        .font(.caption)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    ContentView()
}

extension CalendarWeekday: @retroactive CaseIterable {
    static public var allCases: [CalendarWeekday] {
        [.friday, .monday, .saturday, .thursday, .wednesday, .sunday, .tuesday]
    }
}
