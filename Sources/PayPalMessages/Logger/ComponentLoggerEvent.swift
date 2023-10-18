import Foundation

enum ComponentLoggerEvent: Encodable {
    case messageRender(renderDuration: Int, requestDuration: Int)
    case messageClick(linkName: String, linkSrc: String)
    case messageError(errorName: String, errorDescription: String)
    case dynamic(data: [String: AnyCodable])

    enum StaticKey: String, CodingKey {
        case eventType = "event_type"
        case renderDuration = "render_duration"
        case requestDuration = "request_duration"
        case linkName = "page_view_link_name"
        case linkSrc = "page_view_link_source"
        case errorName = "error_name"
        case errorDescription = "error_description"
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case let .messageRender(renderDuration, requestDuration):
            var container = encoder.container(keyedBy: StaticKey.self)

            try container.encode("message_rendered", forKey: .eventType)
            try container.encode(renderDuration, forKey: .renderDuration)
            try container.encode(requestDuration, forKey: .requestDuration)

        case let .messageClick(linkName, linkSrc):
            var container = encoder.container(keyedBy: StaticKey.self)

            try container.encode("message_clicked", forKey: .eventType)
            try container.encode(linkName, forKey: .linkName)
            try container.encode(linkSrc, forKey: .linkSrc)

        case let .messageError(errorName, errorDescription):
            var container = encoder.container(keyedBy: StaticKey.self)

            try container.encode("message_error", forKey: .eventType)
            try container.encode(errorName, forKey: .errorName)
            try container.encode(errorDescription, forKey: .errorDescription)

        case let .dynamic(data):
            var container = encoder.container(keyedBy: AnyStringKey.self)

            for (key, value) in data {
                try container.encode(value, forKey: AnyStringKey(key))
            }
        }
    }
}
