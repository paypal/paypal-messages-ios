import Foundation
import XCTest
@testable import PayPalMessages

class AnyCodableTests: XCTestCase {

    func testInitialization() {
        // Test various initializations
        let intValue: AnyCodable = 42
        let stringValue: AnyCodable = "Hello, World!"
        let boolValue: AnyCodable = true

        XCTAssertEqual(intValue.value as? Int, 42)
        XCTAssertEqual(stringValue.value as? String, "Hello, World!")
        XCTAssertEqual(boolValue.value as? Bool, true)
    }

    func testEncodeNil() throws {
        // Test encoding nil
        let nilValue: AnyCodable = nil

        let encoder = JSONEncoder()
        let data = try encoder.encode(nilValue)

        let jsonString = String(data: data, encoding: .utf8)
        XCTAssertEqual(jsonString, "null")
    }
}
