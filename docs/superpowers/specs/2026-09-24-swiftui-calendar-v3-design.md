# Specification: SwiftUICalendarView 3.0

**Document Version:** 3.0.0  
**Date:** 2026-09-24  
**Status:** Approved for Implementation  
**Target Platforms:** iOS 16.0+, macOS 13.0+, visionOS 1.0+, watchOS 10.0+  
**Dependencies:** Zero external dependencies (Pure Swift & SwiftUI)  

---

## 1. Executive Summary & Core Pillars

SwiftUICalendarView 3.0 is a complete reimagining of the calendar component library for Apple platforms. It is engineered to become the #1 choice on GitHub by delivering native SwiftUI ergonomics, 120fps fluid performance, zero external dependencies (&lt; 80KB binary footprint), and complete visual customization.

### Core Pillars
1. **Zero-Boilerplate API (SwiftUI Idiomatic):** One-line initializers (`CalendarView(selection: $date)`), configured via declarative ViewModifiers and Environment values rather than monolithic configuration structs.
2. **Deterministic High-Performance Date Engine:** Pre-computed immutable 42-day matrices with integer-based date keys (`YYYYMMDD`), achieving $O(1)$ selection/event lookups and zero heap allocations inside SwiftUI `body` passes.
3. **Fluid Interactive Gestures & Animations:** Native swipe paging (with iOS 16/17 dual-engine fallback), interactive month-to-week scope transitions, and continuous drag-to-select range gestures with haptic feedback.
4. **Accessible & Global-Ready:** Native VoiceOver accessibility actions and dynamic traits, full RTL mirror support, and comprehensive support for non-Gregorian calendars (Buddhist, Islamic, Japanese, Hebrew).

---

## 2. Public API Architecture

### 2.1. Selection Modes & Initializers

The core `CalendarView` provides dedicated initializers for three distinct selection paradigms:

```swift
import SwiftUI

public struct CalendarView<DayContent: View, HeaderContent: View, WeekdayContent: View>: View {
    // MARK: - Environment & State
    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale
    @Environment(\.calendarViewMode) private var viewMode
    @Environment(\.calendarFirstWeekday) private var customFirstWeekday
    @Environment(\.calendarDisabledRule) private var disabledRule
    @Environment(\.calendarEvents) private var events

    @Binding private var displayDate: Date
    private let selectionHandler: ((Date) -> Void)?
    private let isSelectedPredicate: @Sendable (Date) -> Bool
    private let isInRangePredicate: @Sendable (Date) -> Bool
    private let rangePositionPredicate: @Sendable (Date) -> RangeSelectionPosition

    // ViewBuilder Slots
    private let dayContent: (CalendarDayState) -> DayContent
    private let headerContent: ([Date]) -> HeaderContent
    private let weekdayContent: (Int) -> WeekdayContent
}
```

#### Out-of-the-Box Inits (Default Native Views)

```swift
extension CalendarView where DayContent == DefaultCalendarDayCell,
                             HeaderContent == DefaultCalendarHeader,
                             WeekdayContent == DefaultCalendarWeekdayHeader {

    /// 1. Single Date Selection
    public init(selection: Binding<Date>, displayDate: Binding<Date>? = nil) { ... }

    /// 2. Date Range Selection (Airbnb Booking Style)
    public init(selection: Binding<ClosedRange<Date>?>, displayDate: Binding<Date>? = nil) { ... }

    /// 3. Multi-Date Selection
    public init(selection: Binding<Set<Date>>, displayDate: Binding<Date>? = nil) { ... }

    /// 4. Read-Only Display (Agenda / Viewer)
    public init(displayDate: Binding<Date>) { ... }
}
```

### 2.2. ViewBuilder Slot Customization

Developers can override specific visual layers while retaining the underlying gesture and selection engine:

