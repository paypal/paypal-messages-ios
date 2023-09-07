@testable import PayPalMessages
import WebKit
import XCTest

final class PayPalMessageModalViewModelTests: XCTestCase {

    let navigation = WKNavigation()
    let mockSender = LogSenderMock()

    override func setUp() {
        super.setUp()

        // Inject mock sender to intercept log requests
        let logger = Logger.get(for: "test", in: .live)
        logger.sender = mockSender
    }

    func testInitialSetup() {
        let config = PayPalMessageModalConfig(
            data: .init(
                clientID: "testclientid",
                environment: .live,
                amount: 100.0,
                currency: "USD",
                placement: .home,
                offerType: .payLaterLongTerm
            )
        )
        config.data.buyerCountry = "US"
        config.data.channel = "TEST"
        config.data.devTouchpoint = true
        config.data.ignoreCache = true
        config.data.stageTag = "test"

        let (viewModel, webView, stateDelegate, eventDelegate) = makePayPalMessageModalViewModel(
            config: config
        )

        XCTAssertEqual(viewModel.clientID, "testclientid")
        XCTAssertEqual(viewModel.amount, 100.0)
        XCTAssertEqual(viewModel.currency, "USD")
        XCTAssertEqual(viewModel.placement, .home)
        XCTAssertEqual(viewModel.offerType, .payLaterLongTerm)
        XCTAssertEqual(viewModel.buyerCountry, "US")
        XCTAssertEqual(viewModel.channel, "TEST")
        XCTAssertEqual(viewModel.stageTag, "test")
        XCTAssertTrue(viewModel.devTouchpoint ?? false)
        XCTAssertTrue(viewModel.ignoreCache ?? false)
        XCTAssertEqual(viewModel.environment, .live)

        XCTAssertIdentical(viewModel.stateDelegate, stateDelegate)
        XCTAssertIdentical(viewModel.eventDelegate, eventDelegate)

        XCTAssertIdentical(webView.navigationDelegate, viewModel)
    }

    func testUpdateConfig() {
        let expectation = expectation(description: "Evaluate JavaScript Callback")
        let (viewModel, webView, _, _) = makePayPalMessageModalViewModel()
        webView.evaluateJavaScriptCallback = { _ in expectation.fulfill() }

        XCTAssertNil(viewModel.amount)
        XCTAssertNil(viewModel.offerType)

        viewModel.setConfig(.init(
            data: .init(
                clientID: "testclientid",
                environment: .live,
                amount: 200.0,
                offerType: .payLaterShortTerm
            )
        ))

        XCTAssertEqual(viewModel.amount, 200.0)
        XCTAssertEqual(viewModel.offerType, .payLaterShortTerm)

        XCTAssertFalse(webView.evaluateJavaScriptCalled)

        waitForExpectations(timeout: 0.5)

        XCTAssertTrue(webView.evaluateJavaScriptCalled)
        XCTAssertEqual(
            webView.evaluateJavaScriptString,
            "window.actions.updateProps({\"client_id\":\"testclientid\",\"amount\":200,\"offer\":\"PAY_LATER_SHORT_TERM\"})"
        )
    }

    func testUpdateIndividualProperties() {
        let expectation = expectation(description: "Evaluate JavaScript Callback")
        let (viewModel, webView, _, _) = makePayPalMessageModalViewModel()
        webView.evaluateJavaScriptCallback = { _ in expectation.fulfill() }

        XCTAssertNil(viewModel.amount)
        XCTAssertNil(viewModel.offerType)

        viewModel.amount = 300.0
        viewModel.offerType = .payPalCreditNoInterest

        XCTAssertEqual(viewModel.amount, 300.0)
        XCTAssertEqual(viewModel.offerType, .payPalCreditNoInterest)

        XCTAssertFalse(webView.evaluateJavaScriptCalled)

        waitForExpectations(timeout: 0.5)

        XCTAssertTrue(webView.evaluateJavaScriptCalled)
        XCTAssertEqual(
            webView.evaluateJavaScriptString,
            "window.actions.updateProps({\"client_id\":\"testclientid\",\"amount\":300,\"offer\":\"PAYPAL_CREDIT_NO_INTEREST\"})"
        )
    }

