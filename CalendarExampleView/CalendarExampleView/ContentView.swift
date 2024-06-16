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
    @State var firstWeekDate = CalendarWeekday.monday
    @State var isShowDivider = false
    @State var viewMode = CalendarViewMode.year(.full)
    @State private var selectedDate = Date()
    @State private var colorDay = Color.white
    @State var listSelectedDate = [Date]()
    @State var isHightLightToDay = true

    var fontDate: Font {
        switch viewMode {
        case .month,
        .week,
        .single:
            return .footnote
        case .year(let yearDisplayMode):
            switch yearDisplayMode {
            case .compact:
                return .system(size: 10, weight: .regular)
            case .full:
                return .footnote.weight(.semibold)
            }
        }
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    CalendarView(
                        date: selectedDate
                        , dateView: { date in
                            VStack {
                                Text(date.dayName)
                                    .font(fontDate)
                                    .foregroundColor(
                                        Calendar.current.isDateInWeekend(date) ? .red : .black
                                    )
                            }
                            .frameInfinity()
                            .frame(height: 30)
                            .background(listSelectedDate.contains(date) ? .cyan : .clear)
                        }, headerView: { date in
                            HStack {
                                ForEach(date, id: \.self) {
                                    Text($0.weekDayShortName.uppercased())
                                        .font(fontDate)
                                        .foregroundColor(
                                            Calendar.current.isDateInWeekend($0) ? .red : .black
                                        )
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }, dateOutView: { date in
                            VStack {
                                Text(date.dayName)
                                    .font(fontDate)
                                    .foregroundColor(
                                        Calendar.current.isDateInWeekend(date) ? .red.opacity(0.4) : .gray
                                    )
                            }
                            .frameInfinity()
                            .frame(height: 30)
                            .background(listSelectedDate.contains(date) ? .cyan : .clear)
                        }
                    )
                    .enableHeader(isShowHeader)
                    .enableDateOut(isShowDateOut)
                    .firstWeekDay(firstWeekDate)
                    .calendarLocate(locale: Locales.vietnamese.toLocale())
                    .enablePinedView([.sectionHeaders, .sectionFooters])
                    .setViewMode(viewMode)
                    .rowsSpacing(8)
                    .columnSpacing(8)
                    .background(.visible(12, .gray.opacity(0.1)))
                    .onDraggingEnded { direction, viewMode in
                        if direction == .forward {
                            withAnimation(.easeInOut) {
                                selectedDate = selectedDate.dateAt(
                                    viewMode == .month ? .nextMonth : .nextWeek
                                ).date
                            }
                        } else {
                            withAnimation(.easeInOut) {
                                selectedDate = selectedDate.dateAt(
                                    viewMode == .month ? .prevMonth : .prevWeek
                                ).date
                            }
                        }
                    }
                    .onSelectDate(onSelectedDate)
                    .enableDivider(isShowDivider)
                    .enableHighlightToDay(isHightLightToDay)
                    .marginDefault()
                    .allowsTightening(true)
                    Spacer()

                }
                .frame(maxWidth: .infinity)
            }
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
        Grid(horizontalSpacing: 8.0, verticalSpacing: 8.0) {
            GridRow {
                Button {
                    isShowHeader.toggle()
                } label: {
                    Text("Header")
                }
                Button {
                    isShowDivider.toggle()
                } label: {
                    Text("Divider")
                }

                Button {
                    isShowDateOut.toggle()
                } label: {
                    Text("DateOut")
                }
            }
            GridRow {
                Button {
                    firstWeekDate = CalendarWeekday.allCases.randomElement()!
                } label: {
                    Text("WeekDate")
                }
                Button {
                    let nextMonth = Calendar.gregorian.date(byAdding: .month, value: 1, to: selectedDate)
                    selectedDate = nextMonth!
                } label: {
                    Text("Next")
                }
                Button {
                    isHightLightToDay.toggle()
                } label: {
                    Text("ToDay")
                }
            }
        }
        .buttonStyle(.bordered)
        .maxWidthAble()
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

extension CalendarWeekday: CaseIterable {
    static public var allCases: [CalendarWeekday] {
        [.friday, .monday, .saturday, .thursday, .wednesday, .sunday, .tuesday]
    }
}
