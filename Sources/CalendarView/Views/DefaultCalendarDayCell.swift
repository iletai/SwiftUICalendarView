import SwiftUI

/// Default day cell component displaying day numbers, selection highlights, today badges, and event indicators.
public struct DefaultCalendarDayCell: View {
    public let state: CalendarDayState
    public var accentColor: Color

    public init(state: CalendarDayState, accentColor: Color = .blue) {
        self.state = state
        self.accentColor = accentColor
    }

    public var body: some View {
        ZStack {
            if state.rangePosition != .none {
                RangeSelectionShape(position: state.rangePosition, cornerRadius: 8)
                    .fill(accentColor.opacity(state.isSelected ? 1.0 : 0.2))
            } else if state.isSelected {
                Circle()
                    .fill(accentColor)
            } else if state.isToday {
                Circle()
                    .stroke(accentColor, lineWidth: 1.5)
            }

            VStack(spacing: 2) {
                Text("\(state.dayNumber)")
                    .font(.system(size: 16, weight: state.isSelected || state.isToday ? .semibold : .regular))
                    .foregroundColor(textColor)

                if !state.events.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(state.events.prefix(3), id: \.id) { event in
                            Circle()
                                .fill(event.color)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
        }
        .frame(height: 38)
        .opacity(state.isCurrentMonth ? 1.0 : 0.3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(state.isSelected ? [.isSelected, .isButton] : [.isButton])
    }

    public var textColor: Color {
        if state.isSelected {
            return .white
        }
        if state.isDisabled {
            return .secondary.opacity(0.5)
        }
        return state.isCurrentMonth ? .primary : .secondary
    }

    public var accessibilityText: String {
        let dateStr = state.date.formatted(.dateTime.year().month().day())
        let eventStr = state.events.isEmpty ? "" : ", \(state.events.count) events"
        return "\(dateStr)\(eventStr)"
    }
}
