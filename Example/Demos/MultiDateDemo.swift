import CalendarView
import SwiftUI

struct MultiDateDemo: View {
    @State private var selectedDates = Set<Date>()
    @State private var displayDate = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "checklist").foregroundColor(.pink)
                        Text("\(selectedDates.count) dates selected")
                            .font(.subheadline.bold()).foregroundColor(.pink)
                        Spacer()
                        if !selectedDates.isEmpty {
                            Button("Clear") { withAnimation { selectedDates.removeAll() } }
                                .font(.caption.bold()).foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 8).padding(.horizontal, 14)
                    .background(Color.pink.opacity(0.1))
                    .clipShape(Capsule())

                    CalendarView(selection: $selectedDates, displayDate: $displayDate)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .pink.opacity(0.08), radius: 12, x: 0, y: 4)

                    if !selectedDates.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Selected Dates").font(.caption.bold()).foregroundColor(.secondary)
                            ForEach(selectedDates.sorted(), id: \.self) { date in
                                Text(date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding()
            }
            .navigationTitle("Multi-Date")
        }
        .tint(.pink)
    }
}

#Preview {
    MultiDateDemo()
}

