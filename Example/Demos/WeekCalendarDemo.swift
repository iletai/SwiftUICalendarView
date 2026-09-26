import CalendarView
import SwiftUI

struct WeekCalendarDemo: View {
    @State private var selectedDate = Date()
    @State private var displayDate = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Selected")
                        .font(.caption.bold()).foregroundColor(.secondary).textCase(.uppercase)
                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                CalendarView(selection: $selectedDate, displayDate: $displayDate)
                    .calendarViewMode(.week)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .mint.opacity(0.08), radius: 12, x: 0, y: 4)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        let today = Date()
                        displayDate = today
                        selectedDate = today
                    }
                } label: {
                    Label("This Week", systemImage: "calendar.badge.clock")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .navigationTitle("Week View")
        }
        .tint(.mint)
    }
}

#Preview {
    WeekCalendarDemo()
}

