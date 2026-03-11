import UIKit

final class PayPalMessageAttributedStringBuilder {

    private enum Constants {
        /// Space between lines when wrapping
        static let lineSpacing: CGFloat = 2.0
        /// Font size used for raw text
        static let fontSize: CGFloat = 14.0
        /// Font size used for logo image
        static let fontSizeLogo: CGFloat = 16.0
        /// Ratio of the height of 'P' to the lower part of 'y' below the baseline in the PayPal logo image
        static let capHeightToDescenderRatio: CGFloat = 17.0 / 76.0
        /// Extra offset to position the baseline of the PayPal logo text slightly below the raw text baseline
        static let descenderOffset: CGFloat = 0.5
        /// Ratio of the height of the PP monogram to 'PayPal' height in the PP PayPal logo image
        static let monogramToPayPalRatio: CGFloat = 120.0 / 93.0
    }

    deinit {}

    // MARK: - String Making Methods

    /// Makes the PayPal Message Attributed String from the content string, adding the PayPal Logo where the logo placeholder indicates.
    /// If no content has been provided, returns an empty string.
    func makeMessageString(
        _ parameters: PayPalMessageViewParameters?
    ) -> NSAttributedString {
        guard let parameters = parameters, !parameters.message.isEmpty else {
            return NSAttributedString(string: "")
        }

        let attributedText = NSMutableAttributedString()

        // if logo should go at the beginning, append it there
        if parameters.shouldDisplayLeadingLogo {
            attributedText.append(makeLogoAttributedString(parameters))
            attributedText.append(makeSpaceAttributedString(2))
        }

        // main message with bold formatting
        attributedText.append(makeMainMessageAttributedStringWithBold(parameters))

        // if logo has a custom location, search for placeholder and replace
        if !parameters.shouldDisplayLeadingLogo {
            let logoRange = attributedText.mutableString.range(of: parameters.logoPlaceholder)
            attributedText.replaceCharacters(
                in: logoRange,
                with: makeLogoAttributedString(parameters)
            )
        }

        attributedText.append(makeSpaceAttributedString())
        attributedText.append(makeLinkAttributedString(parameters))

        // add paragraph style
        attributedText.addAttribute(
            .paragraphStyle,
            value: makeAttributedStringStyle(parameters),
            range: NSRange(location: 0, length: attributedText.length)
        )

        return attributedText
    }
    /// Returns the main message attributed string, applying bold formatting to substrings wrapped in %bold%...%bold%.
    private func makeMainMessageAttributedStringWithBold(_ parameters: PayPalMessageViewParameters) -> NSAttributedString {
        let message = parameters.message
        let baseFont = getDynamicTypeFont(for: .systemFont(ofSize: Constants.fontSize))
        let boldFont = getDynamicTypeFont(for: .boldSystemFont(ofSize: Constants.fontSize))
        let color = parameters.messageColor

        let result = NSMutableAttributedString()
        var currentIndex = message.startIndex

        while let boldStart = message.range(of: "%bold%", range: currentIndex..<message.endIndex) {
            // Add text before bold marker
            let beforeBold = String(message[currentIndex..<boldStart.lowerBound])
            if !beforeBold.isEmpty {
                let normalAttr = NSAttributedString(string: beforeBold, attributes: [
                    .font: baseFont,
                    .foregroundColor: color
                ])
                result.append(normalAttr)
            }
            // Find end marker
            let afterBoldStart = boldStart.upperBound
            if let boldEnd = message.range(of: "%bold%", range: afterBoldStart..<message.endIndex) {
                let boldText = String(message[afterBoldStart..<boldEnd.lowerBound])
                let boldAttr = NSAttributedString(string: boldText, attributes: [
                    .font: boldFont,
                    .foregroundColor: color
                ])
                result.append(boldAttr)
                currentIndex = boldEnd.upperBound
            } else {
                // No end marker, treat rest as normal
                let rest = String(message[afterBoldStart..<message.endIndex])
                let normalAttr = NSAttributedString(string: rest, attributes: [
                    .font: baseFont,
                    .foregroundColor: color
                ])
                result.append(normalAttr)
                break
            }
        }
        // Add any remaining text after last bold marker
        if currentIndex < message.endIndex {
            let remaining = String(message[currentIndex..<message.endIndex])
            let normalAttr = NSAttributedString(string: remaining, attributes: [
                .font: baseFont,
                .foregroundColor: color
            ])
            result.append(normalAttr)
        }
        return result
    }

