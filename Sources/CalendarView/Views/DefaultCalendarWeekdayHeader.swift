import SwiftUI

/// Default weekday header component that displays short weekday names shifted by `calendar.firstWeekday`.
public struct DefaultCalendarWeekdayHeader: View {
    public let calendar: Calendar

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public var weekdaySymbols: [String] {
        let original = calendar.shortStandaloneWeekdaySymbols
        let first = (calendar.firstWeekday - 1) % original.count
        return Array(original[first...] + original[..<first])
    }

    public var body: some View {
        let symbols = weekdaySymbols
        HStack(spacing: 0) {
            ForEach(0..<min(7, symbols.count), id: \.self) { index in
                Text(symbols[index])
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    DefaultCalendarWeekdayHeader()
        .padding()
}

