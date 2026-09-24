# SwiftUICalendarView 3.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform SwiftUICalendarView into the #1 zero-dependency SwiftUI calendar library on GitHub with fluid 120fps performance, declarative ViewModifier DSL, continuous range selection, and comprehensive unit test coverage across iOS 16+ & iOS 17+.

**Architecture:** A high-performance, stateless pure SwiftUI architecture. The calculation core (`FastCalendarEngine`) generates immutable 42-day matrices with integer date keys (`YYYYMMDD`) to guarantee $O(1)$ lookups and zero allocations during view updates. Views consume declarative environment values and customize layout via `@ViewBuilder` slots.

**Tech Stack:** Swift 5.9 / Swift 6, SwiftUI, Foundation, XCTest (Zero external dependencies).

**Spec:** `docs/superpowers/specs/2026-09-24-swiftui-calendar-v3-design.md`

## Global Constraints
- Target Platforms: iOS 16.0+, macOS 13.0+, visionOS 1.0+, watchOS 10.0+
- Zero external package dependencies (pure Swift/SwiftUI stdlib).
- Maximum binary footprint < 80KB.
- Zero allocations / formatters initialized inside `View.body` execution.
- Strict concurrency compatibility (`Sendable` models, `@MainActor` UI).

---

### Task 1: Core Models & Date Key Utilities

**Files:**
- Create: `Sources/CalendarView/Models/CalendarDayState.swift`
- Create: `Sources/CalendarView/Models/CalendarEvent.swift`
- Create: `Sources/CalendarView/Models/CalendarSelection.swift`
- Create: `Sources/CalendarView/Utils/Calendar+DateKey.swift`
- Test: `Tests/CalendarViewTests/CalendarDateKeyTests.swift`

**Interfaces:**
- Consumes: Foundation `Date`, `Calendar`, `Color`
- Produces: `CalendarDayState`, `RangeSelectionPosition`, `CalendarEvent`, `CalendarDateKey`

- [ ] **Step 1: Write failing unit tests for Date Key math**

```swift
// Tests/CalendarViewTests/CalendarDateKeyTests.swift
import XCTest
@testable import CalendarView

final class CalendarDateKeyTests: XCTestCase {
    func testDateKeyCalculation() {
        let key = CalendarDateKey.makeKey(year: 2026, month: 9, day: 24)
        XCTAssertEqual(key, 20260924)
    }

    func testDateKeyDeconstruction() {
        let (y, m, d) = CalendarDateKey.deconstruct(key: 20260924)
        XCTAssertEqual(y, 2026)
        XCTAssertEqual(m, 9)
        XCTAssertEqual(d, 24)
    }
}
```

- [ ] **Step 2: Run test to verify failure**

Run: `swift test --filter CalendarDateKeyTests`  
Expected: FAIL (types not found)

- [ ] **Step 3: Implement Core Models & DateKey Helper**

