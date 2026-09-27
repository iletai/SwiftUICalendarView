import CalendarView
import SwiftUI

struct SingleDateDemo: View {
    @State private var selectedDate = Date()
    @State private var displayDate = Date()
    @State private var firstWeekday: Locale.Weekday = .sunday
    @State private var hapticsEnabled = true

    var body: some View {
        VStack(spacing: 0) {
            // Selected Date Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Selected Date")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.8))
                        .textCase(.uppercase)
                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
            )

            ScrollView {
                VStack(spacing: 0) {
                    // Calendar — Full Width
                    CalendarView(selection: $selectedDate, displayDate: $displayDate)
                        .calendarFirstWeekday(firstWeekday)
                        .calendarHapticsEnabled(hapticsEnabled)
                        .padding(.vertical, 8)

                    Divider().padding(.horizontal, 20)

                    // Quick Actions
                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                let today = Date()
                                displayDate = today
                                selectedDate = today
                            }
                        } label: {
                            Label("Today", systemImage: "calendar.badge.clock")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                if let next = Calendar.current.date(byAdding: .month, value: 1, to: displayDate) {
                                    displayDate = next
                                }
                            }
                        } label: {
                            Label("Next Month", systemImage: "chevron.right")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                    Divider().padding(.horizontal, 20)

                    // Settings
                    VStack(spacing: 14) {
                        HStack {
                            Text("First Weekday").font(.subheadline.bold())
                            Spacer()
                            Picker("First Weekday", selection: $firstWeekday) {
                                Text("Sun").tag(Locale.Weekday.sunday)
                                Text("Mon").tag(Locale.Weekday.monday)
                                Text("Sat").tag(Locale.Weekday.saturday)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 180)
                        }

                        Divider()

                        Toggle("Selection Haptics", isOn: $hapticsEnabled)
                            .font(.subheadline.bold())
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Single Picker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .tint(.blue)
    }
}

#Preview {
    NavigationStack {
        SingleDateDemo()
    }
}
