@testable import PayPalMessages
import XCTest

final class PayPalMessageAttributedStringTests: XCTestCase {

    private let stringBuilder = PayPalMessageAttributedStringBuilder()

    private let nonLeadingTestMessage: String = "Pay in several installments with %PayPal%."
    private let leadingTestMessage: String = "Pay in several installments."
    private let testLogoPlaceholder: String = "%PayPal%"
    private let testLogo: UIImage = ImageAsset.image(.logoAlternativeStandard)
    private let testProductName: String = "PayPal"
    private let testLinkDescription: String = "Learn More"

    // MARK: - Parameter Builder

    /// Builds the Attributed String Parameters
    private func buildParameters(
        emptyMessage: Bool = false,
        leadingLogo: Bool = true,
        hasLogoImage: Bool = true
    ) -> PayPalMessageViewParameters {
        let testMessage = leadingLogo ? leadingTestMessage : nonLeadingTestMessage
        return PayPalMessageViewParameters(
            message: emptyMessage ? "" : testMessage,
            messageColor: .black,
            shouldDisplayLeadingLogo: leadingLogo,
            logoPlaceholder: testLogoPlaceholder,
            logoImage: hasLogoImage ? testLogo : nil,
            productName: testProductName,
            linkDescription: testLinkDescription,
            linkColor: .blue,
            linkUnderlineColor: .blue,
            textAlign: .left,
            accessibilityLabel: "Pay in several installments with PayPal. Learn More",
            accessibilityTraits: .button,
            isAccessibilityElement: true
        )
    }

    // MARK: - Tests

    func testNoMessageProvided() {
        let params = buildParameters(emptyMessage: true)
        let attributedString = stringBuilder.makeMessageString(params)
        XCTAssert(attributedString.string.isEmpty)
    }

    func testMessageWithLeadingLogo() {
        let params = buildParameters(
            leadingLogo: true,
            hasLogoImage: true
        )
        let attributedString = stringBuilder.makeMessageString(params)

        // verify string matches the expected message and that it contains the leading image
        let expectedString = "￼  Pay in several installments. Learn More"
        XCTAssertEqual(attributedString.string, expectedString)
        XCTAssertTrue(attributedString.containsAttachments(in: NSRange(location: 0, length: 1)))
    }

    func testMessageWithNonLeadingLogo() {
        let params = buildParameters(
            leadingLogo: false,
            hasLogoImage: true
        )
        let attributedString = stringBuilder.makeMessageString(params)

        // verify string matches the expected message
        let expectedString = "Pay in several installments with ￼. Learn More"
        XCTAssertEqual(attributedString.string, expectedString)

        // verify the image falls in the expected range
        if let expectedLogoRange = nonLeadingTestMessage.range(of: testLogoPlaceholder) {
            let expectedLogoNSRange = NSRange(expectedLogoRange, in: nonLeadingTestMessage)
            XCTAssertTrue(attributedString.containsAttachments(in: expectedLogoNSRange))
            XCTAssertFalse(attributedString.containsAttachments(in: NSRange(location: 0, length: 1)))
        } else {
            XCTFail("Failed to find logo placeholder")
        }
    }

    func testMessageWithLeadingNonImageLogo() {
        let params = buildParameters(
            leadingLogo: true,
            hasLogoImage: false
        )
        let attributedString = stringBuilder.makeMessageString(params)

        // verify string matches the expected message and that it contains the leading product name
        let expectedString = "PayPal  Pay in several installments. Learn More"
        XCTAssertEqual(attributedString.string, expectedString)

        // verify there are no images in the text
        let length = attributedString.string.count
        XCTAssertFalse(attributedString.containsAttachments(in: NSRange(location: 0, length: length)))
    }

    func testMessageWithNonLeadingNonImageLogo() {
        let params = buildParameters(
            leadingLogo: false,
            hasLogoImage: false
        )
        let attributedString = stringBuilder.makeMessageString(params)

        // verify string matches the expected message and that it contains the product name in the placeholder position
        let expectedString = "Pay in several installments with PayPal. Learn More"
        XCTAssertEqual(attributedString.string, expectedString)

        // verify there are no images in the text
        let length = attributedString.string.count
        XCTAssertFalse(attributedString.containsAttachments(in: NSRange(location: 0, length: length)))
    }
}
