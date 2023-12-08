// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let version = "1.0.0-prerelease.4"

let package = Package(
    name: "PayPalMessages",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PayPalMessages",
            targets: ["PayPalMessages"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PayPalMessages",
            dependencies: []),
        .testTarget(
            name: "PayPalMessagesTests",
            dependencies: ["PayPalMessages"]),
        .binaryTarget(
            name: "PayPalMessagesBinary",
            url: "https://github.com/paypal/paypal-messages-ios/releases/download/\(version)/PayPalMessages.xcframework.zip",
            checksum: "3fc2ae81ef40e13ff42b6d760f41a3cb420f81fb4073f79c3d9c87e8f6e4f596")
    ]
)
