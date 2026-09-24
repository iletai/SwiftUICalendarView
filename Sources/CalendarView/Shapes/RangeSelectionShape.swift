import SwiftUI

/// A SwiftUI `Shape` that draws continuous connected highlights for date ranges in a calendar grid.
public struct RangeSelectionShape: Shape, Sendable, Equatable {
    /// The selection position of the day within a selected date range.
    public var position: RangeSelectionPosition
    /// Custom corner radius for rounded caps. Defaults to `nil` (using half cell height for full capsule caps).
    public var cornerRadius: CGFloat?

    public init(position: RangeSelectionPosition, cornerRadius: CGFloat? = nil) {
        self.position = position
        self.cornerRadius = cornerRadius
    }

    public init(_ position: RangeSelectionPosition, cornerRadius: CGFloat? = nil) {
        self.position = position
        self.cornerRadius = cornerRadius
    }

    public func path(in rect: CGRect) -> Path {
        guard !rect.isNull, !rect.isEmpty, rect.size.width > 0, rect.size.height > 0 else { return Path() }

        switch position {
        case .none:
            return Path()
        case .rangeMiddle:
            return Path(rect)
        case .singleDay:
            return makePath(in: rect, roundLeft: true, roundRight: true)
        case .rangeStart, .rowStart:
            return makePath(in: rect, roundLeft: true, roundRight: false)
        case .rangeEnd, .rowEnd:
            return makePath(in: rect, roundLeft: false, roundRight: true)
        }
    }

    private func makePath(in rect: CGRect, roundLeft: Bool, roundRight: Bool) -> Path {
        let r = cornerRadius ?? (rect.height / 2)
        let maxRadius = (roundLeft && roundRight) ? min(rect.width / 2, rect.height / 2) : min(rect.width, rect.height / 2)
        let radius = max(0, min(r, maxRadius))

        if radius == 0 {
            return Path(rect)
        }

        // Standard cubic bezier circle approximation constant: 4/3 * (sqrt(2) - 1)
        let k: CGFloat = 0.5522847498307933984
        let offset = (1 - k) * radius

        let minX = rect.minX
        let maxX = rect.maxX
        let minY = rect.minY
        let maxY = rect.maxY

        var path = Path()

        // Start at top-left
        let startX = roundLeft ? minX + radius : minX
        path.move(to: CGPoint(x: startX, y: minY))

        // Top horizontal edge
        let topEndX = roundRight ? maxX - radius : maxX
        path.addLine(to: CGPoint(x: topEndX, y: minY))

        // Right side
        if roundRight {
            path.addCurve(
                to: CGPoint(x: maxX, y: minY + radius),
                control1: CGPoint(x: maxX - offset, y: minY),
                control2: CGPoint(x: maxX, y: minY + offset)
            )
            path.addLine(to: CGPoint(x: maxX, y: maxY - radius))
            path.addCurve(
                to: CGPoint(x: maxX - radius, y: maxY),
                control1: CGPoint(x: maxX, y: maxY - offset),
                control2: CGPoint(x: maxX - offset, y: maxY)
            )
        } else {
            path.addLine(to: CGPoint(x: maxX, y: minY))
            path.addLine(to: CGPoint(x: maxX, y: maxY))
        }

        // Bottom horizontal edge
        let bottomEndX = roundLeft ? minX + radius : minX
        path.addLine(to: CGPoint(x: bottomEndX, y: maxY))

        // Left side
        if roundLeft {
            path.addCurve(
                to: CGPoint(x: minX, y: maxY - radius),
                control1: CGPoint(x: minX + offset, y: maxY),
                control2: CGPoint(x: minX, y: maxY - offset)
            )
            path.addLine(to: CGPoint(x: minX, y: minY + radius))
            path.addCurve(
                to: CGPoint(x: minX + radius, y: minY),
                control1: CGPoint(x: minX, y: minY + offset),
                control2: CGPoint(x: minX + offset, y: minY)
            )
        } else {
            path.addLine(to: CGPoint(x: minX, y: maxY))
            path.addLine(to: CGPoint(x: minX, y: minY))
        }

        path.closeSubpath()
        return path
    }
}
