# PayPal iOS SDK Messages Module

Welcome to the PayPal iOS SDK Messages Module. This package will allow you to integrate PayPal messages in your iOS app to promote offers such as Pay Later and PayPal Credit to your customers.

**The PayPalMessages package permits a deployment target of iOS 14.0 or higher**. It requires Xcode 14.2+ and Swift 5.7+.

## Support 

### Languages
This SDK supports Swift 5.7+. This SDK is written in Swift.

### Package Managers

This SDK supports:
- CocoaPods
- Swift Package Manager
### UI Frameworks

This package supports:
- UIKit
- SwiftUI

## Client ID

In order to display PayPal messages within your iOS application, a Client ID is required. This can be found in your [PayPal Developer Dashboard](https://developer.paypal.com/api/rest/#link-getstarted).

## Demo
1. Open the `PayPalMessages.xcworkspace` in Xcode
2. Resolve the Swift Package Manager packages if needed: `File` > `Packages` > `Resolve Package Versions` or by running `swift package resolve` in Terminal
3. Update the placeholder `clientID` in the default message configuration found in `Demo/DefaultMessageConfig` to your sandbox client ID.
4. Select the `Demo` scheme, and then run.

Xcode 14.2+ is required to run the demo app.

## Testing 

This project uses the `XCTest` framework provided by Xcode. 
To run tests in Xcode, select the `PayPalMessagesTest` scheme and then run.

## CI 

GitHub Actions CI will run all tests and build commands on each PR. This project also takes advantage of `Fastlane` to run tests, lint via `SwiftLint`, build, and release.

## Release Process

This SDK follows Semantic Versioning through the use of [Semantic Release](https://github.com/semantic-release/semantic-release). The release process will be automated via GitHub Actions.

## Feedback

PayPal iOS SDK Messages is in active development and we welcome your feedback! [Submit feedback or report an issue](https://github.com/paypal/paypal-messages-ios/issues).

