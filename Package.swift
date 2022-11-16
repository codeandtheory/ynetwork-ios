// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YNetwork",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "YNetwork",
            targets: ["YNetwork"]
        )
    ],
    targets: [
        .target(name: "YNetwork"),
        .testTarget(
            name: "YNetworkTests",
            dependencies: ["YNetwork"],
            resources: [.process("Resources")]
        )
    ]
)
