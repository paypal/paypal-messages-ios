// swift-tools-version: 5.8
import PackageDescription

let version = "1.0.0-prerelease.6"

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
            checksum: "d9629801acbe39e1a2bf0404331d5417cf64f1b00c4aac78cdf66178a43791c7")
    ],
    swiftLanguageVersions: [.v5]
)
