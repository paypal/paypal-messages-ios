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
    let placement: PayPalMessagePlacement?
    let amount: Double?
    let offerType: PayPalMessageOfferType?
    let merchantProfileHash: String?
    let ignoreCache: Bool
    let devTouchpoint: Bool
    let stageTag: String?
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
            "placement": parameters.placement?.rawValue,
            "amount": parameters.amount?.description,
            "offer": parameters.offerType?.rawValue,
            "merchant_config": parameters.merchantProfileHash,
            "stage_tag": parameters.stageTag,
            "ignore_cache": parameters.ignoreCache.description,
            "dev_touchpoint": parameters.devTouchpoint.description,
            "instance_id": parameters.instanceID,
            "integration_version": Logger.integrationVersion,
            "device_id": Logger.deviceID,
            "session_id": Logger.sessionID
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

        log(.info, "fetchMessage URL is \(url)")
        fetch(url, headers: headers, session: parameters.environment.urlSession) { data, response, _ in
            guard let response = response as? HTTPURLResponse else {
                onCompletion(.failure(.invalidResponse()))
                return
            }
            let requestDuration = startingTimestamp.timeIntervalSinceNow

            guard response.statusCode == 200,
                  let data,
                  var messageResponse = try? JSONDecoder().decode(
                    MessageResponse.self,
                    from: data
                  ) else {
                onCompletion(.failure(
                    .invalidResponse(paypalDebugID: response.paypalDebugID)
                ))
                return
            }

            messageResponse.requestDuration = requestDuration

            onCompletion(.success(messageResponse))
        }
    }
}
