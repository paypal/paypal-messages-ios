import Foundation
@testable import PayPalMessages
import XCTest

final class ResponseErrorTests: XCTestCase {

    func testInitialize() throws {
        let responseError = ResponseError(paypalDebugID: "12345", issue: "SOME_ISSUE", description: "some description")

        XCTAssertEqual(responseError.paypalDebugID, "12345")
        XCTAssertEqual(responseError.issue, "SOME_ISSUE")
        XCTAssertEqual(responseError.description, "some description")
    }

    func testErrorWithoutDetails() throws {
        let json = """
        {
            "name": "UNPROCESSABLE_ENTITY",
            "message": "The requested action could not be performed, semantically incorrect, or failed business validation.",
            "debug_id": "12345"
        }
        """
        guard let jsonData = json.data(using: .utf8) else {
            fatalError("Failed to convert string to data")
        }

        let decoder = JSONDecoder()
        let responseError = try decoder.decode(ResponseError.self, from: jsonData)

        XCTAssertEqual(responseError.paypalDebugID, "12345")
        XCTAssertNil(responseError.issue)
        XCTAssertNil(responseError.description)
    }

    func testErrorWithDetails() throws {
        let json = """
        {
            "name": "UNPROCESSABLE_ENTITY",
            "message": "The requested action could not be performed, semantically incorrect, or failed business validation.",
            "debug_id": "12345",
            "details": [
                {
                    "issue": "TEST_ISSUE",
                    "description": "A helpful description."
                }
            ]
        }
        """
        guard let jsonData = json.data(using: .utf8) else {
            fatalError("Failed to convert string to data")
        }

        let decoder = JSONDecoder()
        let responseError = try decoder.decode(ResponseError.self, from: jsonData)

        XCTAssertEqual(responseError.paypalDebugID, "12345")
        XCTAssertEqual(responseError.issue, "TEST_ISSUE")
        XCTAssertEqual(responseError.description, "A helpful description.")
    }
}
