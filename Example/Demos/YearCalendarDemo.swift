import CalendarView
import SwiftUI

struct YearCalendarDemo: View {
    @State private var selectedDate = Date()
    @State private var displayDate = Date()
    @State private var yearMode: YearDisplayMode = .full

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Picker("Display", selection: $yearMode) {
                    Text("Full").tag(YearDisplayMode.full)
                    Text("Compact").tag(YearDisplayMode.compact)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                CalendarView(selection: $selectedDate, displayDate: $displayDate)
                    .calendarViewMode(.year(yearMode))
                    .padding(.vertical, 8)

                Spacer(minLength: 0)
            }
            .navigationTitle("Year View")
        }
        .tint(.teal)
    }
}
