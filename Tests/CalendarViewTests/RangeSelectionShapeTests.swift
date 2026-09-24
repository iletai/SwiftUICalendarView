import XCTest
import SwiftUI
@testable import CalendarView

final class RangeSelectionShapeTests: XCTestCase {
    private let testRect = CGRect(x: 0, y: 0, width: 40, height: 40)

    func testNonePositionProducesEmptyPath() {
        let shape = RangeSelectionShape(position: .none)
        let path = shape.path(in: testRect)

        XCTAssertTrue(path.isEmpty)
        XCTAssertFalse(path.contains(CGPoint(x: 20, y: 20)))
    }

    func testSingleDayPositionPathGeneration() {
        let shape = RangeSelectionShape(position: .singleDay)
        let path = shape.path(in: testRect)

        XCTAssertFalse(path.isEmpty)
        // Center of cell must be inside
        XCTAssertTrue(path.contains(CGPoint(x: 20, y: 20)))
        // Cardinal inner points must be inside
        XCTAssertTrue(path.contains(CGPoint(x: 20, y: 2)))
        XCTAssertTrue(path.contains(CGPoint(x: 20, y: 38)))
        XCTAssertTrue(path.contains(CGPoint(x: 2, y: 20)))
        XCTAssertTrue(path.contains(CGPoint(x: 38, y: 20)))
        // Four sharp outer corners of square bounding box must NOT be inside rounded cap
        XCTAssertFalse(path.contains(CGPoint(x: 1, y: 1)))
        XCTAssertFalse(path.contains(CGPoint(x: 39, y: 1)))
        XCTAssertFalse(path.contains(CGPoint(x: 1, y: 39)))
        XCTAssertFalse(path.contains(CGPoint(x: 39, y: 39)))
    }

    func testRangeStartPositionPathGeneration() {
        let shape = RangeSelectionShape(position: .rangeStart)
        let path = shape.path(in: testRect)

        XCTAssertFalse(path.isEmpty)
        // Center is inside
        XCTAssertTrue(path.contains(CGPoint(x: 20, y: 20)))
        // Left side is rounded: top-left & bottom-left corners are outside
        XCTAssertFalse(path.contains(CGPoint(x: 1, y: 1)))
        XCTAssertFalse(path.contains(CGPoint(x: 1, y: 39)))
        // Right side is flat: top-right & bottom-right corners are inside (connecting edge)
        XCTAssertTrue(path.contains(CGPoint(x: 39, y: 1)))
        XCTAssertTrue(path.contains(CGPoint(x: 39, y: 39)))
    }

    func testRangeMiddlePositionPathGeneration() {
        let shape = RangeSelectionShape(position: .rangeMiddle)
        let path = shape.path(in: testRect)

        XCTAssertFalse(path.isEmpty)
        XCTAssertEqual(path.boundingRect, testRect)
        // All four corners are inside full rectangle
        XCTAssertTrue(path.contains(CGPoint(x: 1, y: 1)))
        XCTAssertTrue(path.contains(CGPoint(x: 39, y: 1)))
        XCTAssertTrue(path.contains(CGPoint(x: 1, y: 39)))
        XCTAssertTrue(path.contains(CGPoint(x: 39, y: 39)))
        XCTAssertTrue(path.contains(CGPoint(x: 20, y: 20)))
    }

    func testRangeEndPositionPathGeneration() {
        let shape = RangeSelectionShape(position: .rangeEnd)
        let path = shape.path(in: testRect)

        XCTAssertFalse(path.isEmpty)
        // Center is inside
        XCTAssertTrue(path.contains(CGPoint(x: 20, y: 20)))
        // Left side is flat: top-left & bottom-left corners are inside (connecting edge)
        XCTAssertTrue(path.contains(CGPoint(x: 1, y: 1)))
        XCTAssertTrue(path.contains(CGPoint(x: 1, y: 39)))
        // Right side is rounded: top-right & bottom-right corners are outside
        XCTAssertFalse(path.contains(CGPoint(x: 39, y: 1)))
        XCTAssertFalse(path.contains(CGPoint(x: 39, y: 39)))
    }

    func testRowStartPositionPathGeneration() {
        let shape = RangeSelectionShape(position: .rowStart)
        let path = shape.path(in: testRect)

        XCTAssertFalse(path.isEmpty)
        // Center is inside
        XCTAssertTrue(path.contains(CGPoint(x: 20, y: 20)))
        // Left side rounded, right side flat
        XCTAssertFalse(path.contains(CGPoint(x: 1, y: 1)))
        XCTAssertFalse(path.contains(CGPoint(x: 1, y: 39)))
        XCTAssertTrue(path.contains(CGPoint(x: 39, y: 1)))
        XCTAssertTrue(path.contains(CGPoint(x: 39, y: 39)))
    }

    func testRowEndPositionPathGeneration() {
        let shape = RangeSelectionShape(position: .rowEnd)
        let path = shape.path(in: testRect)

        XCTAssertFalse(path.isEmpty)
        // Center is inside
        XCTAssertTrue(path.contains(CGPoint(x: 20, y: 20)))
        // Left side flat, right side rounded
        XCTAssertTrue(path.contains(CGPoint(x: 1, y: 1)))
        XCTAssertTrue(path.contains(CGPoint(x: 1, y: 39)))
        XCTAssertFalse(path.contains(CGPoint(x: 39, y: 1)))
        XCTAssertFalse(path.contains(CGPoint(x: 39, y: 39)))
    }

    func testCustomCornerRadius() {
        let shape = RangeSelectionShape(position: .singleDay, cornerRadius: 4)
        let path = shape.path(in: testRect)

        XCTAssertFalse(path.isEmpty)
        // Point (10, 10) is well inside with 4pt corner radius
        XCTAssertTrue(path.contains(CGPoint(x: 10, y: 10)))
        // Point (20, 20) center is inside
        XCTAssertTrue(path.contains(CGPoint(x: 20, y: 20)))
    }

    func testZeroAndNegativeRectProducesEmptyPath() {
        let shape = RangeSelectionShape(position: .singleDay)

        let zeroPath = shape.path(in: .zero)
        XCTAssertTrue(zeroPath.isEmpty)

        let negativePath = shape.path(in: CGRect(x: 0, y: 0, width: -10, height: 40))
        XCTAssertTrue(negativePath.isEmpty)
    }

    func testAllPositionsCoverage() {
        let positions: [RangeSelectionPosition] = [
            .none,
            .singleDay,
            .rangeStart,
            .rangeMiddle,
            .rangeEnd,
            .rowStart,
            .rowEnd
        ]

        for pos in positions {
            let shape = RangeSelectionShape(pos)
            let path = shape.path(in: testRect)
            if pos == .none {
                XCTAssertTrue(path.isEmpty)
            } else {
                XCTAssertFalse(path.isEmpty)
            }
        }
    }
}
