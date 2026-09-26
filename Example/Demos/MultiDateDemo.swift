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
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 16) {
                headerPill
                calendarCard
                if !selectedDates.isEmpty {
                    selectedScheduleCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Multi-Date Selection")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.pink)
    }

    private var headerPill: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.pink)
            Text("\(selectedDates.count) dates selected")
                .font(.subheadline.bold())
                .foregroundColor(.pink)
            Spacer()
            if !selectedDates.isEmpty {
                Button("Clear All") {
                    selectedDates.removeAll()
                }
                .font(.caption.bold())
                .foregroundColor(.red)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }

    private var calendarCard: some View {
        CalendarView(selection: $selectedDates, displayDate: $displayDate)
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
    }

    private var selectedScheduleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Selected Schedule")
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
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - DateChipView
private struct DateChipView: View {
    let date: Date
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption.bold())
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.pink.opacity(0.12))
        .foregroundColor(.pink)
        .clipShape(Capsule())
    }
}

// MARK: - FlowLayout helper for chips
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
