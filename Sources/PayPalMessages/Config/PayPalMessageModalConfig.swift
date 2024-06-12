import Foundation
import UIKit

class ModalCloseButtonConfig: NSObject {

    var width: Int
    var height: Int
    var availableWidth: Int
    var availableHeight: Int
    var color: UIColor
    var colorType: String
    var alternativeText: String

    init(
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

class PayPalMessageModalDataConfig: NSObject {

    var clientID: String
    var merchantID: String?
    var partnerAttributionID: String?
    var environment: Environment
    var amount: Double?
    var buyerCountry: String?
    var offerType: PayPalMessageOfferType?
    var pageType: PayPalMessagePageType?
    var channel: String
    var ignoreCache: Bool? // swiftlint:disable:this discouraged_optional_boolean
    var modalCloseButton: ModalCloseButtonConfig
    var features: String?

    /// Standard integration
    init(
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

class PayPalMessageModalConfig: NSObject, Encodable {

    var data: PayPalMessageModalDataConfig

    init(
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
        case features
    }

    func encode(to encoder: Encoder) throws {
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
        try container.encodeIfPresent(data.features, forKey: .features)
    }
}
