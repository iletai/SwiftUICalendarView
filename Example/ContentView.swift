import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SingleDateDemo()
                .tabItem { Label("Single", systemImage: "calendar") }
                .tint(.blue)

            BookingRangeDemo()
                .tabItem { Label("Booking", systemImage: "arrow.left.and.right.square") }
                .tint(.indigo)

            EventCalendarDemo()
                .tabItem { Label("Events", systemImage: "circle.grid.2x2") }
                .tint(.orange)

            YearCalendarDemo()
                .tabItem { Label("Year", systemImage: "calendar.badge.plus") }
                .tint(.teal)

            WeekCalendarDemo()
                .tabItem { Label("Week", systemImage: "calendar.day.timeline.left") }
                .tint(.mint)

            MultiDateDemo()
                .tabItem { Label("Multi", systemImage: "checklist") }
                .tint(.pink)

            CustomSlotLocaleDemo()
                .tabItem { Label("Custom", systemImage: "slider.horizontal.3") }
                .tint(.purple)
        }
    }
}

#Preview {
    ContentView()
}
