import CalendarView
import SwiftUI

struct YearCalendarDemo: View {
    @State private var selectedDate = Date()
    @State private var displayDate = Date()
    @State private var yearMode: YearDisplayMode = .full

    var body: some View {
        VStack(spacing: 0) {
            // Mode Selector Bar
            Picker("Display Mode", selection: $yearMode) {
                Text("Full Overview").tag(YearDisplayMode.full)
                Text("Compact Grid").tag(YearDisplayMode.compact)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(uiColor: .secondarySystemBackground))

            // 12-Month Year Calendar — Full Bleed
            CalendarView(selection: $selectedDate, displayDate: $displayDate)
                .calendarViewMode(.year(yearMode))
        }
        .background(Color(uiColor: .systemBackground))
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
