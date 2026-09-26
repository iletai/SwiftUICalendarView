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
            // Background Highlight Shape
            if state.rangePosition != .none {
                RangeSelectionShape(position: state.rangePosition, cornerRadius: 8)
                    .fill(
                        state.rangePosition == .rangeStart || state.rangePosition == .rangeEnd || state.rangePosition == .singleDay
                        ? AnyShapeStyle(LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        : AnyShapeStyle(accentColor.opacity(0.15))
                    )
            } else if state.isSelected {
                Circle()
                    .fill(LinearGradient(
                        colors: [accentColor, accentColor.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 38, height: 38)
            } else if state.isToday {
                Circle()
                    .stroke(accentColor, lineWidth: 1.5)
                    .frame(width: 38, height: 38)
            }

            // Cell Content
            VStack(spacing: 2) {
                Text("\(state.dayNumber)")
                    .font(.system(size: 17, weight: state.isSelected || state.isToday ? .semibold : .regular))
                    .foregroundColor(textColor)

                if !state.events.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(state.events.prefix(3), id: \.id) { event in
                            Circle()
                                .fill(event.color)
                                .frame(width: 4, height: 4)
                        }
                    }
                } else {
                    Spacer().frame(height: 4)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .contentShape(Rectangle())
        .opacity(state.isCurrentMonth ? 1.0 : 0.28)
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

#Preview {
    HStack(spacing: 0) {
        DefaultCalendarDayCell(state: CalendarDayState(
            dateKey: 20260924, date: Date(), dayNumber: 24,
            isCurrentMonth: true, isToday: true, isSelected: false
        ))
        DefaultCalendarDayCell(state: CalendarDayState(
            dateKey: 20260924, date: Date(), dayNumber: 24,
            isCurrentMonth: true, isToday: false, isSelected: true
        ))
        DefaultCalendarDayCell(state: CalendarDayState(
            dateKey: 20260924, date: Date(), dayNumber: 24,
            isCurrentMonth: true, isToday: false, isSelected: false,
            events: [CalendarEvent(date: Date(), color: .orange)]
        ))
    }
    .padding()
}
