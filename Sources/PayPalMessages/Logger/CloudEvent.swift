import Foundation

class CloudEvent: Encodable {

    let specVersion: String = "1.0"
    let id: String
    let type: String = "com.paypal.credit.upstream-presentment.v1"
    let source: String = "urn:paypal:event-src:v1:ios:messages"
    let dataContentType: String = "application/json"
    // swiftlint:disable:next line_length
    let dataSchema: String = "ppaas:events.credit.FinancingPresentmentAsyncAPISpecification/v1/schema/json/credit_upstream_presentment_event.json"
    let time: String

    var environment: Environment

    var loggers: [Logger]

    enum CloudEventKeys: CodingKey {
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CloudEventKeys.self)

        try container.encode(specVersion, forKey: .specversion)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(source, forKey: .source)
        try container.encode(dataContentType, forKey: .datacontenttype)
        try container.encode(dataSchema, forKey: .dataschema)
        try container.encode(time, forKey: .time)

        var dataContainer = container.nestedContainer(keyedBy: IntegrationKey.self, forKey: .data)

        // The static create function is responsible for ensuring that all loggers on the current CloudEvent
        // have the same top level details used here (e.g. clientID, merchantID, partnerAttributionID)
        guard let logger = loggers.first else { return }

        try dataContainer.encode(logger.clientID, forKey: .clientID)
        try dataContainer.encodeIfPresent(logger.merchantID, forKey: .merchantID)
        try dataContainer.encodeIfPresent(logger.partnerAttributionID, forKey: .partnerAttributionID)
        try dataContainer.encodeIfPresent(logger.merchantProfileHash, forKey: .merchantProfileHash)

        try dataContainer.encodeIfPresent(Logger.deviceID, forKey: .deviceID)
        try dataContainer.encodeIfPresent(Logger.sessionID, forKey: .sessionID)
        try dataContainer.encodeIfPresent(Logger.integrationVersion, forKey: .integrationVersion)
        try dataContainer.encodeIfPresent(Logger.integrationName, forKey: .integrationName)

        try dataContainer.encode(BuildInfo.integrationType, forKey: .integrationType)
        try dataContainer.encode(BuildInfo.version, forKey: .libVersion)

        try dataContainer.encodeIfPresent(loggers, forKey: .components)
    }

    private init(logger: Logger) {
        self.id = UUID().uuidString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.time = dateFormatter.string(from: Date())

        self.environment = logger.environment
        self.loggers = [logger]
    }

    static func create(from loggers: [Logger]) -> [CloudEvent] {
        var map: [String: CloudEvent] = [:]

        for logger in loggers {
            if logger.events.isEmpty {
                continue
            }

            let clientID = logger.clientID
            let merchantID = logger.merchantID
            let partnerAttributionID = logger.partnerAttributionID

            let key = [clientID, merchantID ?? "nil", partnerAttributionID ?? "nil"].joined()

            if let cloudEvent = map[key] {
                cloudEvent.loggers.append(logger)
                continue
            }

            let cloudEvent = CloudEvent(logger: logger)
            map[key] = cloudEvent
        }

        return Array(map.values)
    }
}
