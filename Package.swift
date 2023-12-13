// swift-tools-version: 5.8
import PackageDescription

let version = "1.0.0-prerelease.5"

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
            checksum: "265847811e84f6fa8b12324122568ec609a9f9d3a2cb8994d43e7ea4c9970d01")
    ],
    swiftLanguageVersions: [.v5]
)
