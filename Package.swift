// swift-tools-version: 5.8
import PackageDescription

let version = "1.0.0-prerelease.4"

let package = Package(
    name: "PayPalMessages",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "PayPalMessages",
            targets: ["PayPalMessages"])
    ],
    targets: [
        .binaryTarget(
            name: "PayPalMessages",
            url: "https://github.com/paypal/paypal-messages-ios/releases/download/\(version)/PayPalMessages.xcframework.zip",
            checksum: "3fc2ae81ef40e13ff42b6d760f41a3cb420f81fb4073f79c3d9c87e8f6e4f596")
    ],
    swiftLanguageVersions: [.v5]
)