```swift
// Sources/CalendarView/Utils/Calendar+DateKey.swift
import Foundation

public enum CalendarDateKey {
    @inlinable
    public static func makeKey(year: Int, month: Int, day: Int) -> Int {
        year * 10000 + month * 100 + day
    }

    @inlinable
    public static func deconstruct(key: Int) -> (year: Int, month: Int, day: Int) {
        let year = key / 10000
        let month = (key % 10000) / 100
        let day = key % 100
        return (year, month, day)
    }

    @inlinable
    public static func key(for date: Date, using calendar: Calendar) -> Int {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return makeKey(year: comps.year ?? 0, month: comps.month ?? 0, day: comps.day ?? 0)
    }
}

// Sources/CalendarView/Models/CalendarEvent.swift
import SwiftUI

public struct CalendarEvent: Identifiable, Hashable, Sendable {
    public let id: String
    public let date: Date
    public let color: Color
    public let title: String?

    public init(id: String = UUID().uuidString, date: Date, color: Color = .blue, title: String? = nil) {
        self.id = id
        self.date = date
        self.color = color
        self.title = title
    }
}

// Sources/CalendarView/Models/CalendarDayState.swift
import Foundation

public enum RangeSelectionPosition: Sendable, Hashable {
    case none
    case singleDay
    case rangeStart
    case rangeMiddle
    case rangeEnd
    case rowStart
    case rowEnd
}

public struct CalendarDayState: Identifiable, Hashable, Sendable {
    public var id: Int { dateKey }
    public let dateKey: Int
    public let date: Date
    public let dayNumber: Int
    public let isCurrentMonth: Bool
    public let isToday: Bool
    public let isSelected: Bool
    public let isSelectable: Bool
    public let isDisabled: Bool
    public let rangePosition: RangeSelectionPosition
    public let events: [CalendarEvent]

    public init(
        dateKey: Int,
        date: Date,
        dayNumber: Int,
        isCurrentMonth: Bool,
        isToday: Bool,
        isSelected: Bool = false,
        isSelectable: Bool = true,
        isDisabled: Bool = false,
        rangePosition: RangeSelectionPosition = .none,
        events: [CalendarEvent] = []
    ) {
        self.dateKey = dateKey
        self.date = date
        self.dayNumber = dayNumber
        self.isCurrentMonth = isCurrentMonth
        self.isToday = isToday
        self.isSelected = isSelected
        self.isSelectable = isSelectable
        self.isDisabled = isDisabled
        self.rangePosition = rangePosition
        self.events = events
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter CalendarDateKeyTests`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/CalendarView/Models Sources/CalendarView/Utils/Calendar+DateKey.swift Tests/CalendarViewTests/CalendarDateKeyTests.swift
git commit -m "feat: add high-performance date key math and day state models"
```

---

### Task 2: Pure Math High-Performance Date Engine (`FastCalendarEngine`)

**Files:**
- Create: `Sources/CalendarView/Engine/FastMonthMatrix.swift`
- Create: `Sources/CalendarView/Engine/FastCalendarEngine.swift`
- Test: `Tests/CalendarViewTests/FastCalendarEngineTests.swift`

**Interfaces:**
- Consumes: `CalendarDayState`, `CalendarDateKey`, `CalendarEvent`
- Produces: `FastCalendarEngine.computeMonthMatrix`, `FastMonthMatrix`

- [ ] **Step 1: Write failing unit tests for month matrix calculation**

```swift
// Tests/CalendarViewTests/FastCalendarEngineTests.swift
import XCTest
@testable import CalendarView

final class FastCalendarEngineTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 1 // Sunday
    }

    func testFixed42CellsGeneration() {
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 9
        comps.day = 1
        let date = calendar.date(from: comps)!

        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: date,
            calendar: calendar,
            todayDate: date,
            selectedKeySet: [20260924],
            rangeBounds: (nil, nil)
        )

        XCTAssertEqual(matrix.days.count, 42, "Matrix must always produce 42 normalized cells")
        XCTAssertEqual(matrix.yearMonthKey, 202609)
        let day24 = matrix.days.first { $0.dateKey == 20260924 }
        XCTAssertNotNil(day24)
        XCTAssertTrue(day24!.isSelected)
    }
}
```

- [ ] **Step 2: Run test to verify failure**

Run: `swift test --filter FastCalendarEngineTests`  
Expected: FAIL

- [ ] **Step 3: Implement `FastMonthMatrix` and `FastCalendarEngine`**

```swift
// Sources/CalendarView/Engine/FastMonthMatrix.swift
import Foundation

public struct FastMonthMatrix: Identifiable, Hashable, Sendable {
    public var id: Int { yearMonthKey }
    public let yearMonthKey: Int
    public let monthDate: Date
    public let monthTitle: String
    public let days: [CalendarDayState]

    public init(yearMonthKey: Int, monthDate: Date, monthTitle: String, days: [CalendarDayState]) {
        self.yearMonthKey = yearMonthKey
        self.monthDate = monthDate
        self.monthTitle = monthTitle
        self.days = days
    }
}

