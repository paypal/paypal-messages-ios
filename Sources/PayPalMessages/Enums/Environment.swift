import Foundation

public enum Environment: Equatable {
    case local(port: String = "8443", devTouchpoint: Bool = false, stageTag: String? = nil)
    case stage(host: String, devTouchpoint: Bool = false, stageTag: String? = nil)
    case sandbox
    case live

    public var rawValue: String {
        switch self {
        case .live:
            return "production"
        case .sandbox:
            return "sandbox"
        case .stage:
            return "stage"
        case .local:
            return "local"
        }
    }

    public var isProduction: Bool {
        switch self {
        case .live, .sandbox:
            return true
        case .stage, .local:
            return false
        }
    }

    public var urlSession: URLSession {
        switch self {
        case .live, .sandbox:
            return URLSession.shared
        case .stage, .local:
            return URLSession(
                configuration: .default,
                delegate: DevelopmentSession(),
                delegateQueue: .main
            )
        }
    }

    // swiftlint:disable force_unwrapping
    private var baseURL: URL {
        switch self {
        case .local(let port, _, _):
            return URL(string: "https://localhost.paypal.com:\(port)")!
        case .stage(let host, _, _):
            return URL(string: "https://www.\(host)")!
        case .sandbox:
            return URL(string: "https://www.sandbox.paypal.com")!
        case .live:
            return URL(string: "https://www.paypal.com")!
        }
    }

    // swiftlint:disable force_unwrapping
    private var loggerBaseURL: URL {
        switch self {
        case .stage(let host, _, _):
            return URL(string: "https://api.\(host)")!
        case .sandbox:
            return URL(string: "https://api.sandbox.paypal.com")!
        case .live:
            return URL(string: "https://api.paypal.com")!
        default:
            return baseURL
        }
    }

    // swiftlint:enable force_unwrapping

    enum PayPalMessagePath: String {
        case message = "/credit-presentment/native/message"
        case modal = "/credit-presentment/lander/modal"
        case merchantProfile = "/credit-presentment/merchant-profile"
        case log = "/v1/credit/upstream-messaging-events"
    }

    public var devTouchpoint: Bool {
        switch self {
        case .local(_, let devTouchpoint, _), .stage(_, let devTouchpoint, _):
            return devTouchpoint
        default:
            return false
        }
    }

    public var stageTag: String? {
        switch self {
        case .local(_, _, let stageTag), .stage(_, _, let stageTag):
            return stageTag
        default:
            return nil
        }
    }

    func url(_ path: PayPalMessagePath, _ queryParams: [String: String?]? = nil) -> URL? {
        var parts = URLComponents()
        var queryItems: [URLQueryItem]?

        if let queryParams, !queryParams.isEmpty {
            queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        let basePath: URL
        if path == .log {
            basePath = loggerBaseURL
        } else {
            basePath = baseURL
        }

        parts.scheme = basePath.scheme
        parts.host = basePath.host
        parts.port = basePath.port
        parts.path = path.rawValue
        parts.queryItems = queryItems

        return parts.url
    }
}

class DevelopmentSession: NSObject, URLSessionDelegate {

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.useCredential, nil)
            return
        }

        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}
