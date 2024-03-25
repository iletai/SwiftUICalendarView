# SwiftUICalendarView
Build a Calendar By Pure SwiftUI with SwiftDate Library for calculator date.

# SwiftUICalendarView

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Build Project](https://github.com/iletai/SwiftUICalendarView/actions/workflows/build_master.yml/badge.svg?branch=master)](https://github.com/iletai/SwiftUICalendarView/actions/workflows/build_master.yml)

SwiftUICalendarView is a Swift Package for building and displaying a simple calendar interface in SwiftUI. This library provides an easy way to integrate a calendar into your app.

## Installation

### Swift Package Manager

To integrate SwiftUICalendarView into your project, add the GitHub URL to the dependencies section in your Package.swift file:

```swift
dependencies: [
    .package(url: "https://github.com/iletai/SwiftUICalendarView.git", from: "1.0.4"),
],
targets: [
    .target(name: "YourTarget", dependencies: ["CalendarView"]),
]
```



## Calendar Mode Support: 
 
|  Month Mode 	| Year Mode  	|  Week Mode 	|
|---	|---	|---	|
|  <img src="https://github.com/iletai/SwiftUICalendarView/assets/26614687/6dc00b90-ab06-4ad2-ade7-41cab66cd2b7" width="300"> 	|   <img src="https://github.com/iletai/SwiftUICalendarView/assets/26614687/29e86851-96d1-47c7-bce3-54ec3d9f5275" width="300"> 	|  <img src="https://github.com/iletai/SwiftUICalendarView/assets/26614687/589e7a68-9e1e-45d1-a73b-e12ffb2d7915" width="300">  	|

## Usable Example Calendar View

```swift
import SwiftUI
import CalendarView
import SwiftDate

struct ContentView: View {
    @State var isShowHeader = false
    @State var isShowDateOut = false
    @State var firstWeekDate = 1
    @State var viewMode = CalendarViewMode.year
    @State private var selectedDate = Date()
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
```

## Customizing the Interface
You can customize the calendar's interface using properties like accentColor, selectedDateColor, and disabledDateColor,...
```swift
            .enableHeader(isShowHeader)
            .enableDateOut(isShowDateOut)
            .firstWeekDay(firstWeekDate)
            .calendarLocate(locale: Locales.vietnamese.toLocale())
            .enablePinedView(.sectionHeaders)
            .setViewMode(viewMode)
            .rowsSpacing(0)
            .columnSpacing(0)
            .backgroundCalendar(.visible(20, .gray.opacity(0.3)))
            .onDraggingEnded {
                selectedDate = selectedDate.nextWeekday(.friday)
            }
```

## Contribution
If you find a bug or have a way to improve the library, create an Issue or propose a Pull Request. We welcome contributions from the community.

# License
SwiftUICalendarView is released under the MIT License. See details in LICENSE.
