import CoreGraphics

/// Decides whether a drag is a horizontal paging swipe or should be left to an enclosing vertical scroll view.
enum SwipeIntent {
    /// Horizontal travel must exceed vertical travel by this factor to count as a page swipe.
    static let horizontalBias: CGFloat = 1.2

    static func isHorizontal(_ translation: CGSize) -> Bool {
        abs(translation.width) > abs(translation.height) * horizontalBias
    }
}
