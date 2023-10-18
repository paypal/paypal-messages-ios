import Foundation

class ComponentLogger: Encodable {

    // Integration Details
    var offerType: PayPalMessageOfferType?
    var amount: Double?
    var placement: PayPalMessagePlacement?
    var buyerCountryCode: String?
    var channel: String?

    // Message Only
    var styleLogoType: PayPalMessageLogoType?
    var styleColor: PayPalMessageColor?
    var styleTextAlign: PayPalMessageTextAlignment?

    // Other Details
    var type: PayPalMessageComponentLoggerType
    var instanceId: String

    // Includes things like fdata, experience IDs, debug IDs, and the like
    // See the Confluence page above for more info
    var dynamicData: [String: AnyCodable] = [:]

    // Events tied to the component
    var events: [ComponentLoggerEvent] = []

    enum PayPalMessageComponentLoggerType: String, Encodable {
        case message
        case modal
    }

    init(
        type: PayPalMessageComponentLoggerType,
        offerType: PayPalMessageOfferType?,
        amount: Double?,
        placement: PayPalMessagePlacement?,
        channel: String?,
        buyerCountryCode: String?,
        // Message only
        styleColor: PayPalMessageColor? = nil,
        styleLogoType: PayPalMessageLogoType? = nil,
        styleTextAlign: PayPalMessageTextAlignment? = nil
    ) {
        self.instanceId = UUID().uuidString
        self.type = type
        self.offerType = offerType
        self.amount = amount
        self.placement = placement
        self.buyerCountryCode = buyerCountryCode
        self.styleColor = styleColor
        self.styleLogoType = styleLogoType
        self.styleTextAlign = styleTextAlign
    }

    deinit {}

    enum StaticKey: String, CodingKey {
        // Integration Details
        case offerType = "offer_type"
        case amount = "amount"
        case placement = "placement"
        case buyerCountryCode = "buyer_country_code"
        case channel = "channel"
        // Message Only
        case styleLogoType = "style_logo_type"
        case styleColor = "style_color"
        case styleTextAlign = "style_text_align"
        // Other Details
        case type = "type"
        case instanceId = "instance_id"
        // Component Events
        case events = "component_events"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StaticKey.self)

        try container.encodeIfPresent(offerType?.rawValue, forKey: .offerType)
        try container.encodeIfPresent(amount, forKey: .amount)
        try container.encodeIfPresent(placement?.rawValue, forKey: .placement)
        try container.encodeIfPresent(buyerCountryCode, forKey: .buyerCountryCode)
        try container.encodeIfPresent(channel, forKey: .channel)
        try container.encodeIfPresent(styleLogoType?.rawValue, forKey: .styleLogoType)
        try container.encodeIfPresent(styleColor?.rawValue, forKey: .styleColor)
        try container.encodeIfPresent(styleTextAlign?.rawValue, forKey: .styleTextAlign)

        try container.encode(type, forKey: .type)
        try container.encode(instanceId, forKey: .instanceId)

        try dynamicData.encode(to: encoder)

        try container.encode(events, forKey: .events)
    }

    func addEvent(_ event: ComponentLoggerEvent) {
        self.events.append(event)
    }

    func clearEvents() {
        events.removeAll()
    }
}
