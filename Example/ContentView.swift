import CalendarView
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(alignment: .leading, spacing: 24) {
                    // Hero Banner Card — Full Width Edge-to-Edge
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 14) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 3) {
                                Text("SwiftUICalendarView")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Text("Zero-Dependency · 120Hz Fluidity")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white.opacity(0.88))
                            }
                        }

                        Text("Declarative, high-performance SwiftUI calendar component with multi-mode rendering, non-Gregorian engines, and continuous booking highlights.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.92))
                            .lineSpacing(3)

                        HStack(spacing: 8) {
                            HeroPill(title: "v3.1.0")
                            HeroPill(title: "Pure SwiftUI")
                            HeroPill(title: "iOS 17+")
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .blue.opacity(0.3), radius: 16, x: 0, y: 8)

                    // Section 1: Core Selection
                    GallerySection(title: "Core Selection") {
                        NavigationLink { SingleDateDemo() } label: {
                            GalleryCard(
                                icon: "calendar",
                                gradient: [.blue, .cyan],
                                title: "Single Date Picker",
                                subtitle: "1-line date binding, Today jump, first weekday selector",
                                badge: "Basic"
                            )
                        }

                        NavigationLink { BookingRangeDemo() } label: {
                            GalleryCard(
                                icon: "arrow.left.and.right.square.fill",
                                gradient: [.indigo, .purple],
                                title: "Booking Date Range",
                                subtitle: "Airbnb-style continuous curved ribbons, nights counter, disable past dates",
                                badge: "Popular"
                            )
                        }

                        NavigationLink { MultiDateDemo() } label: {
                            GalleryCard(
                                icon: "checklist",
                                gradient: [.pink, .orange],
                                title: "Multi-Date Selection",
                                subtitle: "Select multiple discrete dates with interactive schedule chips",
                                badge: "Multi"
                            )
                        }
                    }

                    // Section 2: View Modes & Layouts
                    GallerySection(title: "View Modes & Layouts") {
                        NavigationLink { YearCalendarDemo() } label: {
                            GalleryCard(
                                icon: "calendar.badge.plus",
                                gradient: [.teal, .green],
                                title: "Year Overview Grid",
                                subtitle: "12-month scrollable overview with full & compact display modes",
                                badge: "12 Months"
                            )
                        }

                        NavigationLink { WeekCalendarDemo() } label: {
                            GalleryCard(
                                icon: "calendar.day.timeline.left",
                                gradient: [.mint, .teal],
                                title: "7-Day Week Strip",
                                subtitle: "Single-row compact week view with seamless week navigation",
                                badge: "Compact"
                            )
                        }

                        NavigationLink { EventCalendarDemo() } label: {
                            GalleryCard(
                                icon: "circle.grid.2x2.fill",
                                gradient: [.orange, .red],
                                title: "Event Calendar & Agenda",
                                subtitle: "Multi-color dot indicators with matching interactive agenda list",
                                badge: "Events"
                            )
                        }
                    }

                    // Section 3: Customization & Localization
                    GallerySection(title: "Customization & Localization") {
                        NavigationLink { CustomSlotLocaleDemo() } label: {
                            GalleryCard(
                                icon: "slider.horizontal.3",
                                gradient: [.purple, .indigo],
                                title: "Custom Slots & Locales",
                                subtitle: "Custom day cell builders with Buddhist, Japanese & Islamic calendars",
                                badge: "Advanced"
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Calendar Gallery")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Gallery Components
private struct HeroPill: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(.white.opacity(0.22))
            .clipShape(Capsule())
    }
}

private struct GallerySection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
                .foregroundColor(.primary)
                .padding(.leading, 4)

            VStack(spacing: 12) {
                content()
            }
        }
    }
}

private struct GalleryCard: View {
    let icon: String
    let gradient: [Color]
    let title: String
    let subtitle: String
    let badge: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.body.bold())
                        .foregroundColor(.primary)
                    Spacer()
                    Text(badge)
                        .font(.caption2.bold())
                        .foregroundColor(gradient.first ?? .blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background((gradient.first ?? .blue).opacity(0.12))
                        .clipShape(Capsule())
                }

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    ContentView()
}
