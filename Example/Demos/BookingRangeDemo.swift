import CalendarView
import SwiftUI

struct BookingRangeDemo: View {
    @State private var dateRange: ClosedRange<Date>? = {
        let cal = Calendar.current
        let today = Date()
        guard let start = cal.date(byAdding: .day, value: 2, to: today),
              let end = cal.date(byAdding: .day, value: 6, to: today) else { return nil }
        return start...end
    }()
    @State private var disablePastDates = true

    private var numberOfNights: Int {
        guard let range = dateRange else { return 0 }
        return Calendar.current.dateComponents([.day], from: range.lowerBound, to: range.upperBound).day ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Gradient Booking Header
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Label("Check-In", systemImage: "arrow.down.circle.fill")
                        .font(.caption2.bold())
                        .foregroundColor(.white.opacity(0.8))
                    Text(dateRange?.lowerBound.formatted(date: .abbreviated, time: .omitted) ?? "Select")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "arrow.right")
                    .font(.body.bold())
                    .foregroundColor(.white.opacity(0.6))

                VStack(alignment: .leading, spacing: 2) {
                    Label("Check-Out", systemImage: "arrow.up.circle.fill")
                        .font(.caption2.bold())
                        .foregroundColor(.white.opacity(0.8))
                    Text(dateRange?.upperBound.formatted(date: .abbreviated, time: .omitted) ?? "Select")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
            )

            // Nights Sub-banner
            if numberOfNights > 0 {
                HStack {
                    Image(systemName: "moon.stars.fill")
                    Text("\(numberOfNights) \(numberOfNights == 1 ? "night" : "nights") selected")
                        .font(.subheadline.bold())
                }
                .foregroundColor(.indigo)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.indigo.opacity(0.08))
            }

            ScrollView {
                VStack(spacing: 0) {
                    // Calendar — Full Width
                    CalendarView(selection: $dateRange)
                        .calendarDisabledDates { date in
                            disablePastDates && date < Calendar.current.startOfDay(for: Date())
                        }
                        .padding(.vertical, 8)

                    Divider().padding(.horizontal, 20)

                    // Presets
                    HStack(spacing: 10) {
                        Button("Weekend (2N)") { setPreset(days: 2) }
                            .buttonStyle(.bordered)
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)

                        Button("1 Week (7N)") { setPreset(days: 7) }
                            .buttonStyle(.bordered)
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)

                        Button("Clear") { withAnimation { dateRange = nil } }
                            .buttonStyle(.bordered)
                            .font(.subheadline.bold())
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                    Divider().padding(.horizontal, 20)

                    Toggle("Disable Past Dates", isOn: $disablePastDates)
                        .font(.subheadline.bold())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Booking Range")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .tint(.indigo)
    }

    private func setPreset(days: Int) {
        let start = Calendar.current.startOfDay(for: Date())
        if let end = Calendar.current.date(byAdding: .day, value: days, to: start) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                dateRange = start...end
            }
        }
    }
}

#Preview {
    NavigationStack {
        BookingRangeDemo()
    }
}
