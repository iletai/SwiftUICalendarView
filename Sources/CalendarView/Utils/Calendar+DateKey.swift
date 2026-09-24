import Foundation

public enum CalendarDateKey {
    @inlinable
    public static func makeKey(year: Int, month: Int, day: Int) -> Int {
        year * 10000 + month * 100 + day
    }

    @inlinable
    public static func deconstruct(key: Int) -> (year: Int, month: Int, day: Int) {
        let year = key / 10000
        let month = (key % 10000) / 100
        let day = key % 100
        return (year, month, day)
    }

    @inlinable
    public static func key(for date: Date, using calendar: Calendar) -> Int {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return makeKey(year: comps.year ?? 0, month: comps.month ?? 0, day: comps.day ?? 0)
    }
}
