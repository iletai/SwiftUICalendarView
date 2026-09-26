// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CalendarView",
    platforms: [
        .macOS(.v13), .iOS(.v17)
    ],
    products: [
        .library(
            name: "CalendarView",
            targets: ["CalendarView"]
        )
    ],
    targets: [
        .target(
            name: "CalendarView"
        ),
        .target(
            name: "CalendarExample",
            dependencies: ["CalendarView"],
            path: "Example"
        ),
        .testTarget(
            name: "CalendarViewTests",
            dependencies: ["CalendarView"]
        )
    ]
)
