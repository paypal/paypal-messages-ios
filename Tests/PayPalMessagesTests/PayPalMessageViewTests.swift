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

        // TODO: This should mock the network requests our other tests, but that drops code coverage of files that do the fetching
        let messageView = PayPalMessageView(
            config: config
        )

        // Assert that properties are correctly set
        XCTAssertEqual(messageView.clientID, config.data.clientID)
        XCTAssertEqual(messageView.color, config.style.color)
    }

    func testMessageViewNotStronglyReferencedInternally() {
        let config = config

        var messageView: PayPalMessageView? = PayPalMessageView(
            config: config,
            requester: PayPalMessageRequestMock(scenario: .success()),
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

    // swiftlint:disable:next function_body_length
    func testMessageAccessibilityLabel() {
        let config = config

        // Inline Pay Monthly message

        let messageResponse = MessageResponse(
            offerType: .payLaterLongTerm,
            productGroup: .payLater,
            defaultMainContent: "As low as $187.17/mo with %paypal_logo%.",
            defaultMainAlternative: "As low as $187.17 per month with PayPal.",
            defaultDisclaimer: "Learn more.",
            genericMainContent: "",
            genericMainAlternative: nil,
            genericDisclaimer: "",
            logoPlaceholder: "%paypal_logo%",
            modalCloseButtonWidth: 25,
            modalCloseButtonHeight: 25,
            modalCloseButtonAvailWidth: 60,
            modalCloseButtonAvailHeight: 60,
            modalCloseButtonColor: "#2d2d2d",
            modalCloseButtonColorType: "DARK",
            modalCloseButtonAlternativeText: "PayPal Modal Close"
        )

        let messageView = PayPalMessageView(
            config: config,
            requester: PayPalMessageRequestMock(scenario: .success(messageResponse: messageResponse)),
            merchantProfileProvider: MerchantProfileProviderMock(scenario: .success)
        )

        XCTAssertEqual(messageView.accessibilityTraits, .button)
        XCTAssertEqual(messageView.isAccessibilityElement, true)
        XCTAssertEqual(messageView.accessibilityLabel, "As low as $187.17 per month with PayPal. Learn more.")

        // Standard Pay Monthly message

        let messageResponse2 = MessageResponse(
            offerType: .payLaterLongTerm,
            productGroup: .payLater,
            defaultMainContent: "As low as $187.17/mo.",
            defaultMainAlternative: "As low as $187.17 per month.",
            defaultDisclaimer: "Learn more.",
            genericMainContent: "",
            genericMainAlternative: nil,
            genericDisclaimer: "",
            logoPlaceholder: "%paypal_logo%",
            modalCloseButtonWidth: 25,
            modalCloseButtonHeight: 25,
            modalCloseButtonAvailWidth: 60,
            modalCloseButtonAvailHeight: 60,
            modalCloseButtonColor: "#2d2d2d",
            modalCloseButtonColorType: "DARK",
            modalCloseButtonAlternativeText: "PayPal Modal Close"
        )

        let messageView2 = PayPalMessageView(
            config: config,
            requester: PayPalMessageRequestMock(scenario: .success(messageResponse: messageResponse2)),
            merchantProfileProvider: MerchantProfileProviderMock(scenario: .success)
        )

        XCTAssertEqual(messageView2.accessibilityTraits, .button)
        XCTAssertEqual(messageView2.isAccessibilityElement, true)
        XCTAssertEqual(messageView2.accessibilityLabel, "PayPal - As low as $187.17 per month. Learn more.")

        // PayPal Credit message

        let messageResponse3 = MessageResponse(
            offerType: .payPalCreditNoInterest,
            productGroup: .paypalCredit,
            defaultMainContent: "No Interest if paid in full in 6 months.",
            defaultMainAlternative: nil,
            defaultDisclaimer: "Learn more.",
            genericMainContent: "",
            genericMainAlternative: nil,
            genericDisclaimer: "",
            logoPlaceholder: "%paypal_logo%",
            modalCloseButtonWidth: 25,
            modalCloseButtonHeight: 25,
            modalCloseButtonAvailWidth: 60,
            modalCloseButtonAvailHeight: 60,
            modalCloseButtonColor: "#2d2d2d",
            modalCloseButtonColorType: "DARK",
            modalCloseButtonAlternativeText: "PayPal Modal Close"
        )

        let messageView3 = PayPalMessageView(
            config: config,
            requester: PayPalMessageRequestMock(scenario: .success(messageResponse: messageResponse3)),
            merchantProfileProvider: MerchantProfileProviderMock(scenario: .success)
        )

        XCTAssertEqual(messageView3.accessibilityTraits, .button)
        XCTAssertEqual(messageView3.isAccessibilityElement, true)
        XCTAssertEqual(messageView3.accessibilityLabel, "PayPal Credit - No Interest if paid in full in 6 months. Learn more.")
    }
}
