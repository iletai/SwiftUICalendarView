# Changelog

All notable changes to SwiftUICalendarView will be documented in this file.

## [3.1.0] - 2026-09-27

### Major Enhancements & Full-Screen Experience
- **Interactive Multi-Mode Rendering** — Complete visual rendering for `.month`, `.year(.full)`, `.year(.compact)`, `.week`, and `.single` day views in `CalendarView.body`.
- **Fluid Swipe Gestures** — Added native `DragGesture` with velocity threshold and spring physics to switch months and weeks with haptic feedback.
- **FastCalendarEngine Week Calculation** — New `computeWeekMatrix(for:calendar:...)` calculating 7-day matrices respecting `calendar.firstWeekday`.
- **Edge-to-Edge Vibrant UI** — Full-width edge-to-edge layout with gradient hero headers, clear typography, and zero clipping.
- **Showcase Gallery Hub** — Brand new categorized card dashboard replacing old TabView overflow menu.
- **XcodeGen Integration** — Lightweight automatic `.xcodeproj` generation (`20KB`) with native `UILaunchScreen` support for full Retina resolution.

### Codebase Optimization
- **Cleaned Legacy Dead Code** — Removed unused legacy files: `CalendarViewOption`, `CalendarBackground`, `CalendarDay`, `CalendarSelectionMode`, `CalendarSelection`, `RootBuilder`, `CalendarWeekday`, `CalendarDefine`.
- **Test Suite Modernization** — 120 comprehensive unit tests covering date math, DST transitions, leap years, non-Gregorian calendars (Buddhist, Japanese, Islamic, Hebrew), range shapes, and environment modifiers.

---

## [2.0.0] - 2026-03-29

### Breaking Changes
- **Removed SwiftDate dependency** — All date operations now use native Swift `Calendar`/`Date` APIs.
- **Minimum iOS version** — Now requires iOS 17+ (previously iOS 16+).

### New Features
- **Binding support** — New `init(selectedDate: Binding<Date>, ...)` for two-way date binding.
- **Date range selection** — `.selectedRange(_:)` and `.onRangeSelected(_:)` modifiers for highlighting date ranges.
- **Event markers** — `.eventDates(_:)` modifier to show dot indicators on dates with events.
- **Accessibility** — Full VoiceOver support with date labels, button traits, and headers.