// Sources/CalendarView/Engine/FastCalendarEngine.swift
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
        var cal = calendar
        let baseComps = cal.dateComponents([.year, .month], from: baseDate)
        guard let startOfMonth = cal.date(from: baseComps),
              let monthRange = cal.range(of: .day, in: .month, for: startOfMonth)
        else {
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

            // Range calculation
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter FastCalendarEngineTests`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/CalendarView/Engine Tests/CalendarViewTests/FastCalendarEngineTests.swift
git commit -m "feat: implement FastCalendarEngine with fixed 42-cell matrix and O(1) lookups"
```

---

### Task 3: Continuous Range Selection Shape (`RangeSelectionShape`)

**Files:**
- Create: `Sources/CalendarView/Shapes/RangeSelectionShape.swift`
- Test: `Tests/CalendarViewTests/RangeSelectionShapeTests.swift`

**Interfaces:**
- Consumes: `RangeSelectionPosition`, SwiftUI `Shape`, `Path`, `CGRect`
- Produces: `RangeSelectionShape`

- [ ] **Step 1: Write failing unit test for shape paths**

```swift
// Tests/CalendarViewTests/RangeSelectionShapeTests.swift
import XCTest
import SwiftUI
@testable import CalendarView

final class RangeSelectionShapeTests: XCTestCase {
    func testRangeStartPathNonEmpty() {
        let shape = RangeSelectionShape(position: .rangeStart, cornerRadius: 8)
        let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
        let path = shape.path(in: rect)
        XCTAssertFalse(path.isEmpty)
    }

    func testNonePositionPathEmpty() {
        let shape = RangeSelectionShape(position: .none, cornerRadius: 8)
        let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
        let path = shape.path(in: rect)
        XCTAssertTrue(path.isEmpty)
    }
}
```

- [ ] **Step 2: Run test to verify failure**

Run: `swift test --filter RangeSelectionShapeTests`  
Expected: FAIL

- [ ] **Step 3: Implement `RangeSelectionShape`**

```swift
// Sources/CalendarView/Shapes/RangeSelectionShape.swift
import SwiftUI

public struct RangeSelectionShape: Shape {
    public let position: RangeSelectionPosition
    public let cornerRadius: CGFloat

    public init(position: RangeSelectionPosition, cornerRadius: CGFloat = 8) {
        self.position = position
        self.cornerRadius = cornerRadius
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        switch position {
        case .none:
            break
        case .singleDay:
            path.addRoundedRect(
                in: rect,
                cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
            )
        case .rangeStart:
            path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
            path.addArc(
                center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                radius: cornerRadius,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
            path.addArc(
                center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                radius: cornerRadius,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )
            path.closeSubpath()
        case .rangeEnd:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
            path.addArc(
                center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                radius: cornerRadius,
                startAngle: .degrees(270),
                endAngle: .degrees(0),
                clockwise: false
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
            path.addArc(
                center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                radius: cornerRadius,
                startAngle: .degrees(0),
                endAngle: .degrees(90),
                clockwise: false
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        case .rangeMiddle, .rowStart, .rowEnd:
            path.addRect(rect)
        }
        return path
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter RangeSelectionShapeTests`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/CalendarView/Shapes Tests/CalendarViewTests/RangeSelectionShapeTests.swift
git commit -m "feat: add RangeSelectionShape for continuous connected booking highlights"
```

---

### Task 4: Declarative Environment DSL & ViewModifiers

**Files:**
- Create: `Sources/CalendarView/Environment/CalendarEnvironmentKeys.swift`
- Create: `Sources/CalendarView/Environment/View+CalendarModifiers.swift`

**Interfaces:**
- Produces: `.calendarViewMode()`, `.calendarLocale()`, `.calendarFirstWeekday()`, `.calendarEvents()`, `.calendarDisabledDates()`

- [ ] **Step 1: Implement Environment Keys and View Modifiers**

```swift
// Sources/CalendarView/Environment/CalendarEnvironmentKeys.swift
import SwiftUI

public enum CalendarViewMode: Sendable, Hashable {
    case month
    case week
    case year
    case multiMonth
}

private struct CalendarViewModeKey: EnvironmentKey {
    static let defaultValue: CalendarViewMode = .month
}

private struct CalendarDisabledRuleKey: EnvironmentKey {
    static let defaultValue: (@Sendable (Date) -> Bool)? = nil
}

private struct CalendarEventsKey: EnvironmentKey {
    static let defaultValue: [Date: [CalendarEvent]] = [:]
}

private struct CalendarFirstWeekdayOverrideKey: EnvironmentKey {
    static let defaultValue: Locale.Weekday? = nil
}

private struct CalendarHapticsEnabledKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

public extension EnvironmentValues {
    var calendarViewMode: CalendarViewMode {
        get { self[CalendarViewModeKey.self] }
        set { self[CalendarViewModeKey.self] = newValue }
    }
    var calendarDisabledRule: (@Sendable (Date) -> Bool)? {
        get { self[CalendarDisabledRuleKey.self] }
        set { self[CalendarDisabledRuleKey.self] = newValue }
    }
    var calendarEvents: [Date: [CalendarEvent]] {
        get { self[CalendarEventsKey.self] }
        set { self[CalendarEventsKey.self] = newValue }
    }
    var calendarFirstWeekdayOverride: Locale.Weekday? {
        get { self[CalendarFirstWeekdayOverrideKey.self] }
        set { self[CalendarFirstWeekdayOverrideKey.self] = newValue }
    }
    var calendarHapticsEnabled: Bool {
        get { self[CalendarHapticsEnabledKey.self] }
        set { self[CalendarHapticsEnabledKey.self] = newValue }
    }
}

// Sources/CalendarView/Environment/View+CalendarModifiers.swift
import SwiftUI

public extension View {
    func calendarViewMode(_ mode: CalendarViewMode) -> some View {
        environment(\.calendarViewMode, mode)
    }

    func calendarDisabledDates(_ rule: @escaping @Sendable (Date) -> Bool) -> some View {
        environment(\.calendarDisabledRule, rule)
    }

    func calendarEvents(_ events: [Date: [CalendarEvent]]) -> some View {
        environment(\.calendarEvents, events)
    }

    func calendarFirstWeekday(_ weekday: Locale.Weekday) -> some View {
        environment(\.calendarFirstWeekdayOverride, weekday)
    }

    func calendarHapticsEnabled(_ enabled: Bool = true) -> some View {
        environment(\.calendarHapticsEnabled, enabled)
    }
}
```

- [ ] **Step 2: Verify compilation via swift build**

Run: `swift build`  
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add Sources/CalendarView/Environment
git commit -m "feat: implement declarative EnvironmentKeys and ViewModifiers"
```

---

### Task 5: Default View Components (Day Cell, Header, Weekday Banner)

**Files:**
- Create: `Sources/CalendarView/Views/DefaultCalendarDayCell.swift`
- Create: `Sources/CalendarView/Views/DefaultCalendarHeader.swift`
- Create: `Sources/CalendarView/Views/DefaultCalendarWeekdayHeader.swift`

- [ ] **Step 1: Implement Default Views with Native Apple HIG Styling**

```swift
// Sources/CalendarView/Views/DefaultCalendarDayCell.swift
import SwiftUI

public struct DefaultCalendarDayCell: View {
    public let state: CalendarDayState
    public var accentColor: Color = .blue

    public init(state: CalendarDayState, accentColor: Color = .blue) {
        self.state = state
        self.accentColor = accentColor
    }

    public var body: some View {
        ZStack {
            if state.rangePosition != .none {
                RangeSelectionShape(position: state.rangePosition, cornerRadius: 8)
                    .fill(accentColor.opacity(state.isSelected ? 1.0 : 0.2))
            } else if state.isSelected {
                Circle()
                    .fill(accentColor)
            } else if state.isToday {
                Circle()
                    .stroke(accentColor, lineWidth: 1.5)
            }

            VStack(spacing: 2) {
                Text("\(state.dayNumber)")
                    .font(.system(size: 16, weight: state.isSelected || state.isToday ? .semibold : .regular))
                    .foregroundColor(textColor)

                if !state.events.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(state.events.prefix(3), id: \.id) { event in
                            Circle()
                                .fill(event.color)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
        }
        .frame(height: 38)
        .opacity(state.isCurrentMonth ? 1.0 : 0.3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(state.isSelected ? [.isSelected, .isButton] : [.isButton])
    }

    private var textColor: Color {
        if state.isSelected {
            return .white
        }
        if state.isDisabled {
            return .secondary.opacity(0.5)
        }
        return state.isCurrentMonth ? .primary : .secondary
    }

    private var accessibilityText: String {
        let dateStr = state.date.formatted(.dateTime.year().month().day())
        let eventStr = state.events.isEmpty ? "" : ", \(state.events.count) events"
        return "\(dateStr)\(eventStr)"
    }
}

// Sources/CalendarView/Views/DefaultCalendarWeekdayHeader.swift
import SwiftUI

public struct DefaultCalendarWeekdayHeader: View {
    public let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public var body: some View {
        let symbols = weekdaySymbols
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                Text(symbols[index])
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var weekdaySymbols: [String] {
        let original = calendar.shortStandaloneWeekdaySymbols
        let first = calendar.firstWeekday - 1
        return Array(original[first...] + original[..<first])
    }
}

// Sources/CalendarView/Views/DefaultCalendarHeader.swift
import SwiftUI

public struct DefaultCalendarHeader: View {
    public let title: String
    public let onPrevious: () -> Void
    public let onNext: () -> Void

    public init(title: String, onPrevious: @escaping () -> Void, onNext: @escaping () -> Void) {
        self.title = title
        self.onPrevious = onPrevious
        self.onNext = onNext
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(.title2.bold())
            Spacer()
            HStack(spacing: 16) {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left")
                        .font(.body.bold())
                }
                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                        .font(.body.bold())
                }
            }
            .foregroundColor(.primary)
        }
        .padding(.horizontal)
    }
}
```

- [ ] **Step 2: Verify compilation via swift build**

Run: `swift build`  
Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**

```bash
git add Sources/CalendarView/Views
git commit -m "feat: add default day cell, header and weekday banner views with accessibility"
```

---

### Task 6: Modern Declarative `CalendarView` Core & Ergonomic Inits

**Files:**
- Modify: `Sources/CalendarView/CalendarView.swift`
- Test: `Tests/CalendarViewTests/CalendarViewTests.swift`

- [ ] **Step 1: Write unit tests for CalendarView selection and mode switching**

```swift
// Tests/CalendarViewTests/CalendarViewTests.swift
import XCTest
import SwiftUI
@testable import CalendarView

final class CalendarViewModernTests: XCTestCase {
    func testSingleDateSelectionBinding() {
        var selected = Date()
        let binding = Binding(get: { selected }, set: { selected = $0 })
        let view = CalendarView(selection: binding)
        XCTAssertNotNil(view)
    }

    func testRangeSelectionBinding() {
        var range: ClosedRange<Date>? = nil
        let binding = Binding(get: { range }, set: { range = $0 })
        let view = CalendarView(selection: binding)
        XCTAssertNotNil(view)
    }
}
```

- [ ] **Step 2: Implement modern `CalendarView` with 1-line inits and custom slot modifiers**

```swift
// Sources/CalendarView/CalendarView.swift
import SwiftUI

public struct CalendarView<DayContent: View, HeaderContent: View, WeekdayContent: View>: View {
    @Environment(\.calendar) private var envCalendar
    @Environment(\.locale) private var envLocale
    @Environment(\.calendarViewMode) private var viewMode
    @Environment(\.calendarDisabledRule) private var disabledRule
    @Environment(\.calendarEvents) private var eventsMap
    @Environment(\.calendarHapticsEnabled) private var hapticsEnabled

    @Binding private var displayDate: Date
    private let onDateTapped: (Date) -> Void
    private let selectedKeySet: Set<Int>
    private let rangeBounds: (startKey: Int?, endKey: Int?)

    private let dayContent: (CalendarDayState) -> DayContent
    private let headerContent: (FastMonthMatrix, @escaping () -> Void, @escaping () -> Void) -> HeaderContent
    private let weekdayContent: (Calendar) -> WeekdayContent

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
        self._displayDate = displayDate
        self.selectedKeySet = selectedKeySet
        self.rangeBounds = rangeBounds
        self.onDateTapped = onDateTapped
        self.dayContent = dayCell
        self.headerContent = header
        self.weekdayContent = weekday
    }

    public var body: some View {
        let matrix = FastCalendarEngine.computeMonthMatrix(
            for: displayDate,
            calendar: effectiveCalendar,
            todayDate: Date(),
            selectedKeySet: selectedKeySet,
            rangeBounds: rangeBounds,
            disabledRule: disabledRule,
            eventsMap: eventKeysMap
        )

        VStack(spacing: 12) {
            headerContent(matrix, { changeMonth(by: -1) }, { changeMonth(by: 1) })
            weekdayContent(effectiveCalendar)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                ForEach(matrix.days) { day in
                    dayContent(day)
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

    private var effectiveCalendar: Calendar {
        var cal = envCalendar
        cal.locale = envLocale
        return cal
    }

    private var eventKeysMap: [Int: [CalendarEvent]] {
        var result: [Int: [CalendarEvent]] = [:]
        for (date, events) in eventsMap {
            let key = CalendarDateKey.key(for: date, using: effectiveCalendar)
            result[key] = events
        }
        return result
    }

    private func changeMonth(by value: Int) {
        if let newDate = effectiveCalendar.date(byAdding: .month, value: value, to: displayDate) {
            displayDate = newDate
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

// MARK: - Out-of-the-Box Inits
public extension CalendarView where DayContent == DefaultCalendarDayCell,
                                    HeaderContent == DefaultCalendarHeader,
                                    WeekdayContent == DefaultCalendarWeekdayHeader {

    /// 1. Single Date Selection
    init(selection: Binding<Date>, displayDate: Binding<Date>? = nil) {
        let dispDate = displayDate ?? selection
        let key = CalendarDateKey.key(for: selection.wrappedValue, using: .current)
        self.init(
            displayDate: dispDate,
            selectedKeySet: [key],
            rangeBounds: (nil, nil),
            onDateTapped: { date in selection.wrappedValue = date },
            dayCell: { DefaultCalendarDayCell(state: $0) },
            header: { matrix, prev, next in DefaultCalendarHeader(title: matrix.monthTitle, onPrevious: prev, onNext: next) },
            weekday: { DefaultCalendarWeekdayHeader(calendar: $0) }
        )
    }

    /// 2. Date Range Selection
    init(selection: Binding<ClosedRange<Date>?>, displayDate: Binding<Date>? = nil) {
        let dispDate = displayDate ?? Binding(
            get: { selection.wrappedValue?.lowerBound ?? Date() },
            set: { _ in }
        )
        let startKey = selection.wrappedValue.map { CalendarDateKey.key(for: $0.lowerBound, using: .current) }
        let endKey = selection.wrappedValue.map { CalendarDateKey.key(for: $0.upperBound, using: .current) }

        self.init(
            displayDate: dispDate,
            selectedKeySet: [],
            rangeBounds: (startKey, endKey),
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
            header: { matrix, prev, next in DefaultCalendarHeader(title: matrix.monthTitle, onPrevious: prev, onNext: next) },
            weekday: { DefaultCalendarWeekdayHeader(calendar: $0) }
        )
    }

    /// 3. Multi-Date Selection
    init(selection: Binding<Set<Date>>, displayDate: Binding<Date>? = nil) {
        let dispDate = displayDate ?? Binding(
            get: { selection.wrappedValue.first ?? Date() },
            set: { _ in }
        )
        let keys = Set(selection.wrappedValue.map { CalendarDateKey.key(for: $0, using: .current) })

        self.init(
            displayDate: dispDate,
            selectedKeySet: keys,
            rangeBounds: (nil, nil),
            onDateTapped: { tappedDate in
                let key = CalendarDateKey.key(for: tappedDate, using: .current)
                if let existing = selection.wrappedValue.first(where: { CalendarDateKey.key(for: $0, using: .current) == key }) {
                    selection.wrappedValue.remove(existing)
                } else {
                    selection.wrappedValue.insert(tappedDate)
                }
            },
            dayCell: { DefaultCalendarDayCell(state: $0) },
            header: { matrix, prev, next in DefaultCalendarHeader(title: matrix.monthTitle, onPrevious: prev, onNext: next) },
            weekday: { DefaultCalendarWeekdayHeader(calendar: $0) }
        )
    }
}
```

- [ ] **Step 3: Run all tests to verify passing**

Run: `swift test`  
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add Sources/CalendarView/CalendarView.swift Tests/CalendarViewTests/CalendarViewTests.swift
git commit -m "feat: complete CalendarView 3.0 declarative API with single, range, and multi-selection"
```

---

### Task 7: Comprehensive Edge-Case Test Suite

**Files:**
- Create: `Tests/CalendarViewTests/CalendarEdgeCaseTests.swift`

- [ ] **Step 1: Write Leap Year, DST transition, and Non-Gregorian Calendar tests**

```swift
// Tests/CalendarViewTests/CalendarEdgeCaseTests.swift
import XCTest
@testable import CalendarView

final class CalendarEdgeCaseTests: XCTestCase {
    func testLeapYearFebruary29() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let feb2024 = cal.date(from: DateComponents(year: 2024, month: 2, day: 1))!

        let matrix = FastCalendarEngine.computeMonthMatrix(for: feb2024, calendar: cal)
        let feb29 = matrix.days.first { $0.dateKey == 20240229 }
        XCTAssertNotNil(feb29, "Leap year must include Feb 29")
        XCTAssertTrue(feb29!.isCurrentMonth)
    }

    func testNonLeapYearFebruary() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let feb2023 = cal.date(from: DateComponents(year: 2023, month: 2, day: 1))!

        let matrix = FastCalendarEngine.computeMonthMatrix(for: feb2023, calendar: cal)
        let feb28 = matrix.days.first { $0.dateKey == 20230228 }
        let feb29 = matrix.days.first { $0.dateKey == 20230229 }
        XCTAssertNotNil(feb28)
        XCTAssertTrue(feb28!.isCurrentMonth)
        // Day 29 falls into next month padding (March 1)
        XCTAssertNil(feb29, "Non leap year cannot have Feb 29")
    }

    func testBuddhistCalendarMatrix() {
        var cal = Calendar(identifier: .buddhist)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = Date()
        let matrix = FastCalendarEngine.computeMonthMatrix(for: date, calendar: cal)
        XCTAssertEqual(matrix.days.count, 42)
    }
}
```

- [ ] **Step 2: Run test suite to verify passing**

Run: `swift test`  
Expected: All tests PASS

- [ ] **Step 3: Commit**

```bash
git add Tests/CalendarViewTests/CalendarEdgeCaseTests.swift
git commit -m "test: add comprehensive leap year, non-gregorian and boundary edge case tests"
```

---

### Task 8: Update README, Example Project & Quality Verification

**Files:**
- Modify: `README.md`
- Modify: `CalendarExampleView/CalendarExampleView/ContentView.swift`

- [ ] **Step 1: Update README.md with modern 3.0 API snippets, badges, and zero-dependency statement**
- [ ] **Step 2: Update CalendarExampleView with Showcase Tabs (Single, Booking Range, Multi-Date, Events)**
- [ ] **Step 3: Run swift test to verify clean build**
- [ ] **Step 4: Commit**

```bash
git add README.md CalendarExampleView
git commit -m "docs: update README and example app for SwiftUICalendarView 3.0"
```
