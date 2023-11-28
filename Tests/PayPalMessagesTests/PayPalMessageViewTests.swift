import Foundation
import XCTest
import SwiftUI
@testable import PayPalMessages

let config = PayPalMessageConfig(
    data: .init(
        clientID: "Test123",
        environment: .sandbox
    ),
    style: .init(
        color: .black
    )
)

enum Constants {
    static let accessibilityLabel: String = "PayPalMessageView"
    static let highlightedAnimationDuration: CGFloat = 1.0
    static let highlightedAlpha: CGFloat = 0.75
    static let regularAlpha: CGFloat = 1.0
    static let fontSize: CGFloat = 14.0
}

@available(iOS 13.0, *)
class PayPalMessageViewTests: XCTestCase {

    // MARK: - Test Initialization and Configuration

    func testInitialization() {
        let config = config

        let messageView = PayPalMessageView(
            config: config
        )

        // Assert that properties are correctly set
        XCTAssertEqual(messageView.clientID, config.data.clientID)
        XCTAssertEqual(messageView.color, config.style.color)
    }
}
