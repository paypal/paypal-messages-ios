import Foundation

class CloudEvent: Encodable {

    let specVersion = "1.0"
    let type = "com.paypal.credit.upstream-presentment.v1"
    let source = "urn:paypal:event-src:v1:ios:messages"
    let dataContentType = "application/json"
    let dataSchema = "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json"

    let id: String
    let time: String

    let environment: Environment
    let clientID: String
    let merchantID: String?
    let partnerAttributionID: String?
    let merchantProfileHash: String?

    var loggers: [AnalyticsLogger]

    /// Creates CloudEvents for each set of client ID + merchant ID + partner attribution ID
    static func create(from loggers: [AnalyticsLogger]) -> [CloudEvent] {
        var map: [String: CloudEvent] = [:]

        for logger in loggers {
            if logger.events.isEmpty {
                continue
            }

            let environment: Environment
            let clientID: String
            let merchantID: String?
            let partnerAttributionID: String?
            let merchantProfileHash: String?

            switch logger.component {
            case .message(let weakMessage):
                guard let message = weakMessage.value else { continue }

                environment = message.environment
                clientID = message.clientID
                merchantID = message.merchantID
                partnerAttributionID = message.partnerAttributionID
                merchantProfileHash = message.merchantProfileHash

            case .modal(let weakModal):
                guard let modal = weakModal.value else { continue }

                environment = modal.environment
                clientID = modal.clientID
                merchantID = modal.merchantID
                partnerAttributionID = modal.partnerAttributionID
                merchantProfileHash = modal.merchantProfileHash
            }

            let key = "\(clientID)_\(merchantID ?? "nil")_\(partnerAttributionID ?? "nil")"

            if let cloudEvent = map[key] {
                cloudEvent.loggers.append(logger)
            } else {
                map[key] = CloudEvent(
                    logger: logger,
                    environment: environment,
                    clientID: clientID,
                    merchantID: merchantID,
                    partnerAttributionID: partnerAttributionID,
                    merchantProfileHash: merchantProfileHash
                )
            }
        }

        return Array(map.values)
    }

    private init(
        logger: AnalyticsLogger,
        environment: Environment,
        clientID: String,
        merchantID: String?,
        partnerAttributionID: String?,
        merchantProfileHash: String?
    ) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        self.time = dateFormatter.string(from: Date())
        self.id = UUID().uuidString
        self.loggers = [logger]
        self.environment = environment
        self.clientID = clientID
        self.merchantID = merchantID
        self.partnerAttributionID = partnerAttributionID
        self.merchantProfileHash = merchantProfileHash
    }


    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CloudEventKey.self)

        try container.encode(specVersion, forKey: .specversion)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(source, forKey: .source)
        try container.encode(dataContentType, forKey: .datacontenttype)
        try container.encode(dataSchema, forKey: .dataschema)
        try container.encode(time, forKey: .time)

        var dataContainer = container.nestedContainer(keyedBy: IntegrationKey.self, forKey: .data)

        try dataContainer.encodeIfPresent(AnalyticsLogger.integrationVersion, forKey: .integrationVersion)
        try dataContainer.encodeIfPresent(AnalyticsLogger.integrationName, forKey: .integrationName)

        try dataContainer.encode(BuildInfo.integrationType, forKey: .integrationType)
        try dataContainer.encode(BuildInfo.version, forKey: .libVersion)

        try dataContainer.encode(clientID, forKey: .clientID)
        try dataContainer.encodeIfPresent(merchantID, forKey: .merchantID)
        try dataContainer.encodeIfPresent(partnerAttributionID, forKey: .partnerAttributionID)
        try dataContainer.encodeIfPresent(merchantProfileHash, forKey: .merchantProfileHash)

        try dataContainer.encodeIfPresent(loggers, forKey: .components)
    }

    enum CloudEventKey: CodingKey {
        case specversion
        case id
        case type
        case source
        case datacontenttype
        case dataschema
        case time
        case data
    }

    enum IntegrationKey: String, CodingKey {
        // Integration Details
        case clientID = "client_id"
        case merchantID = "merchant_id"
        case partnerAttributionID = "partner_attribution_id"
        case merchantProfileHash = "merchant_profile_hash"
        // Global Details
        case integrationVersion = "integration_version"
        case integrationName = "integration_name"
        // Build Details
        case libVersion = "lib_version"
        case integrationType = "integration_type"
        // Component Details
        case components = "components"
    }
}
