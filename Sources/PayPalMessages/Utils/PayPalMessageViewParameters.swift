import UIKit

struct PayPalMessageViewParameters {

    let message: String
    let messageColor: UIColor

    let shouldDisplayLeadingLogo: Bool
    let logoPlaceholder: String
    let logoImage: UIImage?
    let productName: String

    let linkDescription: String
    let linkColor: UIColor
    let linkUnderlineColor: UIColor

    let textAlign: NSTextAlignment

    let accessibilityLabel: String
    let accessibilityTraits: UIAccessibilityTraits
    let isAccessibilityElement: Bool
}
