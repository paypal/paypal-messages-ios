// swift-tools-version: 5.8
import PackageDescription

let version = "1.0.0-alpha.1"

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
            checksum: "7bf501b2b303e51692d69e7b5532c7d4e447bd0604edcd55aebffb2ce5539451")
    ],
    swiftLanguageVersions: [.v5]
)
