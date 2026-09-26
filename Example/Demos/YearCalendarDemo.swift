import CalendarView
import SwiftUI

struct YearCalendarDemo: View {
    @State private var selectedDate = Date()
    @State private var displayDate = Date()
    @State private var yearMode: YearDisplayMode = .full

    var body: some View {
        VStack(spacing: 12) {
            Picker("Display Mode", selection: $yearMode) {
                Text("Full Mode").tag(YearDisplayMode.full)
                Text("Compact Mode").tag(YearDisplayMode.compact)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 8)

            CalendarView(selection: $selectedDate, displayDate: $displayDate)
                .calendarViewMode(.year(yearMode))
                .padding(.bottom, 16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Year Overview")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.teal)
    }
}

#Preview {
    NavigationStack {
        YearCalendarDemo()
    }
}
