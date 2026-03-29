//
//  CalendarDay.swift
//
//
//  Created by Copilot.
//

import Foundation

/// An identifiable wrapper around Date for stable ForEach identification.
public struct CalendarDay: Identifiable, Hashable {
    public let id: String
    public let date: Date

    init(date: Date, monthContext: Date? = nil) {
        self.date = date
        // Create stable ID from date components + month context
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let contextKey = monthContext.map {
            let ctx = calendar.dateComponents([.year, .month], from: $0)
            return "\(ctx.year ?? 0)-\(ctx.month ?? 0)"
        } ?? "none"
        self.id = "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)-\(contextKey)"
    }
}
