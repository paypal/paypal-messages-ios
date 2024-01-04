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

@available(iOS 13.0, *)
class PayPalMessageViewTests: XCTestCase {
    var strongMessageView: PayPalMessageView?
    weak var weakMessageView: PayPalMessageView?

    // MARK: - Test Initialization and Configuration

    func testInitialization() {
        let config = config

        let messageView = PayPalMessageView(
            config: config,
            requester: PayPalMessageRequestMock(scenario: .success),
            merchantProfileProvider: MerchantProfileProviderMock(scenario: .success)
        )

        // Assert that properties are correctly set
        XCTAssertEqual(messageView.clientID, config.data.clientID)
        XCTAssertEqual(messageView.color, config.style.color)
    }

    func testMessageViewNotStronglyReferencedInternally() {
        let config = config

        var messageView: PayPalMessageView? = PayPalMessageView(
            config: config,
            requester: PayPalMessageRequestMock(scenario: .success),
            merchantProfileProvider: MerchantProfileProviderMock(scenario: .success)
        )

        strongMessageView = messageView
        weakMessageView = messageView

        messageView = nil

        XCTAssertNotNil(strongMessageView)
        XCTAssertNotNil(weakMessageView)

        strongMessageView = nil

        XCTAssertNil(weakMessageView)
    }
}
