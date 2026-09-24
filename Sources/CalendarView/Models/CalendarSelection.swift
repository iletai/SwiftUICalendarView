import Foundation

/// Represents the selection state in a calendar.
public enum CalendarSelection: Hashable, Sendable {
    case none
    case single(Date)
    case range(ClosedRange<Date>)
    case multiple(Set<Date>)
}
