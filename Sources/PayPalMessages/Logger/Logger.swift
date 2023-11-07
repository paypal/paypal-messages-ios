import Foundation

struct CloudEvent<T: Encodable>: Encodable {

    let specversion: String = "1.0"
    let id: String
    let type: String = "com.paypal.credit.upstream-presentment.v1"
    let source: String = "urn:paypal:event-src:v1:ios:messages"
    let datacontenttype: String = "application/json"
    // swiftlint:disable:next line_length
    let dataschema: String = "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json"
    let time: String
    let data: T

    init(data: T) {
        self.id = UUID().uuidString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.time = dateFormatter.string(from: Date())
        self.data = data
    }
}

class Logger: Encodable {

    // Integration Details
    let environment: Environment
    let clientID: String
    var merchantID: String?
    var partnerAttributionID: String? // Currently not supported via Checkout config
    var merchantProfileHash: String?

    var components: [ComponentLogger] = []

    let timerInterval: Double = 5
    var timer: Timer?
    var sender: LogSendable = LogSender()

    // Global Details
    static var deviceID: String?
    static var sessionID: String?
    static var integrationVersion: String?
    static var integrationName: String?

    private static var loggers: [String: Logger] = [:]

    private init(
        clientID: String,
        merchantID: String?,
        partnerAttributionID: String?,
        environment: Environment
    ) {
        self.clientID = clientID
        self.merchantID = merchantID
        self.partnerAttributionID = partnerAttributionID
        self.environment = environment

        timer = Timer.scheduledTimer(
            withTimeInterval: timerInterval,
            repeats: true
        ) { _ in
            self.flushEvents()
        }
    }

    deinit {
        timer?.invalidate()
        flushEvents()
    }

    static func get(
        for clientID: String,
        _ merchantID: String? = nil,
        _ partnerAttributionID: String? = nil,
        in environment: Environment
    ) -> Logger {
        let key = [environment.rawValue, clientID, merchantID ?? "nil", partnerAttributionID ?? "nil"]
            .joined(separator: "_")
        if let logger = Logger.loggers[key] {
            return logger
        }

        let logger = Logger(
            clientID: clientID,
            merchantID: merchantID,
            partnerAttributionID: partnerAttributionID,
            environment: environment
        )
        Logger.loggers[key] = logger

        return logger
    }

    static func createMessageLogger(
        environment: Environment,
        clientID: String,
        merchantID: String? = nil,
        partnerAttributionID: String? = nil,
        offerType: PayPalMessageOfferType? = nil,
        amount: Double? = nil,
        placement: PayPalMessagePlacement? = nil,
        buyerCountryCode: String? = nil,
        channel: String? = nil,
        styleColor: PayPalMessageColor,
        styleLogoType: PayPalMessageLogoType,
        styleTextAlign: PayPalMessageTextAlignment
    ) -> ComponentLogger {
        let logger = ComponentLogger(
            type: .message,
            offerType: offerType,
            amount: amount,
            placement: placement,
            channel: channel,
            buyerCountryCode: buyerCountryCode,
            styleColor: styleColor,
            styleLogoType: styleLogoType,
            styleTextAlign: styleTextAlign
        )
        Logger.get(for: clientID, merchantID, partnerAttributionID, in: environment).components.append(logger)
        return logger
    }

    static func createModalLogger(
        environment: Environment,
        clientID: String,
        merchantID: String? = nil,
        partnerAttributionID: String? = nil,
        offerType: PayPalMessageOfferType? = nil,
        amount: Double? = nil,
        placement: PayPalMessagePlacement? = nil,
        buyerCountryCode: String? = nil,
        channel: String? = nil
    ) -> ComponentLogger {
        let logger = ComponentLogger(
            type: .modal,
            offerType: offerType,
            amount: amount,
            placement: placement,
            channel: channel,
            buyerCountryCode: buyerCountryCode
        )
        Logger.get(for: clientID, merchantID, partnerAttributionID, in: environment).components.append(logger)
        return logger
    }

    enum StaticKey: String, CodingKey {
        // Integration Details
        case clientID = "client_id"
        case merchantID = "merchant_id"
        case partnerAttributionID = "partner_attribution_id"
        case merchantProfileHash = "merchant_profile_hash"
        // Global Details
        case deviceID = "device_id"
        case sessionID = "session_id"
        case integrationVersion = "integration_version"
        case integrationName = "integration_name"
        // Build Details
        case libVersion = "lib_version"
        case integrationType = "integration_type"
        // Component Details
        case components = "components"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StaticKey.self)

        try container.encodeIfPresent(clientID, forKey: .clientID)
        try container.encodeIfPresent(merchantID, forKey: .merchantID)
        try container.encodeIfPresent(partnerAttributionID, forKey: .partnerAttributionID)
        try container.encodeIfPresent(merchantProfileHash, forKey: .merchantProfileHash)

        try container.encodeIfPresent(Logger.deviceID, forKey: .deviceID)
        try container.encodeIfPresent(Logger.sessionID, forKey: .sessionID)
        try container.encodeIfPresent(Logger.integrationVersion, forKey: .integrationVersion)
        try container.encodeIfPresent(Logger.integrationName, forKey: .integrationName)

        try container.encodeIfPresent(BuildInfo.integrationType, forKey: .integrationType)
        try container.encodeIfPresent(BuildInfo.version, forKey: .libVersion)

        let componentsWithEvents = components.filter { !$0.events.isEmpty }
        try container.encodeIfPresent(componentsWithEvents, forKey: .components)
    }

    func hasEvents() -> Bool {
        components.contains { !$0.events.isEmpty }
    }

    func clearEvents() {
        for component in components {
            component.clearEvents()
        }
    }

    func flushEvents() {
        guard hasEvents() else { return }

        let cloudEvent = CloudEvent(data: self)
        guard let cloudEventData = try? JSONEncoder().encode(cloudEvent) else { return }

        sender.send(cloudEventData, to: environment)
        clearEvents()
    }
}

protocol LogSendable {
    func send(_ data: Data, to environment: Environment)
}

class LogSender: LogSendable {

    func send(_ data: Data, to environment: Environment) {
        guard let url = environment.url(.log) else { return }
        let headers: [HTTPHeader: String] = [
            .acceptLanguage: "en_US",
            .requestedBy: "native-checkout-sdk",
            .accept: "application/json",
            .contentType: "application/cloudevents+json"
        ]

        log(.debug, "log_payload", with: data, for: environment)

        fetch(url, method: .post, headers: headers, body: data, session: environment.urlSession) { _, _, _ in }
    }
    deinit {}
}
