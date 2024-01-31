import Foundation

public class PayPalMessageData: NSObject {

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
    public var placement: PayPalMessagePlacement?
    /// Preferred message offer to display
    public var offerType: PayPalMessageOfferType?
    /// Consumer's country (Integrations must be approved by PayPal to use this option)
    public var buyerCountry: String?
    /// Skips the caching layer
    public var ignoreCache = false

    /// Standard integration
    public init(
        clientID: String,
        environment: Environment,
        amount: Double? = nil,
        placement: PayPalMessagePlacement? = nil,
        offerType: PayPalMessageOfferType? = nil
    ) {
        self.clientID = clientID
        self.amount = amount
        self.placement = placement
        self.offerType = offerType
        self.environment = environment
    }

    /// Partner integration
    public init(
        clientID: String,
        merchantID: String,
        environment: Environment,
        partnerAttributionID: String,
        amount: Double? = nil,
        placement: PayPalMessagePlacement? = nil,
        offerType: PayPalMessageOfferType? = nil
    ) {
        self.clientID = clientID
        self.merchantID = merchantID
        self.partnerAttributionID = partnerAttributionID
        self.amount = amount
        self.placement = placement
        self.offerType = offerType
        self.environment = environment
    }

    deinit {}
}

public class PayPalMessageStyle: NSObject {

    /// Logo type
    public var logoType: PayPalMessageLogoType
    /// Text and logo color
    public var color: PayPalMessageColor
    /// Text alignment
    public var textAlignment: PayPalMessageTextAlignment

    public init(
        logoType: PayPalMessageLogoType = .inline,
        color: PayPalMessageColor = .black,
        textAlignment: PayPalMessageTextAlignment = .right
    ) {
        self.logoType = logoType
        self.color = color
        self.textAlignment = textAlignment
    }

    deinit {}
}

/// PayPal Message configuration
public class PayPalMessageConfig: NSObject {

    public var data: PayPalMessageData
    public var style: PayPalMessageStyle

    /// Message configuration
    public init(
        data: PayPalMessageData,
        style: PayPalMessageStyle = PayPalMessageStyle()
    ) {
        self.data = data
        self.style = style
    }

    deinit {}

    public static func setGlobalAnalytics(
        integrationName: String,
        integrationVersion: String,
        deviceID: String? = nil,
        sessionID: String? = nil
    ) {
        AnalyticsLogger.integrationName = integrationName
        AnalyticsLogger.integrationVersion = integrationVersion
        AnalyticsLogger.deviceID = deviceID
        AnalyticsLogger.sessionID = sessionID
    }
}
