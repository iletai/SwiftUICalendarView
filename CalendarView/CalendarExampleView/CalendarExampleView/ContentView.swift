//
//  ContentView.swift
//  CalendarExampleView
//
//  Created by iletai on 24/11/2023.
//

import SwiftUI
import CalendarView
import SwiftDate

struct ContentView: View {
    let dateInterval = DateInterval(
        start: Date(timeIntervalSince1970: 1_617_316_527),
        end: Date(timeIntervalSince1970: 1_627_794_000)
    )
    @State var isShowHeader = false
    @State var isShowDateOut = false
    @State var firstWeekDate = 1
    @State var viewMode = 0
    @State private var selectedDate = Date()

    var body: some View {
        listButtonDemo
        ScrollView {
        CalendarView(
            date: selectedDate
            , dateView: { date in
                VStack {
                    Text(date.dayName)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(
                            Calendar.current.isDateInWeekend(date) ? .red : .black
                        )
                }
            }, headerView: { date in
                VStack {
                    Text(date.weekDayName)
                        .font(.footnote)
                        .fontWeight(.bold)
                }
            }, titleView: { date in
            }, dateOutView: { date in
                Text(DateFormatter.day.string(from: date))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        )
        .enableHeader(isShowHeader)
        .enableDateOut(isShowDateOut)
        .firstWeekDay(firstWeekDate)
        .calendarLocate(locale: Locales.vietnamese.toLocale())
        .calendarLayout(.vertical)
        .dateSpacing(12)
        .backgroundCalendar(.visible(20, .gray.opacity(0.3)))
        .setViewMode(viewMode == 0 ? .week : .month)
        .marginAllDft()
        .infinityFrame()
        .allowsTightening(true)
        .id(UUID())
        }
    }

    var listButtonDemo: some View {
        ScrollView(.horizontal) {
            HStack {
                Button {
                    isShowHeader.toggle()
                } label: {
                    Text("Header")
                }
                Button {
                    viewMode = Int.random(in: 0...1)
                } label: {
                    Text("ViewMode")
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
            .buttonStyle(.bordered)
            .fixedSize()
        }
        .scrollIndicators(.visible, axes: .horizontal)
    }
}

#Preview {
    ContentView()
}
