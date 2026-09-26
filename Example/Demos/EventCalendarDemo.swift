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
        ScrollView {
            VStack(spacing: 16) {
                // Calendar Container Card (Evenly distributed)
                CalendarView(selection: $selectedDate, displayDate: $displayDate)
                    .calendarEvents(sampleEvents)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )

                // Timeline Agenda Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Agenda · \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.headline)
                        Spacer()
                        Text("\(currentEvents.count) items")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }

                    if currentEvents.isEmpty {
                        VStack(spacing: 6) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            Text("No events scheduled for this day")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        ForEach(currentEvents) { event in
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(event.color)
                                    .frame(width: 4, height: 36)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title ?? "Event")
                                        .font(.subheadline.bold())
                                    Text("Calendar View Event")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(14)
                            .background(Color(uiColor: .tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
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
        .navigationTitle("Event Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.orange)
    }
}

#Preview {
    NavigationStack {
        EventCalendarDemo()
    }
}
