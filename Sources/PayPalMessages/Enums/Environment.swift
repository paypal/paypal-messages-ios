import Foundation

public enum Environment: Equatable {
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
        }
    }

    public var isProduction: Bool {
        switch self {
        case .live, .sandbox:
            return true
        case .stage:
            return false
        }
    }

    public var urlSession: URLSession {
        switch self {
        case .live, .sandbox:
            return URLSession.shared
        case .stage:
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
        }
    }

    // swiftlint:enable force_unwrapping

    enum PayPalMessagePath: String {
        case message = "/credit-presentment/native/message"
        case modal = "/credit-presentment/lander/modal"
        case merchantProfile = "/credit-presentment/merchant-profile"
        case log = "/v1/credit/upstream-messaging-events"
    }

    private var devTouchpoint: Bool {
        switch self {
        case .stage(_, let devTouchpoint, _):
            return devTouchpoint
        default:
            return false
        }
    }

    private var stageTag: String? {
        switch self {
        case .stage(_, _, let stageTag):
            return stageTag
        default:
            return nil
        }
    }

    func url(_ path: PayPalMessagePath, _ queryParams: [String: String?]? = nil) -> URL? {
        var parts = URLComponents()
        var queryItems = queryParams?.compactMap { key, value in
            value != nil ? URLQueryItem(name: key, value: value) : nil
        } ?? []

        let basePath: URL
        if path == .log {
            basePath = loggerBaseURL
        } else {
            basePath = baseURL

            // Append dev_touchpoint and stage_tag query parameters only for .stage case
            if case .stage(_, let devTouchpoint, let stageTag) = self {
                if devTouchpoint {
                    queryItems.append(URLQueryItem(name: "dev_touchpoint", value: "\(devTouchpoint)"))
                }
                if let stageTag, !stageTag.isEmpty {
                    queryItems.append(URLQueryItem(name: "stage_tag", value: stageTag))
                }
            }
        }

        parts.scheme = basePath.scheme
        parts.host = basePath.host
        parts.path = path.rawValue

        if !queryItems.isEmpty {
            parts.queryItems = queryItems
        }


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