    // MARK: - Private Helpers

    private func makeLogoAttributedString(
        _ parameters: PayPalMessageViewParameters
    ) -> NSAttributedString {
        guard let logoImage = parameters.logoImage else {
            return NSAttributedString(
                string: parameters.productName,
                attributes: [
                    .foregroundColor: parameters.messageColor,
                    .font: getDynamicTypeFont(for: .boldSystemFont(ofSize: Constants.fontSize))
                ]
            )
        }

        let logoAttachment = NSTextAttachment()
        logoAttachment.image = parameters.logoImage
        logoAttachment.bounds = getMessageIconBounds(
            // Slight font size increase over standard to make the logo size slightly more prominent
            forFontSize: Constants.fontSizeLogo,
            includesMonogram: parameters.shouldDisplayLeadingLogo,
            icon: logoImage
        )

        return NSAttributedString(attachment: logoAttachment)
    }

    private func makeMainMessageAttributedString(
        _ parameters: PayPalMessageViewParameters
    ) -> NSAttributedString {
        NSAttributedString(
            string: parameters.message,
            attributes: [
                .foregroundColor: parameters.messageColor,
                .font: getDynamicTypeFont(for: .systemFont(ofSize: Constants.fontSize))
            ]
        )
    }

    private func makeLinkAttributedString(
        _ parameters: PayPalMessageViewParameters
    ) -> NSAttributedString {
        NSAttributedString(
            string: parameters.linkDescription,
            attributes: [
                .foregroundColor: parameters.linkColor,
                .font: getDynamicTypeFont(for: .systemFont(ofSize: Constants.fontSize)),
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: parameters.linkUnderlineColor
            ]
        )
    }

    private func makeSpaceAttributedString(_ count: Int = 1) -> NSAttributedString {
        NSAttributedString(string: String(repeating: " ", count: count))
    }

    private func makeAttributedStringStyle(
        _ parameters: PayPalMessageViewParameters
    ) -> NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = getAccessibilityScaledValue(Constants.lineSpacing)
        style.alignment = parameters.textAlign
        return style
    }

    /// Returns the icon bounds.
    /// The icon height will be the cap height + descender, with an optional monogram multiplier, and the Y position will
    /// be offset by the size of the descender to lower the icon image below the text baseline.
    private func getMessageIconBounds(
        forFontSize fontSize: CGFloat,
        includesMonogram: Bool,
        icon: UIImage
    ) -> CGRect {
        // Use the cap height of the displayed raw text as the basis for calculations.
        // The cap height is the distance from the baseline to the highest point of a capital letter.
        // The height of 'P' would be the cap height.
        let capHeight = getDynamicTypeFont(for: .systemFont(ofSize: fontSize)).capHeight
        // The descender is the lowest part of the text that goes below the baseline.
        // The difference in height between 'a' and 'y' would be the descender, where the
        // descender is just the bottom part of 'y'. We calculate it ourselves instead of pulling it
        // from the font because the PayPal logo has a slightly different descender ratio.
        let descender = capHeight * Constants.capHeightToDescenderRatio + Constants.descenderOffset
        // Used to scale up the calculations when the image includes a monogram since the
        // "PayPal" portion is smaller than the "PP" monogram
        let monogramMultiplier = includesMonogram ? Constants.monogramToPayPalRatio : 1
        // Ratio which is used to calculate the correctly scaled width of the boundary
        let iconRatio = icon.size.width / icon.size.height
        // The height consists of the cap height ('P') and descender (bottom of 'y') and an optional
        // monogram ratio upscale when present
        let iconHeight = (capHeight + descender) * monogramMultiplier
        // Veritical shift down so that the descender (bottom of 'y') falls below the baseline
        let iconYOffset = -1 * descender

        return CGRect(
            x: 0,
            y: getAccessibilityScaledValue(iconYOffset),
            width: getAccessibilityScaledValue(iconHeight * iconRatio),
            height: getAccessibilityScaledValue(iconHeight)
        )
    }

    // MARK: - Accessibility Helpers

    /// Returns the adjusted dimension for a value, using the current Accessibility Size
    private func getAccessibilityScaledValue(_ dimension: CGFloat) -> CGFloat {
        UIFontMetrics(forTextStyle: .body).scaledValue(for: dimension)
    }

    private func getDynamicTypeFont(for font: UIFont) -> UIFont {
        UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
    }
}
