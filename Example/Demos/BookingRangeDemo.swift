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
        ScrollView {
            VStack(spacing: 16) {
                // Booking Summary Card
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Check-In", systemImage: "arrow.down.circle.fill")
                            .font(.caption.bold())
                            .foregroundColor(.indigo)
                        Text(dateRange?.lowerBound.formatted(date: .abbreviated, time: .omitted) ?? "Select date")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "arrow.right")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        Label("Check-Out", systemImage: "arrow.up.circle.fill")
                            .font(.caption.bold())
                            .foregroundColor(.indigo)
                        Text(dateRange?.upperBound.formatted(date: .abbreviated, time: .omitted) ?? "Select date")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Stay Duration Pill
                if numberOfNights > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "moon.stars.fill")
                        Text("\(numberOfNights) \(numberOfNights == 1 ? "night" : "nights") duration")
                            .font(.subheadline.bold())
                    }
                    .foregroundColor(.indigo)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.indigo.opacity(0.12))
                    .clipShape(Capsule())
                }

                // Calendar Container Card (Evenly distributed)
                CalendarView(selection: $dateRange)
                    .calendarDisabledDates { date in
                        disablePastDates && date < Calendar.current.startOfDay(for: Date())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )

                // Presets & Options Card
                VStack(spacing: 14) {
                    HStack(spacing: 10) {
                        Button("Weekend (2N)") { setPreset(days: 2) }
                            .buttonStyle(.bordered)
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)

                        Button("1 Week (7N)") { setPreset(days: 7) }
                            .buttonStyle(.bordered)
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)

                        Button("Clear") { withAnimation { dateRange = nil } }
                            .buttonStyle(.bordered)
                            .font(.caption.bold())
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }

                    Divider()

                    Toggle("Disable Past Dates", isOn: $disablePastDates)
                        .font(.subheadline.bold())
                }
                .padding(16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Booking Range")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.indigo)
    }

    private func setPreset(days: Int) {
        let start = Calendar.current.startOfDay(for: Date())
        if let end = Calendar.current.date(byAdding: .day, value: days, to: start) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
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
