import Foundation
@testable import PayPalMessages

class MerchantProfileRequestMock: MerchantProfileRequestable {

    enum Scenarios {
        // happy path, nothing expired
        case success

        // hard ttl ok, soft ttl timeout
        case ttlSoftExpired

        // both ttls expired
        case ttlHardExpired

        // cache flow disabled
        case cacheFlowDisabled

        // network error
        case networkError
    }

    enum RequestError: Swift.Error {
        case invalidResponse
    }

    var scenario: Scenarios
    var requestsPerformed: Int = 0

    init(scenario: Scenarios) {
        self.scenario = scenario
    }

    func fetchMerchantProfile(
        environment: Environment,
        clientID: String,
        merchantID: String?,
        onCompletion: @escaping (Result<MerchantProfileData, Error>) -> Void
    ) {
        requestsPerformed += 1

        switch scenario {
        case .success:
            onCompletion(.success(makeSuccessResponse()))

        case .ttlSoftExpired:
            onCompletion(.success(makeTtlSoftExpiredResponse()))

        case .ttlHardExpired:
            onCompletion(.success(makeTtlHardExpiredResponse()))

        case .cacheFlowDisabled:
            onCompletion(.success(makeCacheFlowDisabledResponse()))

        case .networkError:
            onCompletion(.failure(RequestError.invalidResponse))
        }
    }

    // MARK: - Helpers

    private func makeSuccessResponse() -> MerchantProfileData {
        MerchantProfileData(
            hash: "TEST_HASH_\(requestsPerformed)",
            ttlHard: Date().addingTimeInterval(TimeInterval(86400)),
            ttlSoft: Date().addingTimeInterval(TimeInterval(900)),
            disabled: false
        )
    }

    private func makeTtlSoftExpiredResponse() -> MerchantProfileData {
        MerchantProfileData(
            hash: "TEST_HASH_TTL_SOFT_\(requestsPerformed)",
            ttlHard: Date().addingTimeInterval(TimeInterval(86400)),
            ttlSoft: Date(),
            disabled: false
        )
    }

    private func makeTtlHardExpiredResponse() -> MerchantProfileData {
        MerchantProfileData(
            hash: "TEST_HASH_TTL_HARD_\(requestsPerformed)",
            ttlHard: Date(),
            ttlSoft: Date(),
            disabled: false
        )
    }

    private func makeCacheFlowDisabledResponse() -> MerchantProfileData {
        MerchantProfileData(
            hash: "TEST_HASH_CACHE_FLOW_DISABLED_\(requestsPerformed)",
            ttlHard: Date().addingTimeInterval(TimeInterval(86400)),
            ttlSoft: Date().addingTimeInterval(TimeInterval(900)),
            disabled: true
        )
    }
}
