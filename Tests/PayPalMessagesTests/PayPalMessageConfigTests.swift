import Foundation
import XCTest
@testable import PayPalMessages

func testSetGlobalAnalytics() {
    let integrationName = "MyIntegration"
    let integrationVersion = "1.0"
    let deviceID = "Device123"
    let sessionID = "Session456"

    PayPalMessageModalConfig.setGlobalAnalytics(
        integrationName: integrationName,
        integrationVersion: integrationVersion,
        deviceID: deviceID,
        sessionID: sessionID
    )

    XCTAssertEqual(Logger.integrationName, integrationName)
    XCTAssertEqual(Logger.integrationVersion, integrationVersion)
    XCTAssertEqual(Logger.deviceID, deviceID)
    XCTAssertEqual(Logger.sessionID, sessionID)
}

func testSetGlobalAnalyticsWithDefaults() {
    let integrationName = "MyIntegration"
    let integrationVersion = "1.0"

    PayPalMessageConfig.setGlobalAnalytics(
        integrationName: integrationName,
        integrationVersion: integrationVersion
    )

    XCTAssertEqual(Logger.integrationName, integrationName)
    XCTAssertEqual(Logger.integrationVersion, integrationVersion)
    XCTAssertNil(Logger.deviceID)
    XCTAssertNil(Logger.sessionID)
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
