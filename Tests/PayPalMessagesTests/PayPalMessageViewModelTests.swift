@testable import PayPalMessages
import XCTest

// swiftlint:disable:next type_body_length
final class PayPalMessageViewModelTests: XCTestCase {

    let mockSender = LogSenderMock()

    override func setUp() {
        super.setUp()

        // Inject mock sender to intercept log requests
        AnalyticsService.shared.sender = mockSender
    }

    // MARK: - Test Initial Config Values

    func testInitialConfigSetting() {
        let mockedView = PayPalMessageViewMock()
        let mockedDelegate = PayPalMessageViewDelegateMock()

        // init ViewModel with mocked delegate
        let viewModel = makePayPalMessageViewModel(
            mockedView: mockedView,
            mockedDelegate: mockedDelegate
        )

        // verify the content was returned and appropriate delegate events called
        XCTAssertTrue(mockedView.refreshContentCalled)
        XCTAssertTrue(mockedDelegate.onSuccessCalled)
        XCTAssertTrue(mockedDelegate.onLoadingCalled)
        XCTAssertFalse(mockedDelegate.onErrorCalled)
        XCTAssertNotNil(viewModel.messageParameters)
    }

    func testInitialConfigSettingLoading() {
        // we set the request to never return to simulate a request in progress
        let mockedView = PayPalMessageViewMock()
        let mockedDelegate = PayPalMessageViewDelegateMock()
        let mockedRequest = PayPalMessageRequestMock(scenario: .neverComplete)

        // init ViewModel with mocked delegate in error scenario
        let viewModel = makePayPalMessageViewModel(
            mockedView: mockedView,
            mockedDelegate: mockedDelegate,
            mockedRequest: mockedRequest
        )

        // verify the content was returned and appropriate delegate events called
        XCTAssertFalse(mockedView.refreshContentCalled)
        XCTAssertFalse(mockedDelegate.onSuccessCalled)
        XCTAssertTrue(mockedDelegate.onLoadingCalled)
        XCTAssertFalse(mockedDelegate.onErrorCalled)
        XCTAssertNil(viewModel.messageParameters)
    }

    func testInitialConfigSettingError() {
        let mockedView = PayPalMessageViewMock()
        let mockedDelegate = PayPalMessageViewDelegateMock()
        let mockedRequest = PayPalMessageRequestMock(scenario: .error(paypalDebugID: "123456"))

        // init ViewModel with mocked delegate in error scenario
        let viewModel = makePayPalMessageViewModel(
            mockedView: mockedView,
            mockedDelegate: mockedDelegate,
            mockedRequest: mockedRequest
        )

        // verify the content was returned and appropriate delegate events called
        XCTAssertTrue(mockedView.refreshContentCalled)
        XCTAssertFalse(mockedDelegate.onSuccessCalled)
        XCTAssertTrue(mockedDelegate.onLoadingCalled)
        XCTAssertTrue(mockedDelegate.onErrorCalled)
        XCTAssertNil(viewModel.messageParameters)

        guard case .invalidResponse(let paypalDebugID) = mockedDelegate.error else {
            XCTFail("Expected error invalidResponse")
            return
        }

        XCTAssertEqual(paypalDebugID, "123456")
    }

    // MARK: - Single Parameter Testing

    func testSimpleAmountUpdate() {
        let mockedRequest = PayPalMessageRequestMock(scenario: .success())

        // init ViewModel with mocked delegate in error scenario
        let viewModel = makePayPalMessageViewModel(
            mockedRequest: mockedRequest
        )

        XCTAssertNil(viewModel.amount)
        XCTAssertEqual(mockedRequest.requestsPerformed, 1)

        // test a random Int is being set correctly in the ViewModel
        let newAmount = Double.random(in: 0...1000)
        viewModel.amount = newAmount
        XCTAssertEqual(viewModel.amount, newAmount)

        viewModel.flushUpdates()

        XCTAssertEqual(mockedRequest.requestsPerformed, 2)
    }

