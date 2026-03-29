# Changelog

All notable changes to SwiftUICalendarView will be documented in this file.

## [2.0.0] - 2026-03-29

### Breaking Changes

- **Removed SwiftDate dependency** — All date operations now use native Swift `Calendar`/`Date` APIs. This eliminates the heavy third-party dependency (~100+ files) that was no longer actively maintained.
- **Minimum iOS version** — Now requires iOS 17+ (previously iOS 16+).

### New Features

- **Binding support** — New `init(selectedDate: Binding<Date>, ...)` for two-way date binding.
- **Convenience init** — New init with `onSelectedDate` parameter for cleaner setup.
- **Date range selection** — `.selectedRange(_:)` and `.onRangeSelected(_:)` modifiers for highlighting date ranges.
- **Event markers** — `.eventDates(_:)` modifier to show dot indicators on dates with events.
- **Disabled dates** — `.disabledDates(_:)` modifier with visual dimming and hit-testing prevention.
- **Accessibility** — Full VoiceOver support with date labels, button traits, selected state, and header traits.
- **Background image** — `CalendarBackground.image` case now fully implemented (was declared but unused).

### Renamed APIs (Backward Compatible)

Old APIs are deprecated with `@available(*, deprecated, renamed:)` — existing code will still compile with warnings.

| Old Name | New Name |
|---|---|
| `calendarLocate(locale:)` | `calendarLocale(_:)` |
| `enablePinedView(_:)` | `enablePinnedView(_:)` |
| `enableHighlightToDay(_:)` | `enableHighlightToday(_:)` |
| `hightLightToDayView(_:_:)` | `highlightTodayView(_:_:)` |
| `withRounderConner(_:)` | `withRoundedCorner(_:)` |
| `isShowHightLightToDay` | `isHighlightToday` |
| `locateForCalendar` | `locale` |
| `kDistaneSwipeBack` | `kSwipeDistance` |
| `background(_:)` (CalendarBackground) | `backgroundCalendar(_:)` |

### Performance Improvements

- **Cached DateFormatters** — `weekDayName`, `weekDayShortName`, `dayName` now use static cached formatters instead of creating new ones per call.
- **Fixed visibility** — `allowVisibleWith(false)` now uses `hidden()` instead of `opacity(0)`, preventing unnecessary rendering of hidden views.
- **Removed redundant code** — `CalendarViewOption.defaultOption` simplified (was duplicating init values). Removed unused `isDisableScroll` and `dateRelatedType` properties.

### Test Coverage

- Added 60 unit tests covering date extensions, calendar enumeration, view options, view modes, and weekday enum.

### Documentation

- Updated README with corrected examples, migration guide, and new feature list.
- Updated podspec to v2.0.0 with iOS 17+ target.
