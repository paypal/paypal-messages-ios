import Foundation
import XCTest
@testable import PayPalMessages

final class AnyCodableTests: XCTestCase {

    func testInitialization() {
        // Test various initializations
        let intValue: AnyCodable = 42
        let stringValue: AnyCodable = "Hello, World!"
        let boolValue: AnyCodable = true

        XCTAssertEqual(intValue.value as? Int, 42)
        XCTAssertEqual(stringValue.value as? String, "Hello, World!")
        XCTAssertEqual(boolValue.value as? Bool, true)
    }

    func testEncodeInt() throws {
        // Test encoding int
        let intValue: AnyCodable = 42

        let encoder = JSONEncoder()
        let data = try encoder.encode(intValue)

        let jsonString = String(data: data, encoding: .utf8)
        XCTAssertEqual(jsonString, "42")
    }


    func testEncodeString() throws {
        // Test encoding string
        let stringValue: AnyCodable = "Hello, World!"

        let encoder = JSONEncoder()
        let data = try encoder.encode(stringValue)

        let jsonString = String(data: data, encoding: .utf8)
        XCTAssertEqual(jsonString, "\"Hello, World!\"")
    }

    func testEncodeBool() throws {
        // Test encoding bool
        let boolValue: AnyCodable = true

        let encoder = JSONEncoder()
        let data = try encoder.encode(boolValue)

        let jsonString = String(data: data, encoding: .utf8)
        XCTAssertEqual(jsonString, "true")
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
