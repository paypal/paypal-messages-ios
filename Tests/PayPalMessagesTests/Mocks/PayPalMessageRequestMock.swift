import Foundation
@testable import PayPalMessages

class PayPalMessageRequestMock: MessageRequestable {

    enum Scenarios {
        case success(messageResponse: MessageResponse? = nil)
        case neverComplete
        case error(paypalDebugID: String?)
    }

    var scenario: Scenarios
    var lastParamsReceived: MessageRequestParameters?
    var requestsPerformed: Int = 0

    init(scenario: Scenarios) {
        self.scenario = scenario
    }

    func fetchMessage(
        parameters: MessageRequestParameters,
        onCompletion: @escaping MessageRequestCompletion
    ) {
        self.lastParamsReceived = parameters
        self.requestsPerformed += 1

        switch scenario {
        case .success:
            if let response = makeResponse() {
                onCompletion(.success(response))
            } else {
                onCompletion(.failure(.invalidResponse()))
            }

        case .error(let paypalDebugID):
            onCompletion(.failure(.invalidResponse(paypalDebugID: paypalDebugID)))

        case .neverComplete:
            break
        }
    }

    // MARK: - Helpers

    private func makeResponse() -> MessageResponse? {
        guard let lastParamsReceived = lastParamsReceived else {
            return nil
        }

        if case .success(messageResponse: let messageResponse) = scenario {
           return messageResponse
        }

        return MessageResponse(
            offerType: makeOfferResponseType(fromParams: lastParamsReceived),
            productGroup: makeProductGroup(fromParams: lastParamsReceived),
            defaultMainContent: "",
            defaultMainAlternative: nil,
            defaultDisclaimer: "",
            genericMainContent: "",
            genericMainAlternative: nil,
            genericDisclaimer: "",
            logoPlaceholder: "",
            modalCloseButtonWidth: 25,
            modalCloseButtonHeight: 25,
            modalCloseButtonAvailWidth: 60,
            modalCloseButtonAvailHeight: 60,
            modalCloseButtonColor: "#2d2d2d",
            modalCloseButtonColorType: "DARK",
            modalCloseButtonAlternativeText: ""
        )
    }

    private func makeOfferResponseType(
        fromParams params: MessageRequestParameters
    ) -> PayPalMessageResponseOfferType {
        let offerTypeStr = params.offerType?.rawValue ?? PayPalMessageResponseOfferType.generic.rawValue
        return PayPalMessageResponseOfferType(rawValue: offerTypeStr) ?? .generic
    }

    private func makeProductGroup(
        fromParams params: MessageRequestParameters
    ) -> PayPalMessageResponseProductGroup {
        switch params.offerType {
        case .payPalCreditNoInterest:
            return .paypalCredit

        default:
            return .payLater
        }
    }
}
