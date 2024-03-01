public enum PayPalMessageError: Error, Equatable {
    case invalidURL
    case invalidResponse(paypalDebugID: String? = nil, issue: String? = nil, description: String? = nil)

    public var paypalDebugId: String? {
        switch self {
        case .invalidResponse(let paypalDebugID, _, _):
            return paypalDebugID

        default:
            return nil
        }
    }

    public var issue: String? {
        switch self {
        case .invalidURL:
            return "InvalidURL"
        case .invalidResponse(_, let issue, _):
            return issue ?? "InvalidResponse"
        }
    }

    public var description: String? {
        switch self {
        case .invalidURL:
            return nil
        case .invalidResponse(_, _, let description):
            return description
        }
    }

    static public func == (lhs: PayPalMessageError, rhs: PayPalMessageError) -> Bool {
        lhs.paypalDebugId == rhs.paypalDebugId && lhs.issue == rhs.issue && lhs.description == rhs.description
    }
}
