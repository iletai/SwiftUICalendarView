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
    @State var isShowDateOut = false
    @State var firstWeekDate = 2
    @State var date = Date()

    @State private var selectedDate = Date()
    var body: some View {
        HStack {
            Button {
                isShowHeader.toggle()
            } label: {
                Text("Header")
            }
            Button {
                isShowDateOut.toggle()
            } label: {
                Text("DateOut")
            }
            Button {
                firstWeekDate = Int.random(in: 1...6)
            } label: {
                Text("First Week Date")
            }
            Button {
                let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)
                selectedDate = nextMonth!
            } label: {
                Text("Next month")
            }

        }
        ScrollView {
        CalendarView(
            date: selectedDate
            , dateView: { date in
                Text(DateFormatter.day.string(from: date))
                    .font(.footnote)
            }, headerView: { date in
                Text(DateFormatter.weekDay.string(from: date))
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(
                        Calendar.current.isDateInWeekend(date) ? .red : .black
                    )
            }, titleView: { date in
            }, dateOutView: { date in
                Text(DateFormatter.day.string(from: date))
                    .font(.footnote)
                    .foregroundColor(.gray)
            })
        .setIsShowHeader(isShowHeader)
        .showDateOut(isShowDateOut)
        .firstWeekDay(firstWeekDate)
        .calendarLocate(locale: .current)
        .calendarLayout(.vertical)
        .padding()
        .infinityFrame()
        .allowsTightening(true)
        .id(UUID())
        }
    }
}

#Preview {
    ContentView()
}
