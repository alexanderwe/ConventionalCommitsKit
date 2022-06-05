// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConventionalCommitsKit",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ConventionalCommitsKit",
            targets: ["ConventionalCommitsKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-parsing", .exact("0.9.2"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ConventionalCommitsKit",
            dependencies: [.product(name: "Parsing", package: "swift-parsing")],
            path: "Sources"
        ),
        .testTarget(
            name: "ConventionalCommitsKitTests",
            dependencies: ["ConventionalCommitsKit"],
            path: "Tests"
        ),
    ]
)
