import CalendarView
import SwiftUI

struct MultiDateDemo: View {
    @State private var selectedDates: Set<Date> = {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return [
            today,
            cal.date(byAdding: .day, value: 2, to: today)!,
            cal.date(byAdding: .day, value: 5, to: today)!
        ]
    }()
    @State private var displayDate = Date()

    var body: some View {
        VStack(spacing: 0) {
            // Gradient Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Selected Dates")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.8))
                        .textCase(.uppercase)
                    Text("\(selectedDates.count) days chosen")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }
                Spacer()
                if !selectedDates.isEmpty {
                    Button("Clear All") {
                        selectedDates.removeAll()
                    }
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.25))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            )

            ScrollView {
                VStack(spacing: 0) {
                    // Calendar — Full Width
                    CalendarView(selection: $selectedDates, displayDate: $displayDate)
                        .padding(.vertical, 8)

                    if !selectedDates.isEmpty {
                        Divider().padding(.horizontal, 20)

                        // Selected Chips Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Schedule")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)

                            FlowLayout(spacing: 8) {
                                ForEach(Array(selectedDates.sorted()), id: \.self) { date in
                                    DateChipView(date: date) {
                                        _ = selectedDates.remove(date)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Multi-Date Selection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .tint(.pink)
    }
}

// MARK: - DateChipView
private struct DateChipView: View {
    let date: Date
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline.bold())
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.pink.opacity(0.12))
        .foregroundColor(.pink)
        .clipShape(Capsule())
    }
}

// MARK: - FlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width {
                currentX = 0
                height += rowHeight + spacing
                rowHeight = 0
            }
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    NavigationStack {
        MultiDateDemo()
    }
}
