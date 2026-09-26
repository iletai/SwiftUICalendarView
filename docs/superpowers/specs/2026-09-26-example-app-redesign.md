# Specification: Example App UI/UX Redesign (Apple Native HIG Premium)

**Document Version:** 3.1.0  
**Date:** 2026-09-26  
**Status:** Approved for Implementation  
**Target:** Example app showcase for iOS 17+  

---

## 1. Executive Summary & Goals

Transform the Example app from an unpolished, clipped TabView with "More..." overflow into an Apple Design Award-tier Showcase Gallery app.

### Key Deliverables
1. **Navigation:** Replace root `TabView` with a categorized `NavigationStack` Gallery Hub (`ShowcaseGalleryView`). No "More..." clipping.
2. **Design System:** Apple Native HIG with `systemGroupedBackground` and `secondarySystemGroupedBackground`, hairline borders, rich SF Symbols with custom tint backgrounds, capsule badges.
3. **Hierarchy & Spacing:** Generous padding, structured card sections, bottom safe area insets so calendar cells are never obscured.
4. **Interactive Controls:** Modern iOS-style control cards with segmented pickers, quick preset buttons, and haptic feedback.
5. **Demos Refined:**
   - Single Date Picker
   - Booking Range (with Nights Badge & Quick Presets)
   - Multi-Date Picker (with selected dates chip list)
   - Year View (Full / Compact switch, auto-scroll to current month)
   - Week View (Week pagination, summary card)
   - Event Calendar (Multi-color dot indicators & Agenda list)
   - Global Calendars & Custom Slots (Locale picker + Buddhist/Japanese/Islamic calendars)

---

## 2. File Structure

```
Example/
├── ExampleApp.swift            # App entry point with modern navigation setup
├── ContentView.swift           # Root ShowcaseGalleryView (Dashboard Cards)
└── Demos/
    ├── SingleDateDemo.swift    # Single date picker showcase
    ├── BookingRangeDemo.swift  # Booking range with continuous ribbon highlight
    ├── MultiDateDemo.swift     # Multi-date selection & chips
    ├── YearCalendarDemo.swift  # 12-month grid with auto-scroll
    ├── WeekCalendarDemo.swift  # 7-day strip with week pagination
    ├── EventCalendarDemo.swift # Event indicators with agenda timeline
    └── CustomSlotLocaleDemo.swift # Non-Gregorian & custom day cell builder
```
