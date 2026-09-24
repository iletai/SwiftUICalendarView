//
//  ContentView.swift
//  CalendarExampleView
//
//  Created by iletai on 24/11/2023.
//

import CalendarView
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SingleDatePickerDemo()
                .tabItem {
                    Label("Single", systemImage: "calendar")
                }

            BookingRangePickerDemo()
                .tabItem {
                    Label("Booking", systemImage: "arrow.left.and.right.square")
                }

            EventCalendarDemo()
                .tabItem {
                    Label("Events", systemImage: "circle.grid.2x2")
                }

            CustomSlotAndLocaleDemo()
                .tabItem {
                    Label("Custom & Locale", systemImage: "slider.horizontal.3")
                }
        }
    }
}

// MARK: - 1. Single Date Picker Demo
struct SingleDatePickerDemo: View {
    @State private var selectedDate = Date()
    @State private var displayDate = Date()
    @State private var firstWeekday: Locale.Weekday = .sunday
    @State private var hapticsEnabled = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Selected Date Header Card
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Selected Date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        Text(selectedDate.formatted(date: .complete, time: .omitted))
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Calendar View
                    CalendarView(selection: $selectedDate, displayDate: $displayDate)
                        .calendarFirstWeekday(firstWeekday)
                        .calendarHapticsEnabled(hapticsEnabled)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)

                    // Actions & Controls
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    let today = Date()
                                    displayDate = today
                                    selectedDate = today
                                }
                            } label: {
                                Label("Today", systemImage: "calendar.badge.clock")
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.borderedProminent)

                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayDate) {
                                        displayDate = nextMonth
                                    }
                                }
                            } label: {
                                Label("Next Month", systemImage: "chevron.right")
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.bordered)
                        }

                        Divider()

                        HStack {
                            Text("First Weekday")
                                .font(.subheadline)
                            Spacer()
                            Picker("First Weekday", selection: $firstWeekday) {
                                Text("Sun").tag(Locale.Weekday.sunday)
                                Text("Mon").tag(Locale.Weekday.monday)
                                Text("Sat").tag(Locale.Weekday.saturday)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 180)
                        }

                        Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                            .font(.subheadline)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .navigationTitle("Single Picker")
        }
    }
}

// MARK: - 2. Booking Range Picker Demo
struct BookingRangePickerDemo: View {
    @State private var dateRange: ClosedRange<Date>? = {
        let cal = Calendar.current
        let today = Date()
        guard let start = cal.date(byAdding: .day, value: 3, to: today),
              let end = cal.date(byAdding: .day, value: 7, to: today) else { return nil }
        return start...end
    }()
    @State private var disablePastDates = true

    private var numberOfNights: Int {
        guard let range = dateRange else { return 0 }
        let comps = Calendar.current.dateComponents([.day], from: range.lowerBound, to: range.upperBound)
        return comps.day ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Booking Summary Card
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Check-In", systemImage: "arrow.down.circle.fill")
                                .font(.caption.bold())
                                .foregroundColor(.blue)
                            Text(dateRange?.lowerBound.formatted(date: .abbreviated, time: .omitted) ?? "Select date")
                                .font(.callout.bold())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "arrow.right")
                            .foregroundColor(.secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Label("Check-Out", systemImage: "arrow.up.circle.fill")
                                .font(.caption.bold())
                                .foregroundColor(.indigo)
                            Text(dateRange?.upperBound.formatted(date: .abbreviated, time: .omitted) ?? "Select date")
                                .font(.callout.bold())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Nights Badge
                    if numberOfNights > 0 {
                        HStack {
                            Image(systemName: "moon.stars.fill")
                                .foregroundColor(.indigo)
                            Text("\(numberOfNights) \(numberOfNights == 1 ? "night" : "nights") selected")
                                .font(.subheadline.bold())
                                .foregroundColor(.indigo)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(Color.indigo.opacity(0.12))
                        .clipShape(Capsule())
                    }

                    // Calendar with continuous range shape
                    CalendarView(selection: $dateRange)
                        .calendarDisabledDates { date in
                            if disablePastDates {
                                let startOfToday = Calendar.current.startOfDay(for: Date())
                                return date < startOfToday
                            }
                            return false
                        }
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)

                    // Range Quick Presets & Controls
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Button("Next 3 Days") {
                                setPresetRange(days: 3)
                            }
                            .buttonStyle(.bordered)
                            .font(.caption.bold())

                            Button("Next 7 Days") {
                                setPresetRange(days: 7)
                            }
                            .buttonStyle(.bordered)
                            .font(.caption.bold())

                            Button("Clear") {
                                withAnimation { dateRange = nil }
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                            .font(.caption.bold())
                        }

                        Toggle("Disable Past Dates", isOn: $disablePastDates)
                            .font(.subheadline)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .navigationTitle("Booking Range")
        }
    }

    private func setPresetRange(days: Int) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        if let end = cal.date(byAdding: .day, value: days, to: start) {
            withAnimation {
                dateRange = start...end
            }
        }
    }
}

// MARK: - 3. Event Calendar Demo
struct EventCalendarDemo: View {
    @State private var displayDate = Date()
    @State private var selectedDate = Date()

