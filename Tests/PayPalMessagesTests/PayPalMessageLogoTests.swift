@testable import PayPalMessages
import XCTest

final class PayPalMessageLogoTests: XCTestCase {

    private let paramsBuilder = PayPalMessageViewParametersBuilder()

    /// Compares the image given by a certain combination of logoType, color and productGroup, and compares it with the expected asset.
    private func compareLogoImageToAsset(
        logoType: PayPalMessageLogoType,
        color: PayPalMessageColor,
        productGroup: PayPalMessageResponseProductGroup,
        expectedAsset: ImageAsset
    ) {
        let resultParameter = paramsBuilder.makeParameters(
            message: "",
            messageAlternative: nil,
            offerType: PayPalMessageResponseOfferType.payLaterShortTerm,
            linkDescription: "",
            logoPlaceholder: "",
            logoType: logoType,
            payPalAlignment: .left,
            payPalColor: color,
            productGroup: productGroup
        )
        guard let resultImage = resultParameter.logoImage else {
            XCTFail("Failed to load images")
            return
        }

        XCTAssertEqual(resultImage, ImageAsset.image(expectedAsset))
    }

    // MARK: - Primary Logos

    func testLoadingPrimaryStandardLogo() {
        compareLogoImageToAsset(
            logoType: .primary,
            color: .black,
            productGroup: .payLater,
            expectedAsset: .logoPrimaryStandard
        )
    }

    func testLoadingPrimaryStandardCreditLogo() {
        compareLogoImageToAsset(
            logoType: .primary,
            color: .black,
            productGroup: .paypalCredit,
            expectedAsset: .logoPrimaryStandardCredit
        )
    }

    func testLoadingPrimaryWhiteLogo() {
        compareLogoImageToAsset(
            logoType: .primary,
            color: .white,
            productGroup: .payLater,
            expectedAsset: .logoPrimaryWhite
        )
    }

    func testLoadingPrimaryWhiteCreditLogo() {
        compareLogoImageToAsset(
            logoType: .primary,
            color: .white,
            productGroup: .paypalCredit,
            expectedAsset: .logoPrimaryWhiteCredit
        )
    }

    func testLoadingPrimaryMonochromeLogo() {
        compareLogoImageToAsset(
            logoType: .primary,
            color: .monochrome,
            productGroup: .payLater,
            expectedAsset: .logoPrimaryMonochrome
        )
    }

    func testLoadingPrimaryMonochromeCreditLogo() {
        compareLogoImageToAsset(
            logoType: .primary,
            color: .monochrome,
            productGroup: .paypalCredit,
            expectedAsset: .logoPrimaryMonochromeCredit
        )
    }

    func testLoadingPrimaryGrayscaleLogo() {
        compareLogoImageToAsset(
            logoType: .primary,
            color: .grayscale,
            productGroup: .payLater,
            expectedAsset: .logoPrimaryGrayscale
        )
    }

    func testLoadingPrimaryGrayscaleCreditLogo() {
        compareLogoImageToAsset(
            logoType: .primary,
            color: .grayscale,
            productGroup: .paypalCredit,
            expectedAsset: .logoPrimaryGrayscaleCredit
        )
    }

    // MARK: - Alternative Logos

    func testLoadingAlternativeStandardLogo() {
        compareLogoImageToAsset(
            logoType: .alternative,
            color: .black,
            productGroup: .payLater,
            expectedAsset: .logoAlternativeStandard
        )
    }

    func testLoadingAlternativeStandardCreditLogo() {
        compareLogoImageToAsset(
            logoType: .alternative,
            color: .black,
            productGroup: .paypalCredit,
            expectedAsset: .logoAlternativeStandardCredit
        )
    }

    func testLoadingAlternativeWhiteLogo() {
        compareLogoImageToAsset(
            logoType: .alternative,
            color: .white,
            productGroup: .payLater,
            expectedAsset: .logoAlternativeWhite
        )
    }

    func testLoadingAlternativeWhiteCreditLogo() {
        compareLogoImageToAsset(
            logoType: .alternative,
            color: .white,
            productGroup: .paypalCredit,
            expectedAsset: .logoAlternativeWhiteCredit
        )
    }

