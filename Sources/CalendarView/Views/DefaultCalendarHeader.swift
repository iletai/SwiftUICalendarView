import SwiftUI

/// Default calendar month header component with month title and previous/next navigation buttons.
public struct DefaultCalendarHeader: View {
    public let title: String
    public let onPrevious: () -> Void
    public let onNext: () -> Void

    public init(title: String, onPrevious: @escaping () -> Void, onNext: @escaping () -> Void) {
        self.title = title
        self.onPrevious = onPrevious
        self.onNext = onNext
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(.title2.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            HStack(spacing: 4) {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left")
                        .font(.body.bold())
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Previous")

                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                        .font(.body.bold())
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Next")
            }
            .foregroundColor(.primary)
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    DefaultCalendarHeader(title: "September 2026", onPrevious: {}, onNext: {})
        .padding()
}

