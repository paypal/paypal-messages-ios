import Foundation
import UIKit

class ModalCloseButtonConfig: NSObject {

    var width: Int
    var height: Int
    var availableWidth: Int
    var availableHeight: Int
    var color: UIColor
    var colorType: String

    init(
        width: Int? = nil,
        height: Int? = nil,
        availableWidth: Int? = nil,
        availableHeight: Int? = nil,
        color: UIColor? = nil,
        colorType: String? = nil
    ) {
        self.width = width ?? 26
        self.height = height ?? 26
        self.availableWidth = availableWidth ?? 60
        self.availableHeight = availableHeight ?? 60
        self.color = color ?? UIColor(hexString: "#001435")
        self.colorType = colorType ?? "dark"
    }

    deinit {}
}

class PayPalMessageModalDataConfig: NSObject {

    var clientID: String
    var merchantID: String?
    var partnerAttributionID: String?
    var environment: Environment
    var amount: Double?
    var currency: String?
    var buyerCountry: String?
    var offerType: PayPalMessageOfferType?
    var placement: PayPalMessagePlacement?
    var channel: String?
    var ignoreCache: Bool? // swiftlint:disable:this discouraged_optional_boolean
    var devTouchpoint: Bool? // swiftlint:disable:this discouraged_optional_boolean
    var stageTag: String?
    var modalCloseButton: ModalCloseButtonConfig

    /// Standard integration
    init(
        clientID: String,
        environment: Environment,
        amount: Double? = nil,
        currency: String? = nil,
        placement: PayPalMessagePlacement? = nil,
        offerType: PayPalMessageOfferType? = nil,
        modalCloseButton: ModalCloseButtonConfig = ModalCloseButtonConfig()
    ) {
        self.clientID = clientID
        self.amount = amount
        self.currency = currency
        self.placement = placement
        self.offerType = offerType
        self.modalCloseButton = modalCloseButton
        self.environment = environment
    }

    /// Partner integration
    init(
        clientID: String,
        merchantID: String,
        environment: Environment,
        partnerAttributionID: String,
        amount: Double? = nil,
        currency: String? = nil,
        placement: PayPalMessagePlacement? = nil,
        offerType: PayPalMessageOfferType? = nil,
        modalCloseButton: ModalCloseButtonConfig = ModalCloseButtonConfig()
    ) {
        self.clientID = clientID
        self.merchantID = merchantID
        self.partnerAttributionID = partnerAttributionID
        self.amount = amount
        self.currency = currency
        self.placement = placement
        self.offerType = offerType
        self.modalCloseButton = modalCloseButton
        self.environment = environment
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
        integrationVersion: String,
        deviceID: String? = nil,
        sessionID: String? = nil
    ) {
        PayPalMessageConfig.setGlobalAnalytics(
            integrationName: integrationName,
            integrationVersion: integrationVersion,
            deviceID: deviceID,
            sessionID: sessionID
        )
    }

    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case merchantID = "merchant_id"
        case partnerAttributionID = "partner_attribution_id"
        case amount
        case currency
        case buyerCountry
        case offerType = "offer"
        case channel
        case placement
        case ignoreCache
        case devTouchpoint
        case stageTag
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(data.clientID, forKey: .clientID)
        try container.encodeIfPresent(data.merchantID, forKey: .merchantID)
        try container.encodeIfPresent(data.partnerAttributionID, forKey: .partnerAttributionID)
        try container.encodeIfPresent(data.amount, forKey: .amount)
        try container.encodeIfPresent(data.currency, forKey: .currency)
        try container.encodeIfPresent(data.buyerCountry, forKey: .buyerCountry)
        try container.encodeIfPresent(data.offerType?.rawValue, forKey: .offerType)
        try container.encodeIfPresent(data.channel, forKey: .channel)
        try container.encodeIfPresent(data.placement?.rawValue, forKey: .placement)
        try container.encodeIfPresent(data.ignoreCache, forKey: .ignoreCache)
        try container.encodeIfPresent(data.devTouchpoint, forKey: .devTouchpoint)
        try container.encodeIfPresent(data.stageTag, forKey: .stageTag)
    }
}
