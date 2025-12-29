// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Project2026Feature",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Project2026Feature",
            targets: ["Project2026Feature"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Project2026Feature"
        ),
        .testTarget(
            name: "Project2026FeatureTests",
            dependencies: [
                "Project2026Feature"
            ]
        ),
    ]
)
