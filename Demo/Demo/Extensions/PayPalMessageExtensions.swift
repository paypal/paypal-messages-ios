import Foundation
import PayPalMessages

// MARK: - Enum Displaying Helpers
typealias PayPalMessageEnumType = CaseIterable & CustomStringConvertible & Equatable

extension PayPalMessageTextAlign: CustomStringConvertible {

    public var description: String {
        switch self {
        case .left:
            return "Left"
        case .center:
            return "Center"
        case .right:
            return "Right"
        }
    }
}

extension PayPalMessageLogoType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .inline:
            return "Inline"
        case .primary:
            return "Primary"
        case .alternative:
            return "Alternative"
        case .none:
            return "None"
        }
    }
}

extension PayPalMessageColor: CustomStringConvertible {

    public var description: String {
        switch self {
        case .black:
            return "Black"
        case .white:
            return "White"
        case .monochrome:
            return "Monochrome"
        case .grayscale:
            return "Grayscale"
        }
    }
}


extension PayPalMessageOfferType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .payLaterShortTerm:
            return "Short Term"
        case .payLaterLongTerm:
            return "Long Term"
        case .payLaterPayIn1:
            return "Pay in 1"
        case .payPalCreditNoInterest:
            return "Credit"
        }
    }
}
