import Foundation
import XCTest
@testable import PayPalMessages

class AnyStringKeyTests: XCTestCase {

    func testStringKey() {
        // Create an AnyStringKey instance with a string value
        let key = AnyStringKey(stringValue: "testKey")

        // Verify that the stringValue matches the provided value
        XCTAssertEqual(key.stringValue, "testKey")

        // Verify that intValue is nil
        XCTAssertNil(key.intValue)
    }

    func testStringLiteralInitialization() {
        // Create an AnyStringKey instance using string literal initialization
        let key: AnyStringKey = "literalKey"

        // Verify that the stringValue matches the provided string literal
        XCTAssertEqual(key.stringValue, "literalKey")

        // Verify that intValue is nil
        XCTAssertNil(key.intValue)
    }

    func testIntValue() {
        // Attempt to create an AnyStringKey instance with an intValue (should return nil)
        let key = AnyStringKey(intValue: 42)

        // Verify that the instance is nil
        XCTAssertNil(key)
    }
}
