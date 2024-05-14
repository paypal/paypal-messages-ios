// swift-tools-version: 5.8
import PackageDescription

let version = "1.0.0"

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
            checksum: "565ab72a3ab75169e41685b16e43268a39e24217a12a641155961d8b10ffe1b4")
    ],
    swiftLanguageVersions: [.v5]
)
