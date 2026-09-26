import CalendarView
import SwiftUI

struct BookingRangeDemo: View {
    @State private var dateRange: ClosedRange<Date>? = {
        let cal = Calendar.current
        let today = Date()
        guard let start = cal.date(byAdding: .day, value: 3, to: today),
              let end = cal.date(byAdding: .day, value: 7, to: today) else { return nil }
        return start...end
    }()
    @State private var disablePastDates = true

    private var numberOfNights: Int {
        guard let range = dateRange else { return 0 }
        return Calendar.current.dateComponents([.day], from: range.lowerBound, to: range.upperBound).day ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Booking summary
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Check-In", systemImage: "arrow.down.circle.fill")
                                .font(.caption.bold()).foregroundColor(.indigo)
                            Text(dateRange?.lowerBound.formatted(date: .abbreviated, time: .omitted) ?? "Select")
                                .font(.callout.bold())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "arrow.right").foregroundColor(.secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Label("Check-Out", systemImage: "arrow.up.circle.fill")
                                .font(.caption.bold()).foregroundColor(.indigo)
                            Text(dateRange?.upperBound.formatted(date: .abbreviated, time: .omitted) ?? "Select")
                                .font(.callout.bold())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    if numberOfNights > 0 {
                        HStack {
                            Image(systemName: "moon.stars.fill").foregroundColor(.indigo)
                            Text("\(numberOfNights) \(numberOfNights == 1 ? "night" : "nights") selected")
                                .font(.subheadline.bold()).foregroundColor(.indigo)
                        }
                        .padding(.vertical, 6).padding(.horizontal, 14)
                        .background(Color.indigo.opacity(0.12))
                        .clipShape(Capsule())
                        .transition(.scale.combined(with: .opacity))
                    }

                    CalendarView(selection: $dateRange)
                        .calendarDisabledDates { date in
                            disablePastDates && date < Calendar.current.startOfDay(for: Date())
                        }
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .indigo.opacity(0.08), radius: 12, x: 0, y: 4)

                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Button("3 Days") { setPreset(3) }.buttonStyle(.bordered).font(.caption.bold())
                            Button("7 Days") { setPreset(7) }.buttonStyle(.bordered).font(.caption.bold())
                            Button("Clear") { withAnimation { dateRange = nil } }
                                .buttonStyle(.bordered).foregroundColor(.red).font(.caption.bold())
                        }
                        Toggle("Disable Past Dates", isOn: $disablePastDates).font(.subheadline)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .navigationTitle("Booking Range")
        }
        .tint(.indigo)
    }

    private func setPreset(_ days: Int) {
        let start = Calendar.current.startOfDay(for: Date())
        if let end = Calendar.current.date(byAdding: .day, value: days, to: start) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { dateRange = start...end }
        }
    }
}

#Preview {
    BookingRangeDemo()
}

