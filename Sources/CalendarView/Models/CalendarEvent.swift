import SwiftUI

public struct CalendarEvent: Identifiable, Hashable, Sendable {
    public let id: String
    public let date: Date
    public let color: Color
    public let title: String?

    public init(id: String = UUID().uuidString, date: Date, color: Color = .blue, title: String? = nil) {
        self.id = id
        self.date = date
        self.color = color
        self.title = title
    }
}
