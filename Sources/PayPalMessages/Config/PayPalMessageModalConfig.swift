import Foundation
import UIKit

public class ModalCloseButtonConfig: NSObject {

    /// Width of icon in pixels
    public var width: Int
    /// Height of icon in pixels
    public var height: Int
    /// Width available to touch-responsive area in pixels
    public var availableWidth: Int
    /// Height available to touch-responsive area in pixels
    public var availableHeight: Int
    /// Color of button
    public var color: UIColor
    /// Color type, i.e. "light" or "dark" for light or dark mode
    public var colorType: String
    /// Text alternative to visual appearance that would be recited by a screen reader
    public var alternativeText: String

    public init(
        width: Int? = nil,
        height: Int? = nil,
        availableWidth: Int? = nil,
        availableHeight: Int? = nil,
        color: UIColor? = nil,
        colorType: String? = nil,
        alternativeText: String? = nil
    ) {
        self.width = width ?? 26
        self.height = height ?? 26
        self.availableWidth = availableWidth ?? 60
        self.availableHeight = availableHeight ?? 60
        self.color = color ?? UIColor(hexString: "#001435")
        self.colorType = colorType ?? "dark"
        self.alternativeText = alternativeText ?? "PayPal learn more modal close"
    }

    deinit {}
}

public class PayPalMessageModalDataConfig: NSObject {

    /// PayPal developer client ID
    public var clientID: String
    /// PayPal encrypted merchant ID. For partner integrations only.
    public var merchantID: String?
    /// Partner BN Code / Attribution ID assigned to the account. For partner integrations only.
    public var partnerAttributionID: String?
    /// PayPal execution environment
    public var environment: Environment
    /// Price expressed in cents amount based on the current context (i.e. individual product price vs total cart price)
    public var amount: Double?
    /// Message screen location (e.g. product, cart, home)
    public var pageType: PayPalMessagePageType?
    /// Preferred message offer to display
    public var offerType: PayPalMessageOfferType?
    /// Consumer's country (Integrations must be approved by PayPal to use this option)
    public var buyerCountry: String?
    /// Message content channel
    public var channel: String
    /// Skips the caching layer
    public var ignoreCache: Bool? // swiftlint:disable:this discouraged_optional_boolean
    /// Configuration for modal close button
    public var modalCloseButton: ModalCloseButtonConfig

    /// Standard integration
    public init(
        clientID: String,
        environment: Environment,
        amount: Double? = nil,
        pageType: PayPalMessagePageType? = nil,
        offerType: PayPalMessageOfferType? = nil,
        channel: String = BuildInfo.channel,
        modalCloseButton: ModalCloseButtonConfig = ModalCloseButtonConfig()
    ) {
        self.clientID = clientID
        self.amount = amount
        self.pageType = pageType
        self.offerType = offerType
        self.modalCloseButton = modalCloseButton
        self.environment = environment
        self.channel = channel
    }

    /// Partner integration
    init(
        clientID: String,
        merchantID: String,
        environment: Environment,
        partnerAttributionID: String,
        amount: Double? = nil,
        pageType: PayPalMessagePageType? = nil,
        offerType: PayPalMessageOfferType? = nil,
        channel: String = BuildInfo.channel,
        modalCloseButton: ModalCloseButtonConfig = ModalCloseButtonConfig()
    ) {
        self.clientID = clientID
        self.merchantID = merchantID
        self.partnerAttributionID = partnerAttributionID
        self.amount = amount
        self.pageType = pageType
        self.offerType = offerType
        self.modalCloseButton = modalCloseButton
        self.environment = environment
        self.channel = channel
    }

    deinit {}
}

public class PayPalMessageModalConfig: NSObject, Encodable {

    public var data: PayPalMessageModalDataConfig

    public init(
        data: PayPalMessageModalDataConfig
    ) {
        self.data = data
    }

    deinit {}

    public static func setGlobalAnalytics(
        integrationName: String,
        integrationVersion: String
    ) {
        PayPalMessageConfig.setGlobalAnalytics(
            integrationName: integrationName,
            integrationVersion: integrationVersion
        )
    }

    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case merchantID = "merchant_id"
        case partnerAttributionID = "partner_attribution_id"
        case amount
        case buyerCountry
        case offerType = "offer"
        case channel
        case pageType
        case ignoreCache
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(data.clientID, forKey: .clientID)
        try container.encodeIfPresent(data.merchantID, forKey: .merchantID)
        try container.encodeIfPresent(data.partnerAttributionID, forKey: .partnerAttributionID)
        try container.encodeIfPresent(data.amount, forKey: .amount)
        try container.encodeIfPresent(data.buyerCountry, forKey: .buyerCountry)
        try container.encodeIfPresent(data.offerType?.rawValue, forKey: .offerType)
        try container.encodeIfPresent(data.channel, forKey: .channel)
        try container.encodeIfPresent(data.pageType?.rawValue, forKey: .pageType)
        try container.encodeIfPresent(data.ignoreCache, forKey: .ignoreCache)
    }
}
