import Foundation
@testable import PayPalMessages

class MerchantProfileProviderMock: MerchantProfileHashGetable {

    enum Scenarios {
        case success
        case error
    }

    var scenario: Scenarios

    init(scenario: Scenarios) {
        self.scenario = scenario
    }

    func getMerchantProfileHash(
        environment: Environment,
        clientID: String,
        merchantID: String?,
        onCompletion: @escaping (String?) -> Void
    ) {
        switch scenario {
        case .success:
            onCompletion("TEST_HASH")

        case .error:
            onCompletion(nil)
        }
    }
}
