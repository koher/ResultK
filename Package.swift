// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "ResultK",
    products: [
        .library(name: "ResultK", targets: ["ResultK"]),
    ],
    targets: [
        .target(name: "ResultK", dependencies: []),
        .testTarget(name: "ResultKTests", dependencies: ["ResultK"]),
    ]
)
