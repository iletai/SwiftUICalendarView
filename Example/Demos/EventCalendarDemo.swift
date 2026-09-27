import CalendarView
import SwiftUI

struct EventCalendarDemo: View {
    @State private var displayDate = Date()
    @State private var selectedDate = Date()

    private var sampleEvents: [Date: [CalendarEvent]] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        func d(_ offset: Int) -> Date { cal.date(byAdding: .day, value: offset, to: today)! }

        return [
            d(0): [
                CalendarEvent(date: d(0), color: .blue, title: "Team Standup (09:30)"),
                CalendarEvent(date: d(0), color: .green, title: "Design Sprint Review")
            ],
            d(2): [
                CalendarEvent(date: d(2), color: .orange, title: "Product QA Testing"),
                CalendarEvent(date: d(2), color: .purple, title: "All-Hands Meeting"),
                CalendarEvent(date: d(2), color: .red, title: "v3.1 Release Cut")
            ],
            d(4): [
                CalendarEvent(date: d(4), color: .teal, title: "Architecture Tech Talk")
            ],
            d(-2): [
                CalendarEvent(date: d(-2), color: .gray, title: "Infrastructure Maintenance")
            ]
        ]
    }

    private var currentEvents: [CalendarEvent] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: selectedDate)
        return sampleEvents.first { cal.isDate($0.key, inSameDayAs: start) }?.value ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            // Gradient Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Agenda View")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.8))
                        .textCase(.uppercase)
                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                Spacer()
                Text("\(currentEvents.count) events")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.25))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
            )

            ScrollView {
                VStack(spacing: 0) {
                    // Calendar — Full Width
                    CalendarView(selection: $selectedDate, displayDate: $displayDate)
                        .calendarEvents(sampleEvents)
                        .padding(.vertical, 8)

                    Divider().padding(.horizontal, 20)

                    // Timeline Agenda List
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Day Schedule")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        if currentEvents.isEmpty {
                            HStack {
                                Spacer()
                                Text("No events scheduled for this day")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 24)
                                Spacer()
                            }
                        } else {
                            ForEach(currentEvents) { event in
                                HStack(spacing: 12) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(event.color)
                                        .frame(width: 4, height: 38)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(event.title ?? "Event")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.primary)
                                        Text("Calendar View Event")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Event Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .tint(.orange)
    }
}

#Preview {
    NavigationStack {
        EventCalendarDemo()
    }
}