    func testSimplePlacementUpdate() {
        let mockedRequest = PayPalMessageRequestMock(scenario: .success())

        // init ViewModel with mocked delegate in error scenario
        let viewModel = makePayPalMessageViewModel(
            mockedRequest: mockedRequest
        )

        XCTAssertNil(viewModel.placement)
        XCTAssertEqual(mockedRequest.requestsPerformed, 1)

        // test the new parameter is being correctly sent
        let newValue: PayPalMessagePlacement = .payment
        viewModel.placement = newValue
        XCTAssertEqual(viewModel.placement, newValue)

        viewModel.flushUpdates()

        XCTAssertEqual(mockedRequest.requestsPerformed, 2)
    }

    func testSimpleOfferTypeUpdate() {
        let mockedRequest = PayPalMessageRequestMock(scenario: .success())

        // init ViewModel with mocked delegate in error scenario
        let viewModel = makePayPalMessageViewModel(
            mockedRequest: mockedRequest
        )

        XCTAssertNil(viewModel.offerType)
        XCTAssertEqual(mockedRequest.requestsPerformed, 1)

        // test the new parameter is being correctly sent
        let newValue: PayPalMessageOfferType = .payPalCreditNoInterest
        viewModel.offerType = newValue
        XCTAssertEqual(viewModel.offerType, newValue)

        viewModel.flushUpdates()

        XCTAssertEqual(mockedRequest.requestsPerformed, 2)
    }

    func testBuyerCountryTypeUpdate() {
        let mockedRequest = PayPalMessageRequestMock(scenario: .success())

        // init ViewModel with mocked delegate in error scenario
        let viewModel = makePayPalMessageViewModel(
            mockedRequest: mockedRequest
        )

        XCTAssertNil(viewModel.buyerCountry)
        XCTAssertEqual(mockedRequest.requestsPerformed, 1)

        // test the new parameter is being correctly sent
        let newValue = "TEST_COUNTRY"
        viewModel.buyerCountry = newValue
        XCTAssertEqual(viewModel.buyerCountry, newValue)

        viewModel.flushUpdates()

        XCTAssertEqual(mockedRequest.requestsPerformed, 2)
    }

    func testSimpleLogoTypeUpdate() {
        let mockedRequest = PayPalMessageRequestMock(scenario: .success())
        let mockedConfig = PayPalMessageConfig(data: .init(clientID: "testclientid", environment: .live))

        // init ViewModel with mocked delegate in error scenario
        let viewModel = makePayPalMessageViewModel(
            mockedRequest: mockedRequest,
            mockedConfig: mockedConfig
        )

        XCTAssertEqual(viewModel.logoType, mockedConfig.style.logoType)
        XCTAssertEqual(mockedRequest.requestsPerformed, 1)

        // test the new AND different parameter is being correctly sent
        let newValue: PayPalMessageLogoType = .primary
        viewModel.logoType = newValue
        XCTAssertEqual(viewModel.logoType, newValue)

        viewModel.flushUpdates()

        XCTAssertEqual(mockedRequest.requestsPerformed, 2)
    }

    func testSimpleColorUpdate() {
        let mockedRequest = PayPalMessageRequestMock(scenario: .success())
        let mockedConfig = PayPalMessageConfig(data: .init(clientID: "testclientid", environment: .live))

        // init ViewModel with mocked delegate in error scenario
        let viewModel = makePayPalMessageViewModel(
            mockedRequest: mockedRequest,
            mockedConfig: mockedConfig
        )

        XCTAssertEqual(viewModel.color, mockedConfig.style.color)
        XCTAssertEqual(mockedRequest.requestsPerformed, 1)

        // test the new AND different parameter is being correctly sent
        let newValue: PayPalMessageColor = .grayscale
        viewModel.color = newValue
        XCTAssertEqual(viewModel.color, newValue)

        viewModel.flushUpdates()

        // verify a request has NOT been performed as color changes shouldn't trigger them
        XCTAssertEqual(mockedRequest.requestsPerformed, 1)
    }

