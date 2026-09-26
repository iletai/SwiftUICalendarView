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
        ScrollView {
            VStack(spacing: 16) {
                // Header Count Pill
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.pink)
                    Text("\(selectedDates.count) dates selected")
                        .font(.subheadline.bold())
                        .foregroundColor(.pink)
                    Spacer()
                    if !selectedDates.isEmpty {
                        Button("Clear All") {
                            withAnimation { selectedDates.removeAll() }
                        }
                        .font(.caption.bold())
                        .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Calendar Card
                VStack(spacing: 12) {
                    CalendarView(selection: $selectedDates, displayDate: $displayDate)
                        .padding(.vertical, 6)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )

                // Selected Dates Chips
                if !selectedDates.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Selected Schedule")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        FlowLayout(spacing: 8) {
                            ForEach(selectedDates.sorted(), id: \.self) { date in
                                HStack(spacing: 6) {
                                    Text(date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption.bold())
                                    Button {
                                        withAnimation { selectedDates.remove(date) }
                                    } label: {
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
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Multi-Date Selection")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.pink)
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
