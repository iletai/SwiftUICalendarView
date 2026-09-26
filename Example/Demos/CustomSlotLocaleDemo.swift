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
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    CalendarView(selection: $selectedDate)
                        .calendarDayCell { state in
                            VStack(spacing: 2) {
                                Text("\(state.dayNumber)")
                                    .font(.system(size: 15, weight: state.isSelected ? .bold : .regular))
                                    .foregroundColor(cellColor(state))

                                if state.isToday {
                                    Circle().fill(Color.orange).frame(width: 4, height: 4)
                                }
                            }
                            .frame(height: 38)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(state.isSelected ? Color.purple : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(state.isToday && !state.isSelected ? Color.orange : Color.clear, lineWidth: 1.5)
                            )
                            .opacity(state.isCurrentMonth ? 1.0 : 0.3)
                        }
                        .calendarLocale(currentLocale)
                        .environment(\.calendar, currentCalendar)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .purple.opacity(0.08), radius: 12, x: 0, y: 4)

                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Locale").font(.caption.bold()).foregroundColor(.secondary)
                            Picker("Locale", selection: $selectedLocaleId) {
                                Text("Tiếng Việt").tag("vi_VN")
                                Text("English").tag("en_US")
                                Text("日本語").tag("ja_JP")
                                Text("Français").tag("fr_FR")
                            }
                            .pickerStyle(.menu)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Calendar System").font(.caption.bold()).foregroundColor(.secondary)
                            Picker("Calendar", selection: $selectedCalendarId) {
                                Text("Gregorian").tag("gregorian")
                                Text("Buddhist (BE)").tag("buddhist")
                                Text("Japanese (Reiwa)").tag("japanese")
                                Text("Islamic (Hijri)").tag("islamic")
                            }
                            .pickerStyle(.menu)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .navigationTitle("Slot & Locale")
        }
        .tint(.purple)
    }

    private func cellColor(_ state: CalendarDayState) -> Color {
        if state.isSelected { return .white }
        if state.isDisabled { return .secondary.opacity(0.4) }
        return state.isCurrentMonth ? .primary : .secondary
    }
}
