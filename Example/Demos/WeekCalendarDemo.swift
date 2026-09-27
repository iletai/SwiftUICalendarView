import CalendarView
import SwiftUI

struct WeekCalendarDemo: View {
    @State private var selectedDate = Date()
    @State private var displayDate = Date()

    var body: some View {
        VStack(spacing: 0) {
            // Selected Date Gradient Header
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
                LinearGradient(colors: [.mint, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
            )

            ScrollView {
                VStack(spacing: 0) {
                    // Week Strip — Full Width
                    CalendarView(selection: $selectedDate, displayDate: $displayDate)
                        .calendarViewMode(.week)
                        .padding(.vertical, 12)

                    Divider().padding(.horizontal, 20)

                    // Quick Jump
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
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
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Week View")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .tint(.mint)
    }
}

#Preview {
    NavigationStack {
        WeekCalendarDemo()
    }
}
