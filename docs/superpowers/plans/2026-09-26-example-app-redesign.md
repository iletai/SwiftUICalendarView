# Example App UI/UX Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the SwiftUICalendarView Example app into a premium Apple Native HIG showcase gallery with clean card navigation, rich controls, fluid spring animations, and zero clipping.

**Architecture:** Replace the root `TabView` with a categorized `NavigationStack` list of showcase cards (`ContentView.swift`). Upgrade all 7 demo views with dynamic grouped backgrounds, elevated card containers, hairline borders, and bottom-safe-area padding.

**Tech Stack:** Swift 5.9+, SwiftUI, XcodeGen, Foundation (iOS 17+ Target).

**Spec:** `docs/superpowers/specs/2026-09-26-example-app-redesign.md`

## Global Constraints

- Target: iOS 17.0+
- Zero external package dependencies for CalendarView library
- Use system tokens (`.systemGroupedBackground`, `.secondarySystemGroupedBackground`)
- Zero UI clipping under bars / safe areas
- Keep `#Preview` macro in all demo files

---

### Task 1: Root Gallery Hub (`ContentView.swift`)

Create the categorized showcase card dashboard with Hero Banner, SF Symbol icons, color badges, and NavigationLinks.

**Files:**
- Modify: `Example/ContentView.swift`

- [ ] **Step 1: Implement `ContentView.swift` with Gallery List**

```swift
import CalendarView
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                // Hero Header Banner
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .font(.title)
                                .foregroundStyle(.blue.gradient)
                            Text("SwiftUICalendarView")
                                .font(.title2.bold())
                        }

                        Text("Declarative, high-performance calendar component for SwiftUI with 120Hz ProMotion fluidity and zero external dependencies.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            BadgeLabel(title: "v3.1.0", color: .blue)
                            BadgeLabel(title: "Zero Deps", color: .green)
                            BadgeLabel(title: "iOS 17+", color: .purple)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 6)
                }

                // Section 1: Core Selection
                Section("Core Selection") {
                    NavigationLink {
                        SingleDateDemo()
                    } label: {
                        ShowcaseRow(
                            icon: "calendar",
                            iconColor: .blue,
                            title: "Single Date Picker",
                            subtitle: "1-line date binding, Today jump, first weekday configuration"
                        )
                    }

                    NavigationLink {
                        BookingRangeDemo()
                    } label: {
                        ShowcaseRow(
                            icon: "arrow.left.and.right.square",
                            iconColor: .indigo,
                            title: "Booking Date Range",
                            subtitle: "Airbnb-style continuous curved ribbons, nights counter, disable past dates"
                        )
                    }

                    NavigationLink {
                        MultiDateDemo()
                    } label: {
                        ShowcaseRow(
                            icon: "checklist",
                            iconColor: .pink,
                            title: "Multi-Date Selection",
                            subtitle: "Select multiple discrete dates with interactive summary chips"
                        )
                    }
                }

                // Section 2: View Modes & Layouts
                Section("View Modes & Layouts") {
                    NavigationLink {
                        YearCalendarDemo()
                    } label: {
                        ShowcaseRow(
                            icon: "calendar.badge.plus",
                            iconColor: .teal,
                            title: "Year Overview Grid",
                            subtitle: "12-month scrollable overview with full & compact display modes"
                        )
                    }

                    NavigationLink {
                        WeekCalendarDemo()
                    } label: {
                        ShowcaseRow(
                            icon: "calendar.day.timeline.left",
                            iconColor: .mint,
                            title: "7-Day Week Strip",
                            subtitle: "Single-row compact week view with seamless week navigation"
                        )
                    }

                    NavigationLink {
                        EventCalendarDemo()
                    } label: {
                        ShowcaseRow(
                            icon: "circle.grid.2x2",
                            iconColor: .orange,
                            title: "Event Calendar & Agenda",
                            subtitle: "Multi-color dot indicators with matching interactive agenda list"
                        )
                    }
                }

                // Section 3: Customization & Localization
                Section("Customization & Localization") {
                    NavigationLink {
                        CustomSlotLocaleDemo()
                    } label: {
                        ShowcaseRow(
                            icon: "slider.horizontal.3",
                            iconColor: .purple,
                            title: "Custom Slots & Locales",
                            subtitle: "Custom day cell builders with Buddhist, Japanese & Islamic calendars"
                        )
                    }
                }
            }
            .navigationTitle("Calendar Gallery")
        }
    }
}

// MARK: - Reusable Row Components
struct ShowcaseRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 38, height: 38)
                .background(iconColor.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.bold())
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct BadgeLabel: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.caption2.bold())
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

#Preview {
    ContentView()
}
```

