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
