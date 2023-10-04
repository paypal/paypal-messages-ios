import Foundation
import XCTest
@testable import PayPalMessages

class MessageResponseTests: XCTestCase {

    func testDecodeMessageResponse() throws {
        let json = """
        {
            "meta": {
                "credit_product_group": "PAY_LATER",
                "offer_country_code": "US",
                "offer_type": "PAY_LATER_LONG_TERM",
                "message_type": "PLLT_MQ_GZ",
                "modal_close_button": {
                    "width": 26,
                    "height": 26,
                    "available_width": 60,
                    "available_height": 60,
                    "color": "#001435",
                    "color_type": "dark"
                },
                "variables": {
                    "inline_logo_placeholder": "%paypal_logo%"
                },
                "merchant_country_code": "US",
                "credit_product_identifiers": [
                    "PAY_LATER_LONG_TERM_US"
                ],
                "debug_id": "5eea97bb38fa9",
                "fdata": "ABC123",
                "originating_instance_id": "abc123",
                "tracking_keys": [
                    "merchant_country_code",
                    "credit_product_identifiers",
                    "offer_country_code",
                    "message_type",
                    "debug_id",
                    "fdata",
                    "originating_instance_id"
                ]
            },
            "content": {
                "default": {
                    "main": "As low as $187.17/mo with %paypal_logo%.",
                    "disclaimer": "Learn more"
                },
                "generic": {
                    "main": "Buy now, pay later with %paypal_logo%.",
                    "disclaimer": "Learn more"
                }
            }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let messageResponse = try decoder.decode(MessageResponse.self, from: json)

        XCTAssertEqual(messageResponse.offerType, .payLaterLongTerm)
        XCTAssertEqual(messageResponse.productGroup, .payLater)
        XCTAssertEqual(messageResponse.defaultMainContent, "As low as $187.17/mo with %paypal_logo%.")
        XCTAssertEqual(messageResponse.defaultDisclaimer, "Learn more")
    }


    func testEncodeMessageResponse() throws {
        let messageResponse = MessageResponse(
            offerType: .payLaterLongTerm,
            productGroup: .payLater,
            defaultMainContent: "As low as $187.17/mo with %paypal_logo%.",
            defaultDisclaimer: "Learn more",
            genericMainContent: "Buyer now, pay later with %paypal_logo%.",
            genericDisclaimer: "Learn more",
            logoPlaceholder: "%paypal_logo%",
            modalCloseButtonWidth: 26,
            modalCloseButtonHeight: 26,
            modalCloseButtonAvailWidth: 60,
            modalCloseButtonAvailHeight: 60,
            modalCloseButtonColor: "#001435",
            modalCloseButtonColorType: "dark"
        )

        let decoder = JSONDecoder()

        let jsonData = try encodeMessageResponse(messageResponse)

        let decodedMessageResponse = try decoder.decode(MessageResponse.self, from: jsonData)

        XCTAssertEqual(messageResponse.offerType, decodedMessageResponse.offerType)
        XCTAssertEqual(messageResponse.productGroup, decodedMessageResponse.productGroup)
        XCTAssertEqual(messageResponse.defaultMainContent, decodedMessageResponse.defaultMainContent)
        XCTAssertEqual(messageResponse.defaultDisclaimer, decodedMessageResponse.defaultDisclaimer)
        XCTAssertEqual(messageResponse.genericMainContent, decodedMessageResponse.genericMainContent)
        XCTAssertEqual(messageResponse.genericDisclaimer, decodedMessageResponse.genericDisclaimer)
        XCTAssertEqual(messageResponse.logoPlaceholder, decodedMessageResponse.logoPlaceholder)
        XCTAssertEqual(messageResponse.modalCloseButtonWidth, decodedMessageResponse.modalCloseButtonWidth)
        XCTAssertEqual(messageResponse.modalCloseButtonHeight, decodedMessageResponse.modalCloseButtonHeight)
        XCTAssertEqual(messageResponse.modalCloseButtonAvailWidth, decodedMessageResponse.modalCloseButtonAvailWidth)
        XCTAssertEqual(messageResponse.modalCloseButtonAvailHeight, decodedMessageResponse.modalCloseButtonAvailHeight)
        XCTAssertEqual(messageResponse.modalCloseButtonColor, decodedMessageResponse.modalCloseButtonColor)
        XCTAssertEqual(messageResponse.modalCloseButtonColorType, decodedMessageResponse.modalCloseButtonColorType)
    }

    func encodeMessageResponse(_ response: MessageResponse) throws -> Data {
        let content: [String: Any] = [
            "meta": [
                "credit_product_group": response.productGroup.rawValue,
                "offer_type": response.offerType.rawValue,
                "modal_close_button": [
                    "width": response.modalCloseButtonWidth,
                    "height": response.modalCloseButtonHeight,
                    "available_width": response.modalCloseButtonAvailWidth,
                    "available_height": response.modalCloseButtonAvailHeight,
                    "color": response.modalCloseButtonColor,
                    "color_type": response.modalCloseButtonColorType
                ],
                "variables": [
                    "inline_logo_placeholder": response.logoPlaceholder
                ],
                "tracking_keys": []
            ],
            "content": [
                "default": [
                    "main": response.defaultMainContent,
                    "disclaimer": response.defaultDisclaimer
                ],
                "generic": [
                    "main": response.genericMainContent,
                    "disclaimer": response.genericDisclaimer
                ]
            ]
        ]

        return try JSONSerialization.data(withJSONObject: content)
    }
}
