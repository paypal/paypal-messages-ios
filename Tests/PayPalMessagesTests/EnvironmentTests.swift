import Foundation
import XCTest
@testable import PayPalMessages

class EnvironmentTests: XCTestCase {

    // Test rawValue correctness
    func testRawValues() {
        XCTAssertEqual(Environment.stage(host: "testhost").rawValue, "stage")
        XCTAssertEqual(Environment.sandbox.rawValue, "sandbox")
        XCTAssertEqual(Environment.live.rawValue, "production")
    }

    // Test environment setting
    func testEnvironmentSetting() {
        XCTAssertTrue(Environment.live.isProduction)
        XCTAssertTrue(Environment.sandbox.isProduction)
        XCTAssertFalse(Environment.stage(host: "testhost").isProduction)
    }

    // Test URL construction
    func testURLConstruction() {
        let stageURL = Environment.stage(host: "testhost").url(.modal, ["param": "value"])
        XCTAssertEqual(stageURL?.absoluteString, "https://www.testhost/credit-presentment/lander/modal?param=value")

        let sandboxURL = Environment.sandbox.url(.merchantProfile)
        XCTAssertEqual(sandboxURL?.absoluteString, "https://www.sandbox.paypal.com/credit-presentment/merchant-profile")

        let liveURL = Environment.live.url(.log)
        XCTAssertEqual(liveURL?.absoluteString, "https://api.paypal.com/v1/credit/upstream-messaging-events")
    }
}