```swift
CalendarView(selection: $selectedRange)
    .calendarDayCell { state in
        // Custom Day Cell Slot
        VStack(spacing: 2) {
            Text("\(state.dayNumber)")
                .font(.system(size: 16, weight: state.isSelected ? .bold : .regular))
                .foregroundColor(state.isCurrentMonth ? .primary : .secondary)
            if !state.events.isEmpty {
                HStack(spacing: 2) {
                    ForEach(state.events.prefix(3), id: \.id) { event in
                        Circle().fill(event.color).frame(width: 4, height: 4)
                    }
                }
            }
        }
    }
    .calendarHeader { visibleDates in
        CustomMonthHeader(visibleDates: visibleDates)
    }
    .calendarWeekdayHeader { weekdayIndex in
        CustomWeekdayBadge(weekdayIndex: weekdayIndex)
    }
```

### 2.3. Declarative ViewModifiers & Environment DSL

```swift
public extension View {
    /// Configures calendar display mode: .month, .week, .year, .multiMonth
    func calendarViewMode(_ mode: CalendarViewMode) -> some View

    /// Configures locale (affects month titles, weekday names)
    func calendarLocale(_ locale: Locale) -> some View

    /// Overrides first day of the week (.sunday, .monday, etc.)
    func calendarFirstWeekday(_ weekday: Locale.Weekday) -> some View

    /// Injects event markers mapped by date
    func calendarEvents(_ events: [Date: [CalendarEvent]]) -> some View

    /// Disables dates according to a custom predicate
    func calendarDisabledDates(_ rule: @escaping @Sendable (Date) -> Bool) -> some View

    /// Minimum and maximum selectable date boundaries
    func calendarDateRange(from start: Date?, to end: Date?) -> some View

    /// Haptic feedback toggle on date interaction
    func calendarHapticsEnabled(_ enabled: Bool = true) -> some View
}
```

---

## 3. Data Models & High-Performance Date Engine

### 3.1. Unified Day State Model (`CalendarDayState`)

```swift
public struct CalendarDayState: Identifiable, Hashable, Sendable {
    public var id: Int { dateKey }
    public let dateKey: Int // Format: YYYYMMDD (e.g. 20260924)
    public let date: Date
    public let dayNumber: Int
    
    // Status Flags
    public let isCurrentMonth: Bool
    public let isToday: Bool
    public let isSelected: Bool
    public let isSelectable: Bool
    public let isDisabled: Bool
    
    // Range Flags
    public let rangePosition: RangeSelectionPosition
    
    // Associated Events
    public let events: [CalendarEvent]
}

public enum RangeSelectionPosition: Sendable, Hashable {
    case none
    case singleDay
    case rangeStart
    case rangeMiddle
    case rangeEnd
    case rowStart
    case rowEnd
}
```

### 3.2. FastCalendarEngine & Allocation Elimination

```swift
public enum FastCalendarEngine {
    @inlinable
    public static func dateKey(year: Int, month: Int, day: Int) -> Int {
        year * 10000 + month * 100 + day
    }

    /// Computes normalized 42-cell matrix (6 rows x 7 columns) for jitter-free layout.
    public static func computeMonthMatrix(
        for baseDate: Date,
        calendar: Calendar,
        todayDate: Date = Date(),
        selectedKeySet: Set<Int>,
        rangeBounds: (startKey: Int?, endKey: Int?),
        disabledRule: (@Sendable (Date) -> Bool)? = nil,
        eventsMap: [Int: [CalendarEvent]] = [:]
    ) -> FastMonthMatrix { ... }
}
```

**Key Optimizations:**
1. **$O(1)$ Hash Set Lookups:** `selectedKeySet.contains(day.dateKey)` replaces costly $O(N)$ `calendar.isDate(_:inSameDayAs:)` scans.
2. **Fixed 42-Day Frame:** Prevents layout jump when scrolling between 4-week (February non-leap), 5-week, and 6-week months.
3. **Thread-Safe FormatStyle:** Eliminates static `DateFormatter` locks and ICU initialization churn.
4. **DST-Safe Math:** Uses `DateComponents` normalized to midnight UTC/Locale to prevent 23-hour / 25-hour day skew.

---

## 4. Visual Components & Animations

### 4.1. Continuous Connected Range Shape (`RangeSelectionShape`)

Unlike traditional square day cells, `RangeSelectionShape` renders a seamless background band across dates and multi-week rows:

```swift
public struct RangeSelectionShape: Shape {
    public let position: RangeSelectionPosition
    public let cornerRadius: CGFloat
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        switch position {
        case .none:
            break
        case .singleDay:
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        case .rangeStart:
            // Curved cap on left, straight edge on right
            path.addPath(UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius,
                bottomLeadingRadius: cornerRadius,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            ).path(in: rect))
        case .rangeEnd:
            // Straight edge on left, curved cap on right
            path.addPath(UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: cornerRadius,
                topTrailingRadius: cornerRadius
            ).path(in: rect))
        case .rangeMiddle, .rowStart, .rowEnd:
            // Full width rectangular connection
            path.addRect(rect)
        }
        return path
    }
}
```

### 4.2. Interactive Month $\leftrightarrow$ Week Collapse Transition

- Interpolates vertical grid height using `matchedGeometryEffect` and spring physics: `Animation.spring(response: 0.35, dampingFraction: 0.82)`.
- Automatically keeps the selected date's row visible while fading/masking non-selected rows during collapse.

### 4.3. Dual-Engine Paging Modifier

```swift
struct CalendarPagingModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            content
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
        } else {
            content
            // TabView / PageView fallback for iOS 16
        }
    }
}
```

---

## 5. Accessibility & Internationalization (A11y & i18n)

1. **VoiceOver Announcements:**
   - Label: Localized date (e.g. *"Tuesday, September 24, 2026"*).
   - Value: Selection state + event count (e.g. *"Selected, 2 scheduled events"*).
   - Actions: Custom accessibility actions for `.range` mode: *"Set as Check-in Date"*, *"Set as Check-out Date"*.
2. **Dynamic Type:** All default components adapt to `.accessibilityLarge` sizes with flexible vertical cell heights.
3. **Right-to-Left (RTL) Support:** First weekday columns and swipe direction mirror automatically when running in Arabic or Hebrew environments.

---

## 6. Directory Structure & File Map

```
Sources/CalendarView/
├── CalendarView.swift                 # Main Entry Point & Ergonomic Inits
├── Engine/
│   ├── FastCalendarEngine.swift       # Pure Math Date Engine (Allocation-Free)
│   └── FastMonthMatrix.swift          # Pre-computed immutable grid models
├── Models/
│   ├── CalendarDayState.swift         # Unified Day State Model
│   ├── CalendarEvent.swift            # Multi-Event Model
│   ├── CalendarSelection.swift        # Selection Types & Protocols
│   └── CalendarViewMode.swift         # .month, .week, .year, .multiMonth
├── Environment/
│   ├── CalendarEnvironmentKeys.swift  # Environment keys for styling & rules
│   └── View+CalendarModifiers.swift   # Declarative ViewModifier DSL
├── Shapes/
│   └── RangeSelectionShape.swift      # Connected Range Highlight Path
├── Views/
│   ├── DefaultCalendarDayCell.swift   # Default Cell View
│   ├── DefaultCalendarHeader.swift    # Default Header & Month Picker
│   ├── DefaultCalendarWeekdayHeader.swift # Default Weekday Banner
│   └── CalendarPagingView.swift       # iOS 16/17 Dual-Engine Paging Grid
└── Utils/
    ├── Calendar+DateKey.swift         # Integer date key utilities
    └── Accessibility+Calendar.swift   # VoiceOver & Traits helpers
```

---

## 7. Migration Plan (v2.x $\rightarrow$ v3.0)

1. **Deprecations with Fix-its:**
   - Mark `CalendarViewOption` as `@available(*, deprecated, message: "Use ViewModifiers like .calendarViewMode() instead.")`.
   - Provide binary compatibility shims for `init(date:dateView:headerView:dateOutView:)`.
2. **Removal of dead code:**
   - Delete `RootBuilder.swift` and reflection mutation helpers.
   - Replace manual while-loops in `Calendar+Extension.swift` with `FastCalendarEngine`.
3. **Test Suite Modernization:**
   - Add unit tests for leap years (e.g. Feb 29, 2024 / 2028), DST boundaries, non-Gregorian calendars, and range shape geometries.
