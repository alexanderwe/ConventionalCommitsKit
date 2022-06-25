// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConventionalCommitsKit",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13)
    ],
    products: [
        .library(
            name: "ConventionalCommitsKit",
            targets: ["ConventionalCommitsKit"]),
    ],
    dependencies: [
        // Source code dependencies
        .package(url: "https://github.com/pointfreeco/swift-parsing", exact: "0.9.2"),

        // Plugins
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "ConventionalCommitsKit",
            dependencies: [
                .product(name: "Parsing", package: "swift-parsing")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ConventionalCommitsKitTests",
            dependencies: [
                "ConventionalCommitsKit"
            ],
            path: "Tests"
        ),
    ]
)