- [ ] **Step 2: Commit**

```bash
git add Example/ContentView.swift
git commit -m "feat(example): redesign root ContentView to categorized Showcase Gallery Hub"
```

---

### Task 2: Redesign Core Demos (Single, Booking, Multi)

Upgrade SingleDateDemo, BookingRangeDemo, and MultiDateDemo with elevated card style, native grouped background, and modern controls.

**Files:**
- Modify: `Example/Demos/SingleDateDemo.swift`
- Modify: `Example/Demos/BookingRangeDemo.swift`
- Modify: `Example/Demos/MultiDateDemo.swift`

- [ ] **Step 1: Redesign `SingleDateDemo.swift`**

```swift
import CalendarView
import SwiftUI

struct SingleDateDemo: View {
    @State private var selectedDate = Date()
    @State private var displayDate = Date()
    @State private var firstWeekday: Locale.Weekday = .sunday
    @State private var hapticsEnabled = true

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header Card
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected Date")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                        .textCase(.uppercase)
                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                        .font(.title3.bold())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Calendar Container Card
                VStack(spacing: 12) {
                    CalendarView(selection: $selectedDate, displayDate: $displayDate)
                        .calendarFirstWeekday(firstWeekday)
                        .calendarHapticsEnabled(hapticsEnabled)
                        .padding(.vertical, 6)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Quick Navigation Actions
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
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            if let next = Calendar.current.date(byAdding: .month, value: 1, to: displayDate) {
                                displayDate = next
                            }
                        }
                    } label: {
                        Label("Next Month", systemImage: "chevron.right")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                }

                // Configuration Settings Card
                VStack(spacing: 14) {
                    HStack {
                        Text("First Weekday").font(.subheadline.bold())
                        Spacer()
                        Picker("First Weekday", selection: $firstWeekday) {
                            Text("Sun").tag(Locale.Weekday.sunday)
                            Text("Mon").tag(Locale.Weekday.monday)
                            Text("Sat").tag(Locale.Weekday.saturday)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                    }

                    Divider()

                    Toggle("Selection Haptics", isOn: $hapticsEnabled)
                        .font(.subheadline.bold())
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Single Picker")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.blue)
    }
}

#Preview {
    NavigationStack {
        SingleDateDemo()
    }
}
```

- [ ] **Step 2: Redesign `BookingRangeDemo.swift`**

