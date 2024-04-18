import Foundation
import UIKit

class Weak<T: AnyObject> {

    weak var value: T?

    init(_ value: T?) {
        self.value = value
    }
}

class AnalyticsLogger: Encodable {

    // Global Details
    static var integrationVersion: String?
    static var integrationName: String?

    var component: Component

    var instanceId: String

    // Includes things like fdata, experience IDs, debug IDs, and the like
    var dynamicData: [String: AnyCodable] = [:]

    // Events tied to the component
    var events: [AnalyticsEvent] = []

    enum Component {
        case message(Weak<PayPalMessageView>)
        case modal(Weak<PayPalMessageModal>)
    }

    init(_ component: Component) {
        self.instanceId = UUID().uuidString
        self.component = component

        AnalyticsService.shared.addLogger(self)
    }

    deinit {}

    enum StaticKey: String, CodingKey {
        // Integration Details
        case offerType = "offer_type"
        case amount = "amount"
        case pageType = "page_type"
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
        case .message(let weakMessage):
            guard let message = weakMessage.value else { return }

            try container.encode("message", forKey: .type)
            try container.encodeIfPresent(message.offerType?.rawValue, forKey: .offerType)
            try container.encodeIfPresent(message.amount, forKey: .amount)
            try container.encodeIfPresent(message.pageType?.rawValue, forKey: .pageType)
            try container.encodeIfPresent(message.buyerCountry, forKey: .buyerCountryCode)
            try container.encodeIfPresent(message.logoType.rawValue, forKey: .styleLogoType)
            try container.encodeIfPresent(message.color.rawValue, forKey: .styleColor)
            try container.encodeIfPresent(message.textAlign.rawValue, forKey: .styleTextAlign)

        case .modal(let weakModal):
            guard let modal = weakModal.value else { return }

            try container.encode("modal", forKey: .type)
            try container.encodeIfPresent(modal.offerType?.rawValue, forKey: .offerType)
            try container.encodeIfPresent(modal.amount, forKey: .amount)
            try container.encodeIfPresent(modal.pageType?.rawValue, forKey: .pageType)
            try container.encodeIfPresent(modal.buyerCountry, forKey: .buyerCountryCode)
        }
    }

    func addEvent(_ event: AnalyticsEvent) {
        self.events.append(event)
    }

    func clearEvents() {
        events.removeAll()
    }
}
