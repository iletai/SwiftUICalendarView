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
    /// Adds calendar date accessibility to a view (thread-safe, localized).
    func calendarDateAccessibility(
        date: Date,
        isSelected: Bool,
        calendar: Calendar
    ) -> some View {
        let label = date.formatted(
            .dateTime
                .year()
                .month(.wide)
                .day()
                .weekday(.wide)
                .locale(calendar.locale ?? .current)
        )
        return self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isButton)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityHint(
                NSLocalizedString(
                    "Double tap to select this date",
                    value: "Double tap to select this date",
                    comment: "Accessibility hint for calendar date"
                )
            )
    }
}
