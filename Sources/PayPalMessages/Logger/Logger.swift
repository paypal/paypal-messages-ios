import Foundation

class Logger: Encodable {

    // Global Details
    static var deviceID: String?
    static var sessionID: String?
    static var integrationVersion: String?
    static var integrationName: String?

    var component: Component

    var instanceId: String

    var clientID: String {
        switch component {
        case .message(let message):
            message.clientID
        case .modal(let modal):
            modal.clientID
        }
    }
    var merchantID: String? {
        switch component {
        case .message(let message):
            message.merchantID
        case .modal(let modal):
            modal.merchantID
        }
    }
    var partnerAttributionID: String? {
        switch component {
        case .message(let message):
            message.partnerAttributionID
        case .modal(let modal):
            modal.partnerAttributionID
        }
    }
    var environment: Environment {
        switch component {
        case .message(let message):
            message.environment
        case .modal(let modal):
            modal.environment
        }
    }
    var merchantProfileHash: String? {
        switch component {
        case .message(let message):
            message.merchantProfileHash
        case .modal(let modal):
            modal.merchantProfileHash
        }
    }

    // Includes things like fdata, experience IDs, debug IDs, and the like
    var dynamicData: [String: AnyCodable] = [:]

    // Events tied to the component
    var events: [LoggerEvent] = []

    enum Component {
        case message(_ component: PayPalMessageView)
        case modal(_ component: PayPalMessageModal)
    }

    init(_ component: Component) {
        self.instanceId = UUID().uuidString
        self.component = component

        LoggerService.shared.addLogger(self)
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

        try container.encode(instanceId, forKey: .instanceId)
        try container.encode(events, forKey: .events)
        try dynamicData.encode(to: encoder)

        switch component {
        case .message(let message):
            try container.encode("message", forKey: .type)
            try container.encodeIfPresent(message.offerType?.rawValue, forKey: .offerType)
            try container.encodeIfPresent(message.amount, forKey: .amount)
            try container.encodeIfPresent(message.placement?.rawValue, forKey: .placement)
            try container.encodeIfPresent(message.buyerCountry, forKey: .buyerCountryCode)
            try container.encodeIfPresent(message.logoType.rawValue, forKey: .styleLogoType)
            try container.encodeIfPresent(message.color.rawValue, forKey: .styleColor)
            try container.encodeIfPresent(message.alignment.rawValue, forKey: .styleTextAlign)

        case .modal(let modal):
            try container.encode("modal", forKey: .type)
            try container.encodeIfPresent(modal.offerType?.rawValue, forKey: .offerType)
            try container.encodeIfPresent(modal.amount, forKey: .amount)
            try container.encodeIfPresent(modal.placement?.rawValue, forKey: .placement)
            try container.encodeIfPresent(modal.buyerCountry, forKey: .buyerCountryCode)
        }
    }

    func addEvent(_ event: LoggerEvent) {
        self.events.append(event)
    }

    func clearEvents() {
        events.removeAll()
    }
}
