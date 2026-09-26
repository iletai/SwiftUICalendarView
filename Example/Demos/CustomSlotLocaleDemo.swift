import CalendarView
import SwiftUI

struct CustomSlotLocaleDemo: View {
    @State private var selectedDate = Date()
    @State private var selectedLocaleId = "vi_VN"
    @State private var selectedCalendarId = "gregorian"

    private var currentLocale: Locale { Locale(identifier: selectedLocaleId) }

    private var currentCalendar: Calendar {
        let id: Calendar.Identifier = switch selectedCalendarId {
        case "buddhist": .buddhist
        case "japanese": .japanese
        case "islamic": .islamicCivil
        default: .gregorian
        }
        var cal = Calendar(identifier: id)
        cal.locale = currentLocale
        return cal
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Custom Slot Calendar Card (Evenly distributed)
                CalendarView(selection: $selectedDate)
                    .calendarDayCell { state in
                        CustomCalendarDayCell(state: state)
                    }
                    .calendarLocale(currentLocale)
                    .environment(\.calendar, currentCalendar)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )

                // Pickers Card
                VStack(spacing: 14) {
                    HStack {
                        Text("Locale").font(.subheadline.bold())
                        Spacer()
                        Picker("Locale", selection: $selectedLocaleId) {
                            Text("Tiếng Việt").tag("vi_VN")
                            Text("English").tag("en_US")
                            Text("日本語").tag("ja_JP")
                            Text("Français").tag("fr_FR")
                        }
                        .pickerStyle(.menu)
                    }

                    Divider()

                    HStack {
                        Text("Calendar System").font(.subheadline.bold())
                        Spacer()
                        Picker("Calendar", selection: $selectedCalendarId) {
                            Text("Gregorian").tag("gregorian")
                            Text("Buddhist (BE)").tag("buddhist")
                            Text("Japanese (Reiwa)").tag("japanese")
                            Text("Islamic (Hijri)").tag("islamic")
                        }
                        .pickerStyle(.menu)
                    }
                }
                .padding(16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Custom & Locales")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.purple)
    }
}

// MARK: - Custom Day Cell View
private struct CustomCalendarDayCell: View {
    let state: CalendarDayState

    var body: some View {
        VStack(spacing: 2) {
            Text("\(state.dayNumber)")
                .font(.system(size: 15, weight: state.isSelected ? .bold : .regular))
                .foregroundColor(cellColor)

            if state.isToday {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .contentShape(Rectangle())
        .background(backgroundShape)
        .overlay(borderOverlay)
        .opacity(state.isCurrentMonth ? 1.0 : 0.3)
    }

    private var cellColor: Color {
        if state.isSelected { return .white }
        if state.isDisabled { return .secondary.opacity(0.4) }
        return state.isCurrentMonth ? .primary : .secondary
    }

    @ViewBuilder
    private var backgroundShape: some View {
        if state.isSelected {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.purple.gradient)
                .frame(width: 38, height: 38)
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if state.isToday && !state.isSelected {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.orange, lineWidth: 1.5)
                .frame(width: 38, height: 38)
        }
    }
}

#Preview {
    NavigationStack {
        CustomSlotLocaleDemo()
    }
}
