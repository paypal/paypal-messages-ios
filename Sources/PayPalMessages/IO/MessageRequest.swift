import Foundation

typealias MessageRequestCompletion =
    (Result<MessageResponse, PayPalMessageError>) -> Void

struct MessageRequestParameters {

    let environment: Environment
    let clientID: String
    let merchantID: String?
    let partnerAttributionID: String?
    let logoType: PayPalMessageLogoType
    let buyerCountry: String?
    let pageType: PayPalMessagePageType?
    let amount: Double?
    let offerType: PayPalMessageOfferType?
    let merchantProfileHash: String?
    let ignoreCache: Bool
    let instanceID: String
}

protocol MessageRequestable {
    func fetchMessage(
        parameters: MessageRequestParameters,
        onCompletion: @escaping MessageRequestCompletion
    )
}

class MessageRequest: MessageRequestable {

    private let headers: [HTTPHeader: String] = [
        .acceptLanguage: "en_US",
        .requestedBy: "native-checkout-sdk",
        .accept: "application/json"
    ]

    deinit {}

    private func makeURL(from parameters: MessageRequestParameters) -> URL? {
        let queryParams: [String: String?] = [
            "client_id": parameters.clientID,
            "merchant_id": parameters.merchantID,
            "partner_attribution_id": parameters.partnerAttributionID,
            "logo_type": parameters.logoType.rawValue,
            "buyer_country": parameters.buyerCountry,
            "page_type": parameters.pageType?.rawValue,
            "amount": parameters.amount?.description,
            "offer": parameters.offerType?.rawValue,
            "merchant_config": parameters.merchantProfileHash,
            "ignore_cache": parameters.ignoreCache.description,
            "instance_id": parameters.instanceID,
            "version": BuildInfo.version,
            "integration_type": BuildInfo.integrationType,
            "integration_version": AnalyticsLogger.integrationVersion,
            "device_id": AnalyticsLogger.deviceID,
            "session_id": AnalyticsLogger.sessionID
        ].filter {
            guard let value = $0.value else { return false }

            return !value.isEmpty && value.lowercased() != "false"
        }

        return parameters.environment.url(.message, queryParams)
    }

    func fetchMessage(
        parameters: MessageRequestParameters,
        onCompletion: @escaping MessageRequestCompletion
    ) {
        guard let url = makeURL(from: parameters) else {
            onCompletion(.failure(.invalidURL))
            return
        }
        let startingTimestamp = Date()

        log(.debug, "fetchMessage URL is \(url)")

        fetch(url, headers: headers, session: parameters.environment.urlSession) { data, response, _ in
            let requestDuration = startingTimestamp.timeIntervalSinceNow

            guard let response = response as? HTTPURLResponse else {
                onCompletion(.failure(.invalidResponse()))
                return
            }

            switch response.statusCode {
            case 200:
                guard let data, var messageResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) else {
                    onCompletion(.failure(.invalidResponse(paypalDebugID: response.paypalDebugID)))
                    return
                }

                messageResponse.requestDuration = requestDuration

                onCompletion(.success(messageResponse))

            default:
                guard let data, let responseError = try? JSONDecoder().decode(ResponseError.self, from: data) else {
                    onCompletion(.failure(.invalidResponse(paypalDebugID: response.paypalDebugID)))
                    return
                }

                onCompletion(.failure(.invalidResponse(
                    paypalDebugID: responseError.paypalDebugID,
                    issue: responseError.issue,
                    description: responseError.description
                )))
            }
        }
    }
}
