import Foundation

public enum RangeSelectionPosition: Sendable, Hashable {
    case none
    case singleDay
    case rangeStart
    case rangeMiddle
    case rangeEnd
    case rowStart
    case rowEnd
}

public struct CalendarDayState: Identifiable, Hashable, Sendable {
    public var id: Int { dateKey }
    public let dateKey: Int
    public let date: Date
    public let dayNumber: Int
    public let isCurrentMonth: Bool
    public let isToday: Bool
    public let isSelected: Bool
    public let isSelectable: Bool
    public let isDisabled: Bool
    public let rangePosition: RangeSelectionPosition
    public let events: [CalendarEvent]

    public init(
        dateKey: Int,
        date: Date,
        dayNumber: Int,
        isCurrentMonth: Bool,
        isToday: Bool,
        isSelected: Bool = false,
        isSelectable: Bool = true,
        isDisabled: Bool = false,
        rangePosition: RangeSelectionPosition = .none,
        events: [CalendarEvent] = []
    ) {
        self.dateKey = dateKey
        self.date = date
        self.dayNumber = dayNumber
        self.isCurrentMonth = isCurrentMonth
        self.isToday = isToday
        self.isSelected = isSelected
        self.isSelectable = isSelectable
        self.isDisabled = isDisabled
        self.rangePosition = rangePosition
        self.events = events
    }
}