    func testSimpleAlignmentUpdate() {
        let mockedRequest = PayPalMessageRequestMock(scenario: .success())
        let mockedConfig = PayPalMessageConfig(data: .init(clientID: "testclientid", environment: .live))

        // init ViewModel with mocked delegate in error scenario
        let viewModel = makePayPalMessageViewModel(
            mockedRequest: mockedRequest,
            mockedConfig: mockedConfig
        )

        XCTAssertEqual(viewModel.alignment, mockedConfig.style.textAlignment)
        XCTAssertEqual(mockedRequest.requestsPerformed, 1)

        // test the new AND different parameter is being correctly sent
        let newValue: PayPalMessageTextAlignment = .center
        viewModel.alignment = newValue
        XCTAssertEqual(viewModel.alignment, newValue)

        viewModel.flushUpdates()

        // verify a request has NOT been performed as alignment changes shouldn't trigger them
        XCTAssertEqual(mockedRequest.requestsPerformed, 1)
    }

    // MARK: - Test Duplicated Value Updates

    func testDuplicatedAmountUpdate() {
        let mockedRequest = PayPalMessageRequestMock(scenario: .success())

        // init ViewModel with mocked delegate in error scenario
        let viewModel = makePayPalMessageViewModel(
            mockedRequest: mockedRequest
        )

        XCTAssertNil(viewModel.amount)
        XCTAssertEqual(mockedRequest.requestsPerformed, 1)

        // set random int
        let newAmount = Double.random(in: 0...1000)
        viewModel.amount = newAmount

        viewModel.flushUpdates()

        XCTAssertEqual(mockedRequest.requestsPerformed, 2)

        // set the same amount again, verify another redundant request hasn't been performed
        viewModel.amount = newAmount

        viewModel.flushUpdates()

        XCTAssertEqual(mockedRequest.requestsPerformed, 2)
    }

    // MARK: - Test Update In Progress Cases

    func testUpdateInProgress() {
        // set the requester to return the api call, to simulate a request in progress
        let mockedDelegate = PayPalMessageViewDelegateMock()
        let mockedRequest = PayPalMessageRequestMock(scenario: .neverComplete)

        // init ViewModel with mocked delegate in error scenario
        let viewModel = makePayPalMessageViewModel(
            mockedDelegate: mockedDelegate,
            mockedRequest: mockedRequest
        )

        // test a request is in progress, with no response
        XCTAssertEqual(mockedRequest.requestsPerformed, 1)
        XCTAssertTrue(mockedDelegate.onLoadingCalled)
        XCTAssertFalse(mockedDelegate.onSuccessCalled)
        XCTAssertFalse(mockedDelegate.onErrorCalled)

        // set random int
        let newAmount = Double.random(in: 0...1000)
        viewModel.amount = newAmount

        // verify a request has not been performed and the status is unchanged
        XCTAssertEqual(mockedRequest.requestsPerformed, 1)
        XCTAssertTrue(mockedDelegate.onLoadingCalled)
        XCTAssertFalse(mockedDelegate.onSuccessCalled)
        XCTAssertFalse(mockedDelegate.onErrorCalled)
    }

    func testUpdateInProgressFromParams() {
        let mockedDelegate = PayPalMessageViewDelegateMock()
        let mockedRequest = PayPalMessageRequestMock(scenario: .success())

        // init ViewModel with mocked delegate in error scenario
        let viewModel = makePayPalMessageViewModel(
            mockedDelegate: mockedDelegate,
            mockedRequest: mockedRequest
        )

        // test a request was completed
        XCTAssertEqual(mockedRequest.requestsPerformed, 1)
        XCTAssertTrue(mockedDelegate.onSuccessCalled)

        // configure the requester to not return, so that amount is loading indefinitely
        mockedRequest.scenario = .neverComplete

        // set random int, verify it triggered a request
        let newAmount = Double.random(in: 1...1000)
        viewModel.amount = newAmount

        // test a new, different amount doesn't perform a request
        let newerAmount = newAmount - 1
        viewModel.amount = newerAmount

        viewModel.flushUpdates()

        XCTAssertEqual(mockedRequest.requestsPerformed, 2)
    }

