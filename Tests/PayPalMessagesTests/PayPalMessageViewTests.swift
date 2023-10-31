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

    func testConfigAccessibility() {
        let config = config

        let messageView = PayPalMessageView(
            config: config
        )

        // Assert accessibility properties are correctly initialized
        XCTAssertEqual(messageView.accessibilityTraits, .link)
        XCTAssertTrue(messageView.isAccessibilityElement)
        XCTAssertEqual(messageView.accessibilityLabel, Constants.accessibilityLabel)
    }


    func testStandardIntegrationInitialization() {
        let clientID = "Client123"
        let amount = 100.0
        let placement = PayPalMessagePlacement.home
        let offerType = PayPalMessageOfferType.payLaterShortTerm
        let environment = Environment.sandbox

        let data = PayPalMessageData(
            clientID: clientID,
            environment: environment,
            amount: amount,
            placement: placement,
            offerType: offerType
        )

        let style = PayPalMessageStyle(logoType: .inline, color: .black, textAlignment: .right)
        let config = PayPalMessageConfig(data: data, style: style)

        XCTAssertEqual(config.data.clientID, clientID)
        XCTAssertEqual(config.data.amount, amount)
        XCTAssertEqual(config.data.placement, placement)
        XCTAssertEqual(config.data.offerType, offerType)
        XCTAssertEqual(config.data.environment, environment)

        XCTAssertEqual(config.style.logoType, .inline)
        XCTAssertEqual(config.style.color, .black)
        XCTAssertEqual(config.style.textAlignment, .right)
    }

    func testPartnerIntegrationInitialization() {
        let clientID = "Client123"
        let merchantID = "Merchant456"
        let partnerAttributionID = "Partner789"
        let amount = 100.0
        let placement = PayPalMessagePlacement.home
        let offerType = PayPalMessageOfferType.payLaterShortTerm
        let environment = Environment.sandbox

        let data = PayPalMessageData(
            clientID: clientID,
            merchantID: merchantID,
            environment: environment,
            partnerAttributionID: partnerAttributionID,
            amount: amount,
            placement: placement,
            offerType: offerType
        )

        let style = PayPalMessageStyle(logoType: .inline, color: .black, textAlignment: .right)
        let config = PayPalMessageConfig(data: data, style: style)

        XCTAssertEqual(config.data.clientID, clientID)
        XCTAssertEqual(config.data.merchantID, merchantID)
        XCTAssertEqual(config.data.partnerAttributionID, partnerAttributionID)
        XCTAssertEqual(config.data.amount, amount)
        XCTAssertEqual(config.data.placement, placement)
        XCTAssertEqual(config.data.offerType, offerType)
        XCTAssertEqual(config.data.environment, environment)

        XCTAssertEqual(config.style.logoType, .inline)
        XCTAssertEqual(config.style.color, .black)
        XCTAssertEqual(config.style.textAlignment, .right)
    }
}
