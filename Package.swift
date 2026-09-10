// swift-tools-version: 5.8
import PackageDescription

let version = "2.0.0"

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
            checksum: "d4411c4c49367fc096b8352f2dceba36fc8f601adc6c6d498be92e065cb41f5f")
    ],
    swiftLanguageVersions: [.v5]
)
