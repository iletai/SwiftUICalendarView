//
//  ContentView.swift
//  CalendarExampleView
//
//  Created by iletai on 24/11/2023.
//

import SwiftUI
import CalendarView

struct ContentView: View {
    let dateInterval = DateInterval(
        start: Date(timeIntervalSince1970: 1_617_316_527),
        end: Date(timeIntervalSince1970: 1_627_794_000)
    )
    @State var isShowHeader = false
    var body: some View {
        Button {
            isShowHeader.toggle()
        } label: {
            Text("IsShowHeader")
        }

        ScrollView {
            CalendarView(interval: dateInterval, onHeaderAppear: { date in
            }, dateView: { date in
                Text(DateFormatter.day.string(from: date))
            }, headerView: { date in
                Text(DateFormatter.weekDay.string(from: date)).fontWeight(.bold)
            }, titleView: { date in
            }, dateOutView: { date in
                Text(DateFormatter.day.string(from: date)).foregroundColor(.gray)
            })
            .setIsShowHeader(isShowHeader)
            .firstWeekDay(1)
            .calendarLayout(.vertical)
            .equatable()
            .padding()
            .infinityFrame()
        }
    }
}

#Preview {
    ContentView()
}
