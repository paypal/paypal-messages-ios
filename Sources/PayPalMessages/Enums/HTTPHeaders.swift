typealias HTTPHeaders = [HTTPHeader: String]

enum HTTPHeader: String {
    // MARK: - Standard Headers

    case accept = "Accept"
    case acceptLanguage = "Accept-Language"
    case contentType = "Content-Type"
    case authorization = "Authorization"

    // MARK: - PayPal Specific Headers

    case requestedBy = "X-Requested-By"
}
