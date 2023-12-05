// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CalendarView",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CalendarView",
            targets: ["CalendarView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/malcommac/SwiftDate.git", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CalendarView",
            dependencies: [
                .product(name: "SwiftDate", package: "SwiftDate")
            ]
        ),
        .testTarget(
            name: "CalendarViewTests",
            dependencies: ["CalendarView"]),
    ]
)