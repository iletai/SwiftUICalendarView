import CalendarView
import SwiftUI

struct WeekCalendarDemo: View {
    @State private var selectedDate = Date()
    @State private var displayDate = Date()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Selected Date Card
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected Date")
                        .font(.caption.bold())
                        .foregroundColor(.mint)
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

                // Week Strip Card (Evenly distributed)
                CalendarView(selection: $selectedDate, displayDate: $displayDate)
                    .calendarViewMode(.week)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )

                // Action
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        let today = Date()
                        displayDate = today
                        selectedDate = today
                    }
                } label: {
                    Label("Current Week", systemImage: "calendar.badge.clock")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Week View")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.mint)
    }
}

#Preview {
    NavigationStack {
        WeekCalendarDemo()
    }
}
