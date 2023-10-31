import Foundation
import XCTest
@testable import PayPalMessages

class EnvironmentTests: XCTestCase {

    // Test rawValue correctness
    func testRawValues() {
        XCTAssertEqual(Environment.local(port: "1234").rawValue, "local")
        XCTAssertEqual(Environment.stage(host: "testhost").rawValue, "stage")
        XCTAssertEqual(Environment.sandbox.rawValue, "sandbox")
        XCTAssertEqual(Environment.live.rawValue, "production")
    }

    // Test environment setting
    func testEnvironmentSetting() {
        XCTAssertTrue(Environment.live.isProduction)
        XCTAssertTrue(Environment.sandbox.isProduction)
        XCTAssertFalse(Environment.local(port: "1234").isProduction)
        XCTAssertFalse(Environment.stage(host: "testhost").isProduction)
    }

    // Test URL construction
    func testURLConstruction() {
        let localURL = Environment.local(port: "1234").url(.message, ["param": "value"])
        XCTAssertEqual(localURL?.absoluteString, "https://localhost.paypal.com:1234/credit-presentment/native/message?param=value")

        let stageURL = Environment.stage(host: "testhost").url(.modal, ["param": "value"])
        XCTAssertEqual(stageURL?.absoluteString, "https://www.testhost/credit-presentment/lander/modal?param=value")

        let sandboxURL = Environment.sandbox.url(.merchantProfile)
        XCTAssertEqual(sandboxURL?.absoluteString, "https://www.sandbox.paypal.com/credit-presentment/merchant-profile")

        let liveURL = Environment.live.url(.log)
        XCTAssertEqual(liveURL?.absoluteString, "https://www.paypal.com/credit-presentment/glog")
    }
}