```swift
import CalendarView
import SwiftUI

struct BookingRangeDemo: View {
    @State private var dateRange: ClosedRange<Date>? = {
        let cal = Calendar.current
        let today = Date()
        guard let start = cal.date(byAdding: .day, value: 2, to: today),
              let end = cal.date(byAdding: .day, value: 6, to: today) else { return nil }
        return start...end
    }()
    @State private var disablePastDates = true

    private var numberOfNights: Int {
        guard let range = dateRange else { return 0 }
        return Calendar.current.dateComponents([.day], from: range.lowerBound, to: range.upperBound).day ?? 0
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Booking Summary Card
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Check-In", systemImage: "arrow.down.circle.fill")
                            .font(.caption.bold())
                            .foregroundColor(.indigo)
                        Text(dateRange?.lowerBound.formatted(date: .abbreviated, time: .omitted) ?? "Select date")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "arrow.right")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        Label("Check-Out", systemImage: "arrow.up.circle.fill")
                            .font(.caption.bold())
                            .foregroundColor(.indigo)
                        Text(dateRange?.upperBound.formatted(date: .abbreviated, time: .omitted) ?? "Select date")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Stay Duration Pill
                if numberOfNights > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "moon.stars.fill")
                        Text("\(numberOfNights) \(numberOfNights == 1 ? "night" : "nights") duration")
                            .font(.subheadline.bold())
                    }
                    .foregroundColor(.indigo)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.indigo.opacity(0.12))
                    .clipShape(Capsule())
                }

                // Calendar Card
                VStack(spacing: 12) {
                    CalendarView(selection: $dateRange)
                        .calendarDisabledDates { date in
                            disablePastDates && date < Calendar.current.startOfDay(for: Date())
                        }
                        .padding(.vertical, 6)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Presets & Options Card
                VStack(spacing: 14) {
                    HStack(spacing: 10) {
                        Button("Weekend (2N)") { setPreset(days: 2) }
                            .buttonStyle(.bordered)
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)

                        Button("1 Week (7N)") { setPreset(days: 7) }
                            .buttonStyle(.bordered)
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)

                        Button("Clear") { withAnimation { dateRange = nil } }
                            .buttonStyle(.bordered)
                            .font(.caption.bold())
                            .foregroundColor(.red)
                    }

                    Divider()

                    Toggle("Disable Past Dates", isOn: $disablePastDates)
                        .font(.subheadline.bold())
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Booking Range")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.indigo)
    }

    private func setPreset(days: Int) {
        let start = Calendar.current.startOfDay(for: Date())
        if let end = Calendar.current.date(byAdding: .day, value: days, to: start) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                dateRange = start...end
            }
        }
    }
}

#Preview {
    NavigationStack {
        BookingRangeDemo()
    }
}
```

- [ ] **Step 3: Redesign `MultiDateDemo.swift`**

```swift
import CalendarView
import SwiftUI

struct MultiDateDemo: View {
    @State private var selectedDates: Set<Date> = {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return [
            today,
            cal.date(byAdding: .day, value: 2, to: today)!,
            cal.date(byAdding: .day, value: 5, to: today)!
        ]
    }()
    @State private var displayDate = Date()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header Count Pill
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.pink)
                    Text("\(selectedDates.count) dates selected")
                        .font(.subheadline.bold())
                        .foregroundColor(.pink)
                    Spacer()
                    if !selectedDates.isEmpty {
                        Button("Clear All") {
                            withAnimation { selectedDates.removeAll() }
                        }
                        .font(.caption.bold())
                        .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Calendar Card
                VStack(spacing: 12) {
                    CalendarView(selection: $selectedDates, displayDate: $displayDate)
                        .padding(.vertical, 6)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Selected Dates Chips
                if !selectedDates.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Selected Schedule")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        FlowLayout(spacing: 8) {
                            ForEach(selectedDates.sorted(), id: \.self) { date in
                                HStack(spacing: 6) {
                                    Text(date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption.bold())
                                    Button {
                                        withAnimation { selectedDates.remove(date) }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.pink.opacity(0.12))
                                .foregroundColor(.pink)
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Multi-Date Selection")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.pink)
    }
}

// MARK: - FlowLayout helper for chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width {
                currentX = 0
                height += rowHeight + spacing
                rowHeight = 0
            }
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    NavigationStack {
        MultiDateDemo()
    }
}
```

- [ ] **Step 4: Commit**

```bash
git add Example/Demos/SingleDateDemo.swift Example/Demos/BookingRangeDemo.swift Example/Demos/MultiDateDemo.swift
git commit -m "feat(example): polish Single, Booking and Multi-Date demo views with Apple HIG cards"
```