    private var sampleEvents: [Date: [CalendarEvent]] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        func makeDate(offset: Int) -> Date {
            cal.date(byAdding: .day, value: offset, to: today) ?? today
        }

        return [
            makeDate(offset: 0): [
                CalendarEvent(date: makeDate(offset: 0), color: .blue, title: "Team Standup 09:30"),
                CalendarEvent(date: makeDate(offset: 0), color: .green, title: "Design Sprint Review")
            ],
            makeDate(offset: 2): [
                CalendarEvent(date: makeDate(offset: 2), color: .orange, title: "Product Launch QA"),
                CalendarEvent(date: makeDate(offset: 2), color: .purple, title: "All-Hands Meeting"),
                CalendarEvent(date: makeDate(offset: 2), color: .red, title: "Deadline: v3.0 Release")
            ],
            makeDate(offset: 5): [
                CalendarEvent(date: makeDate(offset: 5), color: .green, title: "Quarterly Planning")
            ],
            makeDate(offset: -3): [
                CalendarEvent(date: makeDate(offset: -3), color: .gray, title: "Architecture Refactoring")
            ]
        ]
    }

    private var currentEvents: [CalendarEvent] {
        let cal = Calendar.current
        let startOfSelected = cal.startOfDay(for: selectedDate)
        return sampleEvents.first(where: { cal.isDate($0.key, inSameDayAs: startOfSelected) })?.value ?? []
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Calendar with multi-color dots
                    CalendarView(selection: $selectedDate, displayDate: $displayDate)
                        .calendarEvents(sampleEvents)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)

                    // Agenda List for Selected Date
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Agenda for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.headline)
                            Spacer()
                            Text("\(currentEvents.count) items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if currentEvents.isEmpty {
                            HStack {
                                Spacer()
                                Text("No events scheduled for this day")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 16)
                                Spacer()
                            }
                        } else {
                            VStack(spacing: 8) {
                                ForEach(currentEvents) { event in
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(event.color)
                                            .frame(width: 10, height: 10)

                                        Text(event.title ?? "Event")
                                            .font(.subheadline.bold())

                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(.tertiarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .navigationTitle("Event Calendar")
        }
    }
}

// MARK: - 4. Custom Slot Builder & Alternate Locale Demo
struct CustomSlotAndLocaleDemo: View {
    @State private var selectedDate = Date()
    @State private var selectedLocaleIdentifier = "vi_VN"
    @State private var selectedCalendarIdentifier = "gregorian"

    private var currentLocale: Locale {
        Locale(identifier: selectedLocaleIdentifier)
    }

    private var currentCalendar: Calendar {
        switch selectedCalendarIdentifier {
        case "buddhist":
            var cal = Calendar(identifier: .buddhist)
            cal.locale = currentLocale
            return cal
        case "japanese":
            var cal = Calendar(identifier: .japanese)
            cal.locale = currentLocale
            return cal
        case "islamic":
            var cal = Calendar(identifier: .islamicCivil)
            cal.locale = currentLocale
            return cal
        default:
            var cal = Calendar(identifier: .gregorian)
            cal.locale = currentLocale
            return cal
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Custom Slot Builder Calendar
                    CalendarView(selection: $selectedDate)
                        .calendarDayCell { state in
                            // Custom Day Cell Slot Builder
                            VStack(spacing: 2) {
                                Text("\(state.dayNumber)")
                                    .font(.system(size: 15, weight: state.isSelected ? .bold : .regular))
                                    .foregroundColor(cellTextColor(for: state))

                                if state.isToday {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 4, height: 4)
                                }
                            }
                            .frame(height: 38)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(state.isSelected ? Color.purple : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(state.isToday && !state.isSelected ? Color.orange : Color.clear, lineWidth: 1.5)
                            )
                            .opacity(state.isCurrentMonth ? 1.0 : 0.3)
                        }
                        .calendarLocale(currentLocale)
                        .environment(\.calendar, currentCalendar)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)

                    // Configuration Options
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Locale")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Picker("Locale", selection: $selectedLocaleIdentifier) {
                                Text("Tiếng Việt (vi_VN)").tag("vi_VN")
                                Text("English (en_US)").tag("en_US")
                                Text("Japanese (ja_JP)").tag("ja_JP")
                                Text("French (fr_FR)").tag("fr_FR")
                            }
                            .pickerStyle(.menu)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Calendar System")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Picker("Calendar", selection: $selectedCalendarIdentifier) {
                                Text("Gregorian").tag("gregorian")
                                Text("Buddhist (BE)").tag("buddhist")
                                Text("Japanese (Reiwa)").tag("japanese")
                                Text("Islamic (Hijri)").tag("islamic")
                            }
                            .pickerStyle(.menu)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .navigationTitle("Slot & Locale")
        }
    }

    private func cellTextColor(for state: CalendarDayState) -> Color {
        if state.isSelected {
            return .white
        }
        if state.isDisabled {
            return .secondary.opacity(0.4)
        }
        return state.isCurrentMonth ? .primary : .secondary
    }
}

#Preview {
    ContentView()
}
