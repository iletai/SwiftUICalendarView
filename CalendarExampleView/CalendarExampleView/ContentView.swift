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
    @State var isShowHeader = false
    @State var isShowDateOut = false
    @State var firstWeekDate = 1
    @State var viewMode = CalendarViewMode.year
    @State private var selectedDate = Date()
    @State private var colorDay = Color.white
    @State var listSelectedDate = [Date]()

    var body: some View {
        VStack {
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
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
                    .background(listSelectedDate.contains(date) ? .cyan : .clear)
                }, headerView: { date in
                    VStack {
                        Text(date.weekDayShortName)
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(
                                Calendar.current.isDateInWeekend(date) ? .red : .black
                            )
                    }
                }, dateOutView: { date in
                    Text(DateFormatter.day.string(from: date))
                        .font(.footnote)
                        .foregroundColor(.gray)
                },
                onSelectedDate: onSelectedDate
            )
            .enableHeader(isShowHeader)
            .enableDateOut(isShowDateOut)
            .firstWeekDay(firstWeekDate)
            .calendarLocate(locale: Locales.vietnamese.toLocale())
            .enablePinedView(.sectionHeaders)
            .setViewMode(viewMode)
            .rowsSpacing(0)
            .columnSpacing(0)
            .backgroundCalendar(.visible(20, .gray.opacity(0.3)))
            .onDraggingEnded { direction in
                if direction == .forward {
                    withAnimation(.easeInOut) {
                        selectedDate = selectedDate.nextWeekday(.friday)
                    }
                } else {
                    withAnimation(.easeInOut) {
                        if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) {
                            selectedDate = previousMonth
                        }
                    }
                }
            }
            .padding(.all, 16 )
            .allowsTightening(true)
            Spacer()
            VStack {
                listButtonDemo
                    .padding()
                Picker("Mode", selection: $viewMode) {
                    ForEach(CalendarViewMode.allCases, id: \.self) { option in
                        Text(String(describing: option).uppercased())
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
                .padding()
            }

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
                    let nextMonth = Calendar.gregorian.date(byAdding: .month, value: 1, to: selectedDate)
                    selectedDate = nextMonth!
                } label: {
                    Text("Next month")
                }

            }
            .buttonStyle(.bordered)
        }
    }

    func onSelectedDate(_ date: Date) {
        if listSelectedDate.contains(date) {
            listSelectedDate.removeAll { $0 == date }
        } else {
            listSelectedDate.append(date)
        }
    }
}

#Preview {
    ContentView()
}
