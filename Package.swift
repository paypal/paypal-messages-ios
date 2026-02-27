// swift-tools-version: 5.8
import PackageDescription

let version = "1.1.0"

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
            checksum: "e5bc8d95746330e453a537fb789bf53ce3994f5d20feeb5ddabdcd69e177ff33")
    ],
    swiftLanguageVersions: [.v5]
)
