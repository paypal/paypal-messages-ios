import Foundation

class CloudEvent: Encodable {

    let specVersion = "1.0"
    let type = "com.paypal.credit.upstream-presentment.v1"
    let source = "urn:paypal:event-src:v1:ios:messages"
    let dataContentType = "application/json"
    let dataSchema = "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json"

    let id: String
    let time: String

    var environment: Environment
    var loggers: [AnalyticsLogger]

    /// Creates CloudEvents for each set of client ID + merchant ID + partner attribution ID
    static func create(from loggers: [AnalyticsLogger]) -> [CloudEvent] {
        var map: [String: CloudEvent] = [:]

        for logger in loggers {
            if logger.events.isEmpty {
                continue
            }

            let clientID = logger.clientID
            let merchantID = logger.merchantID ?? "nil"
            let partnerAttributionID = logger.partnerAttributionID ?? "nil"

            let key = "\(clientID)_\(merchantID)_\(partnerAttributionID)"

            if let cloudEvent = map[key] {
                cloudEvent.loggers.append(logger)
            } else {
                map[key] = CloudEvent(logger: logger)
            }
        }

        return Array(map.values)
    }

    private init(logger: AnalyticsLogger) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        self.time = dateFormatter.string(from: Date())
        self.id = UUID().uuidString
        self.environment = logger.environment
        self.loggers = [logger]
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

        try dataContainer.encodeIfPresent(AnalyticsLogger.deviceID, forKey: .deviceID)
        try dataContainer.encodeIfPresent(AnalyticsLogger.sessionID, forKey: .sessionID)
        try dataContainer.encodeIfPresent(AnalyticsLogger.integrationVersion, forKey: .integrationVersion)
        try dataContainer.encodeIfPresent(AnalyticsLogger.integrationName, forKey: .integrationName)

        try dataContainer.encode(BuildInfo.integrationType, forKey: .integrationType)
        try dataContainer.encode(BuildInfo.version, forKey: .libVersion)

        // The static create function is responsible for ensuring that all loggers on the current CloudEvent
        // have the same top level details used here (e.g. clientID, merchantID, partnerAttributionID)
        guard let logger = loggers.first else { return }

        try dataContainer.encode(logger.clientID, forKey: .clientID)
        try dataContainer.encodeIfPresent(logger.merchantID, forKey: .merchantID)
        try dataContainer.encodeIfPresent(logger.partnerAttributionID, forKey: .partnerAttributionID)
        try dataContainer.encodeIfPresent(logger.merchantProfileHash, forKey: .merchantProfileHash)

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
}
