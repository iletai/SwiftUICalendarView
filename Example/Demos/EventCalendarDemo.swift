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
                CalendarEvent(date: d(0), color: .blue, title: "Team Standup 09:30"),
                CalendarEvent(date: d(0), color: .green, title: "Design Sprint Review")
            ],
            d(2): [
                CalendarEvent(date: d(2), color: .orange, title: "Product Launch QA"),
                CalendarEvent(date: d(2), color: .purple, title: "All-Hands Meeting"),
                CalendarEvent(date: d(2), color: .red, title: "Deadline: v3.1 Release")
            ],
            d(5): [CalendarEvent(date: d(5), color: .green, title: "Quarterly Planning")],
            d(-3): [CalendarEvent(date: d(-3), color: .gray, title: "Architecture Refactoring")]
        ]
    }

    private var currentEvents: [CalendarEvent] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: selectedDate)
        return sampleEvents.first { cal.isDate($0.key, inSameDayAs: start) }?.value ?? []
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    CalendarView(selection: $selectedDate, displayDate: $displayDate)
                        .calendarEvents(sampleEvents)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .orange.opacity(0.08), radius: 12, x: 0, y: 4)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Agenda for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.headline)
                            Spacer()
                            Text("\(currentEvents.count) items").font(.caption).foregroundColor(.secondary)
                        }

                        if currentEvents.isEmpty {
                            Text("No events scheduled")
                                .font(.subheadline).foregroundColor(.secondary)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                        } else {
                            ForEach(currentEvents) { event in
                                HStack(spacing: 12) {
                                    Circle().fill(event.color).frame(width: 10, height: 10)
                                    Text(event.title ?? "Event").font(.subheadline.bold())
                                    Spacer()
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .navigationTitle("Event Calendar")
        }
        .tint(.orange)
    }
}
