import CalendarView
import SwiftUI

struct SingleDateDemo: View {
    @State private var selectedDate = Date()
    @State private var displayDate = Date()
    @State private var firstWeekday: Locale.Weekday = .sunday
    @State private var hapticsEnabled = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Selected date card
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Selected Date")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        Text(selectedDate.formatted(date: .complete, time: .omitted))
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Calendar
                    CalendarView(selection: $selectedDate, displayDate: $displayDate)
                        .calendarFirstWeekday(firstWeekday)
                        .calendarHapticsEnabled(hapticsEnabled)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .blue.opacity(0.08), radius: 12, x: 0, y: 4)

                    // Controls
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    let today = Date()
                                    displayDate = today
                                    selectedDate = today
                                }
                            } label: {
                                Label("Today", systemImage: "calendar.badge.clock")
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.borderedProminent)

                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    if let next = Calendar.current.date(byAdding: .month, value: 1, to: displayDate) {
                                        displayDate = next
                                    }
                                }
                            } label: {
                                Label("Next Month", systemImage: "chevron.right")
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.bordered)
                        }

                        Divider()

                        HStack {
                            Text("First Weekday").font(.subheadline)
                            Spacer()
                            Picker("First Weekday", selection: $firstWeekday) {
                                Text("Sun").tag(Locale.Weekday.sunday)
                                Text("Mon").tag(Locale.Weekday.monday)
                                Text("Sat").tag(Locale.Weekday.saturday)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 180)
                        }

                        Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                            .font(.subheadline)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .navigationTitle("Single Picker")
        }
        .tint(.blue)
    }
}

#Preview {
    SingleDateDemo()
}