---

### Task 3: Redesign Modes & Views (Year, Week, Events, Custom Slot)

Upgrade YearCalendarDemo, WeekCalendarDemo, EventCalendarDemo, and CustomSlotLocaleDemo.

**Files:**
- Modify: `Example/Demos/YearCalendarDemo.swift`
- Modify: `Example/Demos/WeekCalendarDemo.swift`
- Modify: `Example/Demos/EventCalendarDemo.swift`
- Modify: `Example/Demos/CustomSlotLocaleDemo.swift`

- [ ] **Step 1: Redesign `YearCalendarDemo.swift`**

```swift
import CalendarView
import SwiftUI

struct YearCalendarDemo: View {
    @State private var selectedDate = Date()
    @State private var displayDate = Date()
    @State private var yearMode: YearDisplayMode = .full

    var body: some View {
        VStack(spacing: 12) {
            Picker("Display Mode", selection: $yearMode) {
                Text("Full Mode").tag(YearDisplayMode.full)
                Text("Compact Mode").tag(YearDisplayMode.compact)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            CalendarView(selection: $selectedDate, displayDate: $displayDate)
                .calendarViewMode(.year(yearMode))
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Year Overview")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.teal)
    }
}

#Preview {
    NavigationStack {
        YearCalendarDemo()
    }
}
```

- [ ] **Step 2: Redesign `WeekCalendarDemo.swift`**

```swift
import CalendarView
import SwiftUI

struct WeekCalendarDemo: View {
    @State private var selectedDate = Date()
    @State private var displayDate = Date()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Selected Date Card
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected Date")
                        .font(.caption.bold())
                        .foregroundColor(.mint)
                        .textCase(.uppercase)
                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                        .font(.title3.bold())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Week Strip Card
                VStack(spacing: 12) {
                    CalendarView(selection: $selectedDate, displayDate: $displayDate)
                        .calendarViewMode(.week)
                        .padding(.vertical, 6)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Action
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        let today = Date()
                        displayDate = today
                        selectedDate = today
                    }
                } label: {
                    Label("Current Week", systemImage: "calendar.badge.clock")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Week View")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.mint)
    }
}

#Preview {
    NavigationStack {
        WeekCalendarDemo()
    }
}
```

- [ ] **Step 3: Redesign `EventCalendarDemo.swift`**

```swift
import CalendarView
import SwiftUI

struct EventCalendarDemo: View {
    @State private var displayDate = Date()
    @State private var selectedDate = Date()

    private var sampleEvents: [Date: [CalendarEvent]] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        func d(_ offset: Int) -> Date { cal.date(byAdding: .day, value: offset, to: today)! }

        return [
            d(0): [
                CalendarEvent(date: d(0), color: .blue, title: "Team Standup (09:30)"),
                CalendarEvent(date: d(0), color: .green, title: "Design Sprint Review")
            ],
            d(2): [
                CalendarEvent(date: d(2), color: .orange, title: "Product QA Testing"),
                CalendarEvent(date: d(2), color: .purple, title: "All-Hands Meeting"),
                CalendarEvent(date: d(2), color: .red, title: "v3.1 Release Cut")
            ],
            d(4): [
                CalendarEvent(date: d(4), color: .teal, title: "Architecture Tech Talk")
            ],
            d(-2): [
                CalendarEvent(date: d(-2), color: .gray, title: "Infrastructure Maintenance")
            ]
        ]
    }

    private var currentEvents: [CalendarEvent] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: selectedDate)
        return sampleEvents.first { cal.isDate($0.key, inSameDayAs: start) }?.value ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Calendar Card with dots
                VStack(spacing: 12) {
                    CalendarView(selection: $selectedDate, displayDate: $displayDate)
                        .calendarEvents(sampleEvents)
                        .padding(.vertical, 6)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Timeline Agenda Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Agenda · \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.headline)
                        Spacer()
                        Text("\(currentEvents.count) items")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }

                    if currentEvents.isEmpty {
                        VStack(spacing: 6) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            Text("No events scheduled for this day")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        ForEach(currentEvents) { event in
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(event.color)
                                    .frame(width: 4, height: 36)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title ?? "Event")
                                        .font(.subheadline.bold())
                                    Text("Calendar View Event")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(uiColor: .tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Event Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.orange)
    }
}

#Preview {
    NavigationStack {
        EventCalendarDemo()
    }
}
```

