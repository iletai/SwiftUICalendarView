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
    ///
    /// - Returns: A modified view with the maximum width set to infinity.
    public func maxWidthAble() -> some View {
        frame(maxWidth: .infinity)
    }

    /// Sets the maximum height of the view to infinity.
    ///
    /// - Returns: A modified view with the maximum height set to infinity.
    public func maxHeightAble() -> some View {
        frame(maxHeight: .infinity)
    }

    /// Sets both the maximum width and maximum height of the view to infinity.
    ///
    /// - Returns: A modified view with both the maximum width and maximum height set to infinity.
    public func frameInfinity() -> some View {
        maxWidthAble().maxHeightAble()
    }

    /// Sets the padding of the view to a default value of 16 on all sides.
    ///
    /// - Returns: A modified view with the padding set to a default value of 16 on all sides.
    public func marginDefault() -> some View {
        padding(.all, 16)
    }

    /// Clips the view to the specified corner radius.
    ///
    /// - Parameter radius: The corner radius to apply to the view.
    /// - Returns: A modified view with the specified corner radius applied.
    public func withRounderConner(_ radius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

extension View {
    /**
     Highlights the day view if it is today.

     This modifier applies a background color to the view if the date is today.
     - Parameters:
     - isToday: A boolean value indicating whether the date is today.
     - color: The color to use for highlighting. Default is `.orange`.
     - Returns: A modified SwiftUI `View` with the highlighting applied.
     */
    @ViewBuilder
    func hightLightToDayView(
        _ isToday: Bool,
        _ color: Color = .orange
    ) -> some View {
        if isToday {
            background(color.clipShape(Circle()))
        } else {
            self
        }
    }

    /**
     Sets the visibility of the view based on a boolean value.

     This modifier sets the opacity of the view to 1.0 if the `isAllow` parameter is `true`, otherwise sets it to 0.0.
     - Parameter isAllow: A boolean value indicating whether the view should be visible.
     - Returns: A modified SwiftUI `View` with the visibility set.
     */
    @ViewBuilder
    func allowVisibleWith(_ isAllow: Bool) -> some View {
        opacity(isAllow ? 1.0 : 0.0)
    }
}