    func testModalLoadSuccess() {
        let (viewModel, webView, _, _) = makePayPalMessageModalViewModel(
            config: .init(
                data: .init(
                    clientID: "testclientid",
                    environment: .live,
                    amount: 500.0
                )
            )
        )
        var loadResult: Result<Void, PayPalMessageError>?

        XCTAssertNil(loadResult)
        XCTAssertFalse(webView.loadCalled)

        viewModel.loadModal { result in
            loadResult = result
        }

        XCTAssertNil(loadResult)
        XCTAssertTrue(webView.loadCalled)
        XCTAssertEqual(webView.loadRequest?.url?.host, "www.paypal.com")
        XCTAssertEqual(webView.loadRequest?.url?.path, "/credit-presentment/lander/modal")
        XCTAssertTrue(webView.loadRequest?.url?.query?.contains("500") ?? false)

        let response = MockNavigationResponse(statusCode: 200, debugId: "123abc")
        var responsePolicy: WKNavigationResponsePolicy?

        viewModel.webView(webView, decidePolicyFor: response) { policy in
            responsePolicy = policy
        }

        XCTAssertNotNil(responsePolicy)
        XCTAssertEqual(responsePolicy, .allow)

        XCTAssertNil(loadResult)

        viewModel.webView(webView, didFinish: navigation)

        XCTAssertNotNil(loadResult)

        if case .failure = loadResult {
            XCTFail("Expected loadResult to be .success")
        }
    }

    func testModalLoadFailure() {
        let (viewModel, webView, _, _) = makePayPalMessageModalViewModel()
        var loadResult: Result<Void, PayPalMessageError>?

        XCTAssertFalse(webView.loadCalled)
        XCTAssertNil(loadResult)

        viewModel.loadModal { result in
            loadResult = result
        }

        XCTAssertTrue(webView.loadCalled)
        XCTAssertNil(loadResult)

        let response = MockNavigationResponse(statusCode: 500, debugId: "123abc")
        var responsePolicy: WKNavigationResponsePolicy?

        viewModel.webView(webView, decidePolicyFor: response) { policy in
            responsePolicy = policy
        }

        XCTAssertNotNil(responsePolicy)
        XCTAssertEqual(responsePolicy, .cancel)

        XCTAssertNotNil(loadResult)

        guard let loadResult else {
            return XCTFail("loadResult is nil")
        }

        switch loadResult {
        case .success:
            XCTFail("Expected loadResult to be .failure")

        case .failure(let error):
            XCTAssertEqual(error, .invalidResponse(paypalDebugID: "123abc"))
        }
    }

    func testCallsEventDelegate() {
        let (viewModel, _, _, eventDelegate) = makePayPalMessageModalViewModel()
        let userContentController = WKUserContentController()

        viewModel.userContentController(
            userContentController,
            didReceive: MockScriptMessage(
                """
                {
                    "name": "onCalculate",
                    "args": []
                }
                """
            )
        )

        XCTAssertFalse(eventDelegate.onCalculateCalled)

        viewModel.userContentController(
            userContentController,
            didReceive: MockScriptMessage(
                """
                {
                    "name": "onCalculate",
                    "args": [
                        {
                            "amount": 100.50
                        }
                    ]
                }
                """
            )
        )

        XCTAssertTrue(eventDelegate.onCalculateCalled)
        XCTAssertEqual(eventDelegate.onCalculateData?.value, 100.5)

        viewModel.userContentController(
            userContentController,
            didReceive: MockScriptMessage(
                """
                {
                    "name": "onClick",
                    "args": [
                        {
                            "link_name": "Apply Now Link",
                            "link_src": "Apply Now Src"
                        }
                    ]
                }
                """
            )
        )

        XCTAssertTrue(eventDelegate.onClickCalled)
        XCTAssertEqual(eventDelegate.onClickData?.linkName, "Apply Now Link")
        XCTAssertEqual(eventDelegate.onClickData?.linkSrc, "Apply Now Src")
    }

    private func makePayPalMessageModalViewModel(
        config: PayPalMessageModalConfig = PayPalMessageModalConfig(data: .init(clientID: "testclientid", environment: .live))
    ) -> ( // swiftlint:disable:this large_tuple
        PayPalMessageModalViewModel,
        PayPalMessageModalWebViewMock,
        PayPalMessageModalStateDelegateMock,
        PayPalMessageModalEventDelegateMock
    ) {
        let webView = PayPalMessageModalWebViewMock()
        let stateDelegate = PayPalMessageModalStateDelegateMock()
        let eventDelegate = PayPalMessageModalEventDelegateMock()
        let modal = PayPalMessageModal(
            config: config,
            stateDelegate: stateDelegate,
            eventDelegate: eventDelegate
        )
        let viewModel = PayPalMessageModalViewModel(
            config: config,
            webView: webView,
            stateDelegate: stateDelegate,
            eventDelegate: eventDelegate
        )
        viewModel.modal = modal

        return (
            viewModel,
            webView,
            stateDelegate,
            eventDelegate
        )
    }
}
