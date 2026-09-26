import CalendarView
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                // Hero Header Banner
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.blue.gradient)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("SwiftUICalendarView")
                                    .font(.title3.bold())
                                Text("Zero-Dependency · 120Hz")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Text("Declarative, high-performance SwiftUI calendar component with multi-mode rendering, non-Gregorian engines, and continuous booking highlights.")
                            .font(.footnote)
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            BadgeLabel(title: "v3.1.0", color: .blue)
                            BadgeLabel(title: "Pure SwiftUI", color: .green)
                            BadgeLabel(title: "iOS 17+", color: .purple)
                        }
                    }
                    .padding(.vertical, 6)
                }

                // Section 1: Core Selection
                Section("Core Selection") {
                    NavigationLink {
                        SingleDateDemo()
                    } label: {
                        ShowcaseRow(
                            icon: "calendar",
                            iconColor: .blue,
                            title: "Single Date Picker",
                            subtitle: "1-line date binding, Today jump, first weekday configuration"
                        )
                    }

                    NavigationLink {
                        BookingRangeDemo()
                    } label: {
                        ShowcaseRow(
                            icon: "arrow.left.and.right.square",
                            iconColor: .indigo,
                            title: "Booking Date Range",
                            subtitle: "Airbnb-style continuous curved ribbons, nights counter, disable past dates"
                        )
                    }

                    NavigationLink {
                        MultiDateDemo()
                    } label: {
                        ShowcaseRow(
                            icon: "checklist",
                            iconColor: .pink,
                            title: "Multi-Date Selection",
                            subtitle: "Select multiple discrete dates with interactive summary chips"
                        )
                    }
                }

                // Section 2: View Modes & Layouts
                Section("View Modes & Layouts") {
                    NavigationLink {
                        YearCalendarDemo()
                    } label: {
                        ShowcaseRow(
                            icon: "calendar.badge.plus",
                            iconColor: .teal,
                            title: "Year Overview Grid",
                            subtitle: "12-month scrollable overview with full & compact display modes"
                        )
                    }

                    NavigationLink {
                        WeekCalendarDemo()
                    } label: {
                        ShowcaseRow(
                            icon: "calendar.day.timeline.left",
                            iconColor: .mint,
                            title: "7-Day Week Strip",
                            subtitle: "Single-row compact week view with seamless week navigation"
                        )
                    }

                    NavigationLink {
                        EventCalendarDemo()
                    } label: {
                        ShowcaseRow(
                            icon: "circle.grid.2x2",
                            iconColor: .orange,
                            title: "Event Calendar & Agenda",
                            subtitle: "Multi-color dot indicators with matching interactive agenda list"
                        )
                    }
                }

                // Section 3: Customization & Localization
                Section("Customization & Localization") {
                    NavigationLink {
                        CustomSlotLocaleDemo()
                    } label: {
                        ShowcaseRow(
                            icon: "slider.horizontal.3",
                            iconColor: .purple,
                            title: "Custom Slots & Locales",
                            subtitle: "Custom day cell builders with Buddhist, Japanese & Islamic calendars"
                        )
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Calendar Gallery")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Reusable Row Components
struct ShowcaseRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 38, height: 38)
                .background(iconColor.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.bold())
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct BadgeLabel: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.caption2.bold())
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

#Preview {
    ContentView()
}
