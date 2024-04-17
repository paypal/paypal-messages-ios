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
                    "color_type": "dark",
                    "alternative_text": "PayPal learn more modal close"
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
                    "main_alternative": "As low as $187.17 per month with PayPal.",
                    "disclaimer": "Learn more"
                },
                "generic": {
                    "main": "Buy now, pay later with %paypal_logo%.",
                    "disclaimer": "Learn more"
                }
            }
        }
        """
            // swiftlint:disable force_unwrapping
            .data(using: .utf8)!

        let decoder = JSONDecoder()
        let messageResponse = try decoder.decode(MessageResponse.self, from: json)

        XCTAssertEqual(messageResponse.offerType, .payLaterLongTerm)
        XCTAssertEqual(messageResponse.productGroup, .payLater)
        XCTAssertEqual(messageResponse.defaultMainContent, "As low as $187.17/mo with %paypal_logo%.")
        XCTAssertEqual(messageResponse.defaultDisclaimer, "Learn more")
        XCTAssertEqual(messageResponse.defaultMainAlternative, "As low as $187.17 per month with PayPal.")
        XCTAssertEqual(messageResponse.modalCloseButtonAlternativeText, "PayPal learn more modal close")
    }
}
