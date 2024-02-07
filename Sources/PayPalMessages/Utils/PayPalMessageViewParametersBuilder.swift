import UIKit

struct PayPalMessageViewParametersBuilder {

    // swiftlint:disable:next function_parameter_count
    func makeParameters(
        message: String,
        messageAlternative: String?,
        offerType: PayPalMessageResponseOfferType,
        linkDescription: String,
        logoPlaceholder: String,
        logoType: PayPalMessageLogoType,
        payPalAlignment: PayPalMessageTextAlignment,
        payPalColor: PayPalMessageColor,
        productGroup: PayPalMessageResponseProductGroup
    ) -> PayPalMessageViewParameters {
        let shouldDisplayLeadingLogo = shouldDisplayLeadingLogo(
            message: message,
            logoPlaceholder: logoPlaceholder
        )

        let logoImage = getLogoImage(
            logoType: logoType,
            color: payPalColor,
            productGroup: productGroup
        )

        let brandingText = productGroup == .paypalCredit ? "PayPal Credit" : "PayPal"
        var accessibilityLabel = (messageAlternative ?? message).replacingOccurrences(of: logoPlaceholder, with: brandingText)

        accessibilityLabel += " \(linkDescription)"

        if !message.contains(logoPlaceholder) {
            accessibilityLabel = "\(brandingText) - \(accessibilityLabel)"
        }

        return PayPalMessageViewParameters(
            message: message,
            messageColor: getLabelColor(payPalColor),
            shouldDisplayLeadingLogo: shouldDisplayLeadingLogo,
            logoPlaceholder: logoPlaceholder,
            logoImage: logoImage,
            productName: getProductName(productGroup),
            linkDescription: linkDescription,
            linkColor: getLinkColor(payPalColor),
            linkUnderlineColor: getUnderlineLinkColor(payPalColor),
            textAlignment: getAlignment(payPalAlignment),
            accessibilityLabel: accessibilityLabel,
            accessibilityTraits: .button,
            isAccessibilityElement: true
        )
    }

    // MARK: - Image Helpers

    private func getLogoImage(
        logoType: PayPalMessageLogoType,
        color: PayPalMessageColor,
        productGroup: PayPalMessageResponseProductGroup
    ) -> UIImage? {
        let isPayLater = productGroup == .payLater

        switch logoType {
        case .primary:
            return getImageForPrimaryStyle(isPayLater: isPayLater, color: color)

        case .alternative:
            return getImageForAlternativeStyle(isPayLater: isPayLater, color: color)

        case .inline:
            return getImageForInlineStyle(isPayLater: isPayLater, color: color)

        case .none:
            return nil
        }
    }

    private func getImageForPrimaryStyle(
        isPayLater: Bool,
        color: PayPalMessageColor
    ) -> UIImage {
        var asset: ImageAsset

        switch color {
        case .black:
            asset = isPayLater ? ImageAsset.logoPrimaryStandard : ImageAsset.logoPrimaryStandardCredit

        case .white:
            asset = isPayLater ? ImageAsset.logoPrimaryWhite : ImageAsset.logoPrimaryWhiteCredit

        case .monochrome:
            asset = isPayLater ? ImageAsset.logoPrimaryMonochrome : ImageAsset.logoPrimaryMonochromeCredit

        case .grayscale:
            asset = isPayLater ? ImageAsset.logoPrimaryGrayscale : ImageAsset.logoPrimaryGrayscaleCredit
        }

        return ImageAsset.image(asset)
    }

    private func getImageForAlternativeStyle(
        isPayLater: Bool,
        color: PayPalMessageColor
    ) -> UIImage {
        var asset: ImageAsset

        switch color {
        case .black:
            asset = isPayLater ? ImageAsset.logoAlternativeStandard : ImageAsset.logoAlternativeStandardCredit

        case .white:
            asset = isPayLater ? ImageAsset.logoAlternativeWhite : ImageAsset.logoAlternativeWhiteCredit

        case .monochrome:
            asset = isPayLater ? ImageAsset.logoAlternativeMonochrome : ImageAsset.logoAlternativeMonochromeCredit

        case .grayscale:
            asset = isPayLater ? ImageAsset.logoAlternativeGrayscale : ImageAsset.logoAlternativeGrayscaleCredit
        }

        return ImageAsset.image(asset)
    }

    private func getImageForInlineStyle(
        isPayLater: Bool,
        color: PayPalMessageColor
    ) -> UIImage {
        var asset: ImageAsset

        switch color {
        case .black:
            asset = isPayLater ? ImageAsset.logoInlineStandard : ImageAsset.logoInlineStandardCredit

        case .white:
            asset = isPayLater ? ImageAsset.logoInlineWhite : ImageAsset.logoInlineWhiteCredit

        case .monochrome:
            asset = isPayLater ? ImageAsset.logoInlineMonochrome : ImageAsset.logoInlineMonochromeCredit

        case .grayscale:
            asset = isPayLater ? ImageAsset.logoInlineGrayscale : ImageAsset.logoInlineGrayscaleCredit
        }

        return ImageAsset.image(asset)
    }

    // MARK: - Other Helpers

    private func getLabelColor(_ color: PayPalMessageColor) -> UIColor {
        switch color {
        case .black, .grayscale:
            return .colorGrey700

        case .white:
            return .white

        case .monochrome:
            return .black
        }
    }

    private func getLinkColor(_ color: PayPalMessageColor) -> UIColor {
        switch color {
        case .black:
            return .colorBlue600

        default:
            return getLabelColor(color)
        }
    }

    private func getUnderlineLinkColor(_ color: PayPalMessageColor) -> UIColor {
        switch color {
        case .black:
            return .colorBlue600

        default:
            return getLabelColor(color)
        }
    }

    private func getAlignment(_ textAlignment: PayPalMessageTextAlignment) -> NSTextAlignment {
        switch textAlignment {
        case .left:
            return .left

        case .right:
            return .right

        case .center:
            return .center
        }
    }

    private func getProductName(_ productGroup: PayPalMessageResponseProductGroup) -> String {
        let isCredit = productGroup == .paypalCredit
        return isCredit ? "PayPal Credit" : "PayPal"
    }

    private func shouldDisplayLeadingLogo(message: String, logoPlaceholder: String) -> Bool {
        !message.contains(logoPlaceholder)
    }
}
