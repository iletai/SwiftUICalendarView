//
//  View+Extension.swift
//
//
//  Created by Lê Quang Trọng Tài on 12/31/23.
//

import Foundation
import SwiftUI

extension View {
    /// Sets the maximum width of the view to infinity.
    public func maxWidthAble() -> some View {
        frame(maxWidth: .infinity)
    }

    /// Sets the maximum height of the view to infinity.
    public func maxHeightAble() -> some View {
        frame(maxHeight: .infinity)
    }

    /// Sets both the maximum width and maximum height of the view to infinity.
    public func frameInfinity() -> some View {
        maxWidthAble().maxHeightAble()
    }

    /// Sets the padding of the view with configurable edges and length.
    public func marginDefault(_ edges: Edge.Set = .all, _ length: CGFloat = 16) -> some View {
        padding(edges, length)
    }

    /// Clips the view to the specified corner radius.
    public func withRoundedCorner(_ radius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius))
    }

    /// Deprecated: Use `withRoundedCorner` instead.
    @available(*, deprecated, renamed: "withRoundedCorner")
    public func withRounderConner(_ radius: CGFloat) -> some View {
        withRoundedCorner(radius)
    }
}

extension View {
    /// Highlights the day view if it is today.
    @ViewBuilder
    func highlightTodayView(
        _ isToday: Bool,
        _ color: Color = .orange
    ) -> some View {
        if isToday {
            background(color.clipShape(Circle()))
        } else {
            self
        }
    }

    /// Deprecated: Use `highlightTodayView` instead.
    @available(*, deprecated, renamed: "highlightTodayView")
    @ViewBuilder
    func hightLightToDayView(
        _ isToday: Bool,
        _ color: Color = .orange
    ) -> some View {
        highlightTodayView(isToday, color)
    }

    /// Sets the visibility of the view based on a boolean value.
    @ViewBuilder
    func allowVisibleWith(_ isAllow: Bool) -> some View {
        if isAllow {
            self
        } else {
            hidden()
        }
    }
}

extension View {
    /// Adds calendar date accessibility to a view.
    func calendarDateAccessibility(
        date: Date,
        isSelected: Bool,
        calendar: Calendar
    ) -> some View {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.calendar = calendar
        return self
            .accessibilityLabel(formatter.string(from: date))
            .accessibilityAddTraits(.isButton)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityHint("Double tap to select this date")
    }
}

extension View {
    /// Highlights view if the date falls within the selected range.
    @ViewBuilder
    func highlightIfInRange(
        _ date: Date,
        range: ClosedRange<Date>?,
        color: Color = .blue.opacity(0.2)
    ) -> some View {
        if let range, range.contains(date) {
            self.background(color)
        } else {
            self
        }
    }
}

extension View {
    /// Highlights the view if the date is in the selected dates set.
    @ViewBuilder
    func highlightIfSelected(
        _ date: Date,
        selectedDates: Set<Date>,
        calendar: Calendar,
        color: Color = .blue.opacity(0.3)
    ) -> some View {
        let isSelected = selectedDates.contains { calendar.isDate($0, inSameDayAs: date) }
        if isSelected {
            self.background(color.clipShape(RoundedRectangle(cornerRadius: 4)))
        } else {
            self
        }
    }
}

extension View {
    /// Dims and disables interaction if the date is outside the min/max bounds.
    @ViewBuilder
    func applyDateBounds(
        _ date: Date,
        minimum: Date?,
        maximum: Date?,
        calendar: Calendar
    ) -> some View {
        let isOutOfBounds = {
            if let min = minimum, calendar.compare(date, to: min, toGranularity: .day) == .orderedAscending {
                return true
            }
            if let max = maximum, calendar.compare(date, to: max, toGranularity: .day) == .orderedDescending {
                return true
            }
            return false
        }()
        if isOutOfBounds {
            self.opacity(0.3).allowsHitTesting(false)
        } else {
            self
        }
    }
}

extension View {
    /// Shows a small dot indicator below the view if the date has events.
    @ViewBuilder
    func eventIndicator(
        for date: Date,
        events: Set<Date>?,
        color: Color = .blue
    ) -> some View {
        if let events {
            let calendar = Calendar.current
            let hasEvent = events.contains { calendar.isDate($0, inSameDayAs: date) }
            if hasEvent {
                VStack(spacing: 2) {
                    self
                    Circle()
                        .fill(color)
                        .frame(width: 4, height: 4)
                }
            } else {
                self
            }
        } else {
            self
        }
    }
}
