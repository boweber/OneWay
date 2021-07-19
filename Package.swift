// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Penguin",
    platforms: [.macOS("12.0"), .iOS("15.0")],
    products: [ .library(name: "Penguin", targets: ["Penguin"]) ],
    targets: [
        .target(name: "Penguin"),
        .target(name: "TestingPenguin", dependencies: ["Penguin"]),
        .testTarget(
            name: "PenguinTests",
            dependencies: ["Penguin", "TestingPenguin"],
            resources: [
                .copy("ToDo/Resources/Todo.json")
            ]
        )
    ]
)