- [ ] **Step 4: Redesign `CustomSlotLocaleDemo.swift`**

```swift
import CalendarView
import SwiftUI

struct CustomSlotLocaleDemo: View {
    @State private var selectedDate = Date()
    @State private var selectedLocaleId = "vi_VN"
    @State private var selectedCalendarId = "gregorian"

    private var currentLocale: Locale { Locale(identifier: selectedLocaleId) }

    private var currentCalendar: Calendar {
        let id: Calendar.Identifier = switch selectedCalendarId {
        case "buddhist": .buddhist
        case "japanese": .japanese
        case "islamic": .islamicCivil
        default: .gregorian
        }
        var cal = Calendar(identifier: id)
        cal.locale = currentLocale
        return cal
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Custom Slot Calendar Card
                VStack(spacing: 12) {
                    CalendarView(selection: $selectedDate)
                        .calendarDayCell { state in
                            VStack(spacing: 2) {
                                Text("\(state.dayNumber)")
                                    .font(.system(size: 15, weight: state.isSelected ? .bold : .regular))
                                    .foregroundColor(cellColor(state))

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
                                    .fill(state.isSelected ? Color.purple.gradient : AnyShapeStyle(Color.clear))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(state.isToday && !state.isSelected ? Color.orange : Color.clear, lineWidth: 1.5)
                            )
                            .opacity(state.isCurrentMonth ? 1.0 : 0.3)
                        }
                        .calendarLocale(currentLocale)
                        .environment(\.calendar, currentCalendar)
                        .padding(.vertical, 6)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Pickers Card
                VStack(spacing: 14) {
                    HStack {
                        Text("Locale").font(.subheadline.bold())
                        Spacer()
                        Picker("Locale", selection: $selectedLocaleId) {
                            Text("Tiếng Việt").tag("vi_VN")
                            Text("English").tag("en_US")
                            Text("日本語").tag("ja_JP")
                            Text("Français").tag("fr_FR")
                        }
                        .pickerStyle(.menu)
                    }

                    Divider()

                    HStack {
                        Text("Calendar System").font(.subheadline.bold())
                        Spacer()
                        Picker("Calendar", selection: $selectedCalendarId) {
                            Text("Gregorian").tag("gregorian")
                            Text("Buddhist (BE)").tag("buddhist")
                            Text("Japanese (Reiwa)").tag("japanese")
                            Text("Islamic (Hijri)").tag("islamic")
                        }
                        .pickerStyle(.menu)
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Custom & Locales")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.purple)
    }

    private func cellColor(_ state: CalendarDayState) -> Color {
        if state.isSelected { return .white }
        if state.isDisabled { return .secondary.opacity(0.4) }
        return state.isCurrentMonth ? .primary : .secondary
    }
}

#Preview {
    NavigationStack {
        CustomSlotLocaleDemo()
    }
}
```

- [ ] **Step 5: Commit**

```bash
git add Example/Demos/
git commit -m "feat(example): polish Year, Week, Events, and Custom Slot demos with Apple HIG"
```

---

### Task 4: Verification & Screenshots

Build the app, run tests, install on Simulator, and capture screenshots to verify the new UI design.

- [ ] **Step 1: Build Xcode project via xcodebuild**
- [ ] **Step 2: Install and launch on Simulator**
- [ ] **Step 3: Capture screenshot of Showcase Gallery and Booking demo**
- [ ] **Step 4: Verify all unit tests pass**
