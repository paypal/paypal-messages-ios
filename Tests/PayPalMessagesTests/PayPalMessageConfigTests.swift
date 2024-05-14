import Foundation
import XCTest
@testable import PayPalMessages

final class PayPalMessageConfigTests: XCTestCase {

    func testSetGlobalAnalytics() {
        let integrationName = "MyIntegration"
        let integrationVersion = "1.0"

        PayPalMessageModalConfig.setGlobalAnalytics(
            integrationName: integrationName,
            integrationVersion: integrationVersion
        )

        XCTAssertEqual(AnalyticsLogger.integrationName, integrationName)
        XCTAssertEqual(AnalyticsLogger.integrationVersion, integrationVersion)
    }

    func testStandardIntegrationInitialization() {
        let clientID = "Client123"
        let amount = 100.0
        let pageType = PayPalMessagePageType.home
        let offerType = PayPalMessageOfferType.payLaterShortTerm
        let environment = Environment.sandbox

        let data = PayPalMessageData(
            clientID: clientID,
            environment: environment,
            amount: amount,
            pageType: pageType,
            offerType: offerType
        )

        let style = PayPalMessageStyle(logoType: .inline, color: .black, textAlign: .right)
        let config = PayPalMessageConfig(data: data, style: style)

        XCTAssertEqual(config.data.clientID, clientID)
        XCTAssertEqual(config.data.amount, amount)
        XCTAssertEqual(config.data.pageType, pageType)
        XCTAssertEqual(config.data.offerType, offerType)
        XCTAssertEqual(config.data.environment, environment)

        XCTAssertEqual(config.style.logoType, .inline)
        XCTAssertEqual(config.style.color, .black)
        XCTAssertEqual(config.style.textAlign, .right)
    }

    func testPartnerIntegrationInitialization() {
        let clientID = "Client123"
        let merchantID = "Merchant456"
        let partnerAttributionID = "Partner789"
        let amount = 100.0
        let pageType = PayPalMessagePageType.home
        let offerType = PayPalMessageOfferType.payLaterShortTerm
        let environment = Environment.sandbox

        let data = PayPalMessageData(
            clientID: clientID,
            merchantID: merchantID,
            environment: environment,
            partnerAttributionID: partnerAttributionID,
            amount: amount,
            pageType: pageType,
            offerType: offerType
        )

        let style = PayPalMessageStyle(logoType: .inline, color: .black, textAlign: .right)
        let config = PayPalMessageConfig(data: data, style: style)

        XCTAssertEqual(config.data.clientID, clientID)
        XCTAssertEqual(config.data.merchantID, merchantID)
        XCTAssertEqual(config.data.partnerAttributionID, partnerAttributionID)
        XCTAssertEqual(config.data.amount, amount)
        XCTAssertEqual(config.data.pageType, pageType)
        XCTAssertEqual(config.data.offerType, offerType)
        XCTAssertEqual(config.data.environment, environment)

        XCTAssertEqual(config.style.logoType, .inline)
        XCTAssertEqual(config.style.color, .black)
        XCTAssertEqual(config.style.textAlign, .right)
    }
}
