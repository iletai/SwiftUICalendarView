<p align="center">
  <img src="https://github.com/iletai/SwiftUICalendarView/assets/26614687/cc7b3b91-73ff-4195-9377-4ece5fd299fe" height="128">
  <h1 align="center">Calendar For SwiftUI</h1>
</p>

<p align="center">
  <a aria-label="Follow Me on Instagram" href="https://www.instagram.com/tai.lqt" target="_blank">
    <img alt="" src="https://github.com/iletai/SwiftUICalendarView/assets/26614687/176e7212-8803-459a-8940-d209c7177643" height="28">
  </a>
</p>


SwiftUI is a component for creating a calendar view with SwiftUI Framework.
Build a Calendar By Pure SwiftUI with SwiftDate Library for calculator date. SwiftUICalendarView is a Swift Package for building and displaying a simple calendar interface in SwiftUI. This library provides an easy way to integrate a calendar into your app.


<img width="1012" height="300" alt="github-banner" src="https://github.com/iletai/SwiftUICalendarView/assets/26614687/96833803-42c3-41ca-9270-852a81e290c6">

## SwiftUICalendarView

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Build Project](https://github.com/iletai/SwiftUICalendarView/actions/workflows/build_master.yml/badge.svg?branch=master)](https://github.com/iletai/SwiftUICalendarView/actions/workflows/build_master.yml)


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



### Feature Support: 
 - Calendar Mode: Week, Month, Year
 - First WeekDay
 - Show Date Out
 - Pin Header Calendar
 - Allow Custom Owner Calendar Date View


### Usable Example Calendar View

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

### Customizing the Interface
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
### Example:
> [!NOTE]
> For example using this repository, please help to see more at: https://github.com/iletai/SwiftUICalendarView/tree/master/CalendarExampleView
## Contribution
If you find a bug or have a way to improve the library, create an Issue or propose a Pull Request. We welcome contributions from the community.

### License
SwiftUICalendarView is released under the MIT License. See details in LICENSE.
