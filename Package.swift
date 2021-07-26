// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OneWay",
    platforms: [.macOS("12.0"), .iOS("15.0")],
    products: [
        .library(name: "OneWay", targets: ["OneWay"]),
        .library(name: "TestingOneWay", targets: ["TestingOneWay"])
    ],
    targets: [
        .target(name: "OneWay"),
        .target(name: "TestingOneWay", dependencies: ["OneWay"]),
        .testTarget(
            name: "OneWayTests",
            dependencies: ["OneWay", "TestingOneWay"],
            resources: [
                .copy("ToDo/Resources/Todo.json")
            ]
        )
    ]
)
