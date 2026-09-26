import CalendarView
import SwiftUI

struct SingleDateDemo: View {
    @State private var selectedDate = Date()
    @State private var displayDate = Date()
    @State private var firstWeekday: Locale.Weekday = .sunday
    @State private var hapticsEnabled = true

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header Card
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected Date")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                        .textCase(.uppercase)
                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                        .font(.title3.bold())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Calendar Container Card (Evenly distributed)
                CalendarView(selection: $selectedDate, displayDate: $displayDate)
                    .calendarFirstWeekday(firstWeekday)
                    .calendarHapticsEnabled(hapticsEnabled)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )

                // Quick Navigation Actions
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
                            .padding(.vertical, 12)
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
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                }

                // Configuration Settings Card
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
        .navigationTitle("Single Picker")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.blue)
    }
}

#Preview {
    NavigationStack {
        SingleDateDemo()
    }
}