    func testUpdateInProgressFromConfig() {
        let mockedDelegate = PayPalMessageViewDelegateMock()
        let mockedRequest = PayPalMessageRequestMock(scenario: .success())

        // init ViewModel with mocked delegate in error scenario
        let viewModel = makePayPalMessageViewModel(
            mockedDelegate: mockedDelegate,
            mockedRequest: mockedRequest
        )

        // test a request was completed
        XCTAssertEqual(mockedRequest.requestsPerformed, 1)
        XCTAssertTrue(mockedDelegate.onSuccessCalled)

        // configure the requester to not return, so that amount is loading indefinitely
        mockedRequest.scenario = .neverComplete

        // set random int, verify it triggered a request
        let newAmount = Double.random(in: 1...1000)
        viewModel.amount = newAmount

        viewModel.flushUpdates()

        XCTAssertEqual(mockedRequest.requestsPerformed, 2)

        // test a new config being set overrides the update in progress flag and triggers and update
        let newConfig = PayPalMessageConfig(data: .init(clientID: "testclientid", environment: .live))
        viewModel.config = newConfig

        viewModel.flushUpdates()

        XCTAssertEqual(mockedRequest.requestsPerformed, 3)
    }

    // MARK: - Test Merchant Provider

    func testMerchantProviderFailure() {
        let mockedView = PayPalMessageViewMock()
        let mockedDelegate = PayPalMessageViewDelegateMock()
        let mockedMerchantProfileProvider = MerchantProfileProviderMock(scenario: .error)

        // init ViewModel with mocked delegate
        let viewModel = makePayPalMessageViewModel(
            mockedView: mockedView,
            mockedDelegate: mockedDelegate,
            mockedMerchantProfile: mockedMerchantProfileProvider
        )

        // verify everything works correctly, it should NOT affect the outcome
        XCTAssertTrue(mockedView.refreshContentCalled)
        XCTAssertTrue(mockedDelegate.onSuccessCalled)
        XCTAssertTrue(mockedDelegate.onLoadingCalled)
        XCTAssertFalse(mockedDelegate.onErrorCalled)
        XCTAssertNotNil(viewModel.messageParameters)
    }

    private func makePayPalMessageViewModel(
        mockedView: PayPalMessageViewMock = PayPalMessageViewMock(),
        mockedDelegate: PayPalMessageViewDelegateMock = PayPalMessageViewDelegateMock(),
        mockedRequest: PayPalMessageRequestMock = PayPalMessageRequestMock(scenario: .success()),
        mockedMerchantProfile: MerchantProfileProviderMock = MerchantProfileProviderMock(scenario: .success),
        mockedConfig: PayPalMessageConfig = PayPalMessageConfig(data: .init(clientID: "testclientid", environment: .sandbox))
    ) -> PayPalMessageViewModel {
        // Intentionally use different `requester` and `merchantProfileProvider` values from the view model to prevent interferring
        // with mock request counts specifically fired from the view model itself
        let messageView = PayPalMessageView(
            config: mockedConfig,
            requester: PayPalMessageRequestMock(scenario: .success()),
            merchantProfileProvider: MerchantProfileProviderMock(scenario: .success)
        )

        let viewModel = PayPalMessageViewModel(
            config: mockedConfig,
            requester: mockedRequest,
            merchantProfileProvider: mockedMerchantProfile,
            stateDelegate: mockedDelegate,
            eventDelegate: mockedDelegate,
            delegate: mockedView,
            messageView: messageView
        )

        return viewModel
    }
}
// swiftlint:disable:this file_length