    func testLoadingAlternativeMonochromeLogo() {
        compareLogoImageToAsset(
            logoType: .alternative,
            color: .monochrome,
            productGroup: .payLater,
            expectedAsset: .logoAlternativeMonochrome
        )
    }

    func testLoadingAlternativeMonochromeCreditLogo() {
        compareLogoImageToAsset(
            logoType: .alternative,
            color: .monochrome,
            productGroup: .paypalCredit,
            expectedAsset: .logoAlternativeMonochromeCredit
        )
    }

    func testLoadingAlternativeGrayscaleLogo() {
        compareLogoImageToAsset(
            logoType: .alternative,
            color: .grayscale,
            productGroup: .payLater,
            expectedAsset: .logoAlternativeGrayscale
        )
    }

    func testLoadingAlternativeGrayscaleCreditLogo() {
        compareLogoImageToAsset(
            logoType: .alternative,
            color: .grayscale,
            productGroup: .paypalCredit,
            expectedAsset: .logoAlternativeGrayscaleCredit
        )
    }

    // MARK: - Inline Logos

    func testLoadingInlineStandardLogo() {
        compareLogoImageToAsset(
            logoType: .inline,
            color: .black,
            productGroup: .payLater,
            expectedAsset: .logoInlineStandard
        )
    }

    func testLoadingInlineStandardCreditLogo() {
        compareLogoImageToAsset(
            logoType: .inline,
            color: .black,
            productGroup: .paypalCredit,
            expectedAsset: .logoInlineStandardCredit
        )
    }

    func testLoadingInlineWhiteLogo() {
        compareLogoImageToAsset(
            logoType: .inline,
            color: .white,
            productGroup: .payLater,
            expectedAsset: .logoInlineWhite
        )
    }

    func testLoadingInlineWhiteCreditLogo() {
        compareLogoImageToAsset(
            logoType: .inline,
            color: .white,
            productGroup: .paypalCredit,
            expectedAsset: .logoInlineWhiteCredit
        )
    }

    func testLoadingInlineMonochromeLogo() {
        compareLogoImageToAsset(
            logoType: .inline,
            color: .monochrome,
            productGroup: .payLater,
            expectedAsset: .logoInlineMonochrome
        )
    }

    func testLoadingInlineMonochromeCreditLogo() {
        compareLogoImageToAsset(
            logoType: .inline,
            color: .monochrome,
            productGroup: .paypalCredit,
            expectedAsset: .logoInlineMonochromeCredit
        )
    }

    func testLoadingInlineGrayscaleLogo() {
        compareLogoImageToAsset(
            logoType: .inline,
            color: .grayscale,
            productGroup: .payLater,
            expectedAsset: .logoInlineGrayscale
        )
    }

    func testLoadingInlineGrayscaleCreditLogo() {
        compareLogoImageToAsset(
            logoType: .inline,
            color: .grayscale,
            productGroup: .paypalCredit,
            expectedAsset: .logoInlineGrayscaleCredit
        )
    }

    // MARK: - No Logo

    func testLoadingNoLogo() {
        let allColors: [PayPalMessageColor] = [.black, .white, .monochrome, .grayscale]
        let allProductGroups: [PayPalMessageResponseProductGroup] = [.payLater, .paypalCredit]

        for color in allColors {
            for productGroup in allProductGroups {
                let resultParameter = paramsBuilder.makeParameters(
                    message: "",
                    messageAlternative: nil,
                    offerType: PayPalMessageResponseOfferType.payLaterShortTerm,
                    linkDescription: "",
                    logoPlaceholder: "",
                    logoType: .none,
                    payPalAlignment: .left,
                    payPalColor: color,
                    productGroup: productGroup
                )
                let resultImage = resultParameter.logoImage
                XCTAssertNil(resultImage)
            }
        }
    }

    func testImageAssetLoading() {
        // Test loading an image without specifying a size
        let loadingCircleImage = ImageAsset.image(.loadingCircle)
        XCTAssertNotNil(loadingCircleImage)

        // Test loading an image with a specified size
        let closeIconImage = ImageAsset.image(.closeIcon, CGSize(width: 20, height: 20))
        XCTAssertNotNil(closeIconImage)
        XCTAssertEqual(closeIconImage.size, CGSize(width: 20, height: 20))
    }
}
