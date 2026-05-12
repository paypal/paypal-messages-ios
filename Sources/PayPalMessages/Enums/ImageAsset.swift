import UIKit

enum ImageAsset: String {
    case loadingCircle = "loading_circle"
    case closeIcon = "close_icon"

    // MARK: - Alternative Logos

    case logoAlternativeWhite = "alternative_white"
    case logoAlternativeWhiteCredit = "alternative_white_credit"
    case logoAlternativeGrayscale = "alternative_grayscale"
    case logoAlternativeGrayscaleCredit = "alternative_grayscale_credit"
    case logoAlternativeMonochrome = "alternative_monochrome"
    case logoAlternativeMonochromeCredit = "alternative_monochrome_credit"
    case logoAlternativeStandard = "alternative_standard"
    case logoAlternativeStandardCredit = "alternative_standard_credit"

    // MARK: - Primary Logos

    case logoPrimaryWhite = "primary_white"
    case logoPrimaryWhiteCredit = "primary_white_credit"
    case logoPrimaryGrayscale = "primary_grayscale"
    case logoPrimaryGrayscaleCredit = "primary_grayscale_credit"
    case logoPrimaryMonochrome = "primary_monochrome"
    case logoPrimaryMonochromeCredit = "primary_monochrome_credit"
    case logoPrimaryStandard = "primary_standard"
    case logoPrimaryStandardCredit = "primary_standard_credit"

    // MARK: - Inline Logos

    case logoInlineWhite = "inline_white"
    case logoInlineWhiteCredit = "inline_white_credit"
    case logoInlineGrayscale = "inline_grayscale"
    case logoInlineGrayscaleCredit = "inline_grayscale_credit"
    case logoInlineMonochrome = "inline_monochrome"
    case logoInlineMonochromeCredit = "inline_monochrome_credit"
    case logoInlineStandard = "inline_standard"
    case logoInlineStandardCredit = "inline_standard_credit"

    #if SWIFT_PACKAGE
    static let bundle = Bundle.module
    #elseif COCOAPODS
    static let bundle: Bundle = {
        let frameworkBundle = Bundle(for: PayPalMessageView.self)
        if let bundleUrl = frameworkBundle.resourceURL?.appendingPathComponent("PayPalMessages.bundle") {
            if let bundle = Bundle(url: bundleUrl) {
                return bundle
            }
        }
        return frameworkBundle
    }()
    #else
    static let bundle = Bundle(for: PayPalMessageView.self)
    #endif

    static func image(_ img: ImageAsset, _ sized: CGSize? = nil) -> UIImage {
        // swiftlint:disable:next force_unwrapping
        let image = UIImage(named: img.rawValue, in: ImageAsset.bundle, compatibleWith: nil)!

        guard let sized else { return image }

        let renderFormat = UIGraphicsImageRendererFormat.default()
        renderFormat.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: sized, format: renderFormat)

        let newImage = renderer.image { _ in
            image.draw(in: CGRect(x: 0, y: 0, width: sized.width, height: sized.height))
        }

        return newImage
    }
}
