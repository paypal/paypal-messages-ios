import Foundation

protocol MerchantProfileHashGetable {
    func getMerchantProfileHash(
        environment: Environment,
        clientID: String,
        merchantID: String?,
        onCompletion: @escaping (String?) -> Void
    )
}

class MerchantProfileProvider: MerchantProfileHashGetable {

    private let merchantProfileRequest: MerchantProfileRequestable

    init(
        merchantProfileRequest: MerchantProfileRequestable = MerchantProfileRequest()
    ) {
        self.merchantProfileRequest = merchantProfileRequest
    }

    deinit {}

    // MARK: - Merchant Hash Methods

    func getMerchantProfileHash(
        environment: Environment,
        clientID: String,
        merchantID: String?,
        onCompletion: @escaping (String?) -> Void
    ) {
        let currentDate = Date()

        // hash must be inside ttl and non-null
        guard let merchantProfileData = getCachedMerchantProfileData(clientID: clientID, merchantID: merchantID),
              currentDate < merchantProfileData.ttlHard else {
            requestMerchantProfile(environment: environment, clientID: clientID, merchantID: merchantID) { merchantProfiledData in
                guard let merchantProfiledData = merchantProfiledData else {
                    onCompletion(nil)
                    return
                }

                onCompletion(merchantProfiledData.disabled ? nil : merchantProfiledData.hash)
            }
            return
        }

        // if date is outside soft-ttl window, re-request data
        if currentDate > merchantProfileData.ttlSoft {
            // ignores the response as it will return hashed value
            requestMerchantProfile(environment: environment, clientID: clientID, merchantID: merchantID) { _ in }
        }

        onCompletion(merchantProfileData.disabled ? nil : merchantProfileData.hash)
    }

    // MARK: - API Fetch Methods

    private func requestMerchantProfile(
        environment: Environment,
        clientID: String,
        merchantID: String?,
        onCompletion: @escaping (MerchantProfileData?) -> Void
    ) {
        merchantProfileRequest.fetchMerchantProfile(environment: environment, clientID: clientID, merchantID: merchantID) { [weak self] result in
            switch result {
            case .success(let merchantProfileData):
                log(.debug, "Merchant Request Hash succeeded with \(merchantProfileData.hash)")
                self?.setCachedMerchantProfileData(merchantProfileData, clientID: clientID, merchantID: merchantID)
                onCompletion(merchantProfileData)

            case .failure(let error):
                log(.debug, "Merchant Request Hash failed with \(error.localizedDescription)")
                onCompletion(nil)
            }
        }
    }

    // MARK: - User Defaults Methods

    private func getCachedMerchantProfileData(clientID: String, merchantID: String?) -> MerchantProfileData? {
        guard let cachedData = UserDefaults.getMerchantProfileData(forClientID: clientID, merchantID: merchantID) else {
            return nil
        }

        return try? JSONDecoder().decode(MerchantProfileData.self, from: cachedData)
    }

    private func setCachedMerchantProfileData(_ data: MerchantProfileData, clientID: String, merchantID: String?) {
        let encodedData = try? JSONEncoder().encode(data)
        UserDefaults.setMerchantProfileData(encodedData, forClientID: clientID, merchantID: merchantID)
    }
}
