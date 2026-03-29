//
//  CalendarTheme.swift
//
//
//  Created by SwiftUICalendarView on 2025.
//

import SwiftUI

/// A theme configuration for customizing the calendar's visual appearance.
public struct CalendarTheme: Sendable {
    /// Color for today's date highlight.
    public var todayColor: Color
    /// Color for selected date(s) background.
    public var selectedColor: Color
    /// Color for weekend day text.
    public var weekendColor: Color
    /// Color for disabled date text.
    public var disabledColor: Color
    /// Color for date-out (outside current month) text.
    public var dateOutColor: Color
    /// Color for event indicator dots.
    public var eventIndicatorColor: Color
    /// Font for day numbers.
    public var dayFont: Font
    /// Font for header weekday names.
    public var headerFont: Font
    /// Font for month titles.
    public var titleFont: Font

    /// The default theme using system-adaptive colors.
    public static var `default`: CalendarTheme {
        #if canImport(UIKit)
        let disabled = Color(UIColor.tertiaryLabel)
        let dateOut = Color(UIColor.secondaryLabel)
        #elseif canImport(AppKit)
        let disabled = Color(NSColor.tertiaryLabelColor)
        let dateOut = Color(NSColor.secondaryLabelColor)
        #endif
        return CalendarTheme(
            todayColor: .orange,
            selectedColor: .accentColor.opacity(0.3),
            weekendColor: .red,
            disabledColor: disabled,
            dateOutColor: dateOut,
            eventIndicatorColor: .accentColor,
            dayFont: .footnote,
            headerFont: .footnote.bold(),
            titleFont: .footnote.bold()
        )
    }

    /// A convenience dark theme with colors optimized for dark backgrounds.
    public static var dark: CalendarTheme {
        CalendarTheme(
            todayColor: .orange,
            selectedColor: .blue.opacity(0.4),
            weekendColor: .red.opacity(0.8),
            disabledColor: .white.opacity(0.2),
            dateOutColor: .white.opacity(0.4),
            eventIndicatorColor: .cyan,
            dayFont: .footnote,
            headerFont: .footnote.bold(),
            titleFont: .footnote.bold()
        )
    }

    public init(
        todayColor: Color = .orange,
        selectedColor: Color = .blue.opacity(0.3),
        weekendColor: Color = .red,
        disabledColor: Color = .gray.opacity(0.3),
        dateOutColor: Color = .gray,
        eventIndicatorColor: Color = .blue,
        dayFont: Font = .footnote,
        headerFont: Font = .footnote.bold(),
        titleFont: Font = .footnote.bold()
    ) {
        self.todayColor = todayColor
        self.selectedColor = selectedColor
        self.weekendColor = weekendColor
        self.disabledColor = disabledColor
        self.dateOutColor = dateOutColor
        self.eventIndicatorColor = eventIndicatorColor
        self.dayFont = dayFont
        self.headerFont = headerFont
        self.titleFont = titleFont
    }
}
