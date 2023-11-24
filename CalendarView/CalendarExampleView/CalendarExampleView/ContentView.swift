//
//  ContentView.swift
//  CalendarExampleView
//
//  Created by tailqt on 24/11/2023.
//

import SwiftUI
import CalendarView

struct ContentView: View {
    let dateInterval = DateInterval(
        start: Date(timeIntervalSince1970: 1_617_316_527),
        end: Date(timeIntervalSince1970: 1_627_794_000)
    )
    var body: some View {
        CalendarView(
            interval: dateInterval,
            onHeaderAppear: { _ in
            },
            dateViewBuilder: { date in
                Text(date.parseString())
            }
        )
        .setIsShowHeader(true)
        .firstWeekDay(1)
        .calendarLayout(.vertical)
        .padding()
        .infinityFrame()
        .fixedSize()
    }
}

#Preview {
    ContentView()
}
