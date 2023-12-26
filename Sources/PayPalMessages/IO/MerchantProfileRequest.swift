import Foundation

protocol MerchantProfileRequestable {
    func fetchMerchantProfile(
        environment: Environment,
        clientID: String,
        merchantID: String?,
        onCompletion: @escaping (Result<MerchantProfileData, Error>) -> Void
    )
}

class MerchantProfileRequest: MerchantProfileRequestable {

    private let headers: HTTPHeaders = [
        .acceptLanguage: "en_US",
        .requestedBy: "native-checkout-sdk",
        .accept: "application/json"
    ]

    enum RequestError: Swift.Error {
        case invalidClientID
        case invalidJSON
        case invalidResponse
    }

    deinit {}

    func fetchMerchantProfile(
        environment: Environment,
        clientID: String,
        merchantID: String?,
        onCompletion: @escaping (Result<MerchantProfileData, Error>) -> Void
    ) {
        guard let url = environment.url(.merchantProfile, ["client_id": clientID, "merchant_id": merchantID]) else {
            onCompletion(.failure(RequestError.invalidClientID))
            return
        }

        log(.debug, "fetcheMerchantProfile URL is \(url)")

        fetch(url, headers: headers, session: environment.urlSession) { data, _, error in
            guard let data = data, error == nil else {
                onCompletion(.failure(RequestError.invalidResponse))
                return
            }

            guard let merchantProfileData = try? JSONDecoder().decode(
                MerchantProfileData.self,
                from: data
            ) else {
                onCompletion(.failure(RequestError.invalidJSON))
                return
            }

            onCompletion(.success(merchantProfileData))
        }
    }
}
