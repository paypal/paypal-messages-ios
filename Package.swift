// swift-tools-version: 5.8
import PackageDescription

let version = "1.2.0"

let package = Package(
    name: "PayPalMessages",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "PayPalMessages",
            targets: ["PayPalMessages"])
    ],
    targets: [
        .binaryTarget(
            name: "PayPalMessages",
            url: "https://github.com/paypal/paypal-messages-ios/releases/download/\(version)/PayPalMessages.xcframework.zip",
            checksum: "819604d748397409167cc17278ce3c1c9c4e73f18dbdde903878839849069e95")
    ],
    swiftLanguageVersions: [.v5]
)
