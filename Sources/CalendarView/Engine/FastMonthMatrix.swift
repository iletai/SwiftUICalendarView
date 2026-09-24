import Foundation

public struct FastMonthMatrix: Identifiable, Hashable, Sendable {
    public var id: Int { yearMonthKey }
    public let yearMonthKey: Int
    public let monthDate: Date
    public let monthTitle: String
    public let days: [CalendarDayState]

    public init(yearMonthKey: Int, monthDate: Date, monthTitle: String, days: [CalendarDayState]) {
        self.yearMonthKey = yearMonthKey
        self.monthDate = monthDate
        self.monthTitle = monthTitle
        self.days = days
    }
}
