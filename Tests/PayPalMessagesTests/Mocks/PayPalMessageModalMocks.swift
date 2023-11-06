@testable import PayPalMessages
import WebKit

class PayPalMessageModalStateDelegateMock: PayPalMessageModalStateDelegate {

    var onErrorCalled = false
    var onLoadingCalled = false
    var onSuccessCalled = false

    func onError(_ modal: PayPalMessageModal, error: PayPalMessageError) {
        onErrorCalled = true
    }

    func onLoading(_ modal: PayPalMessageModal) {
        onLoadingCalled = true
    }

    func onSuccess(_ modal: PayPalMessageModal) {
        onSuccessCalled = true
    }
}

class PayPalMessageModalEventDelegateMock: PayPalMessageModalEventDelegate {

    var onClickCalled = false
    var onClickData: PayPalMessageModalClickData?
    var onCalculateCalled = false
    var onCalculateData: PayPalMessageModalCalculateData?
    var onShowCalled = false
    var onCloseCalled = false

    func onClick(_ modal: PayPalMessageModal, data: PayPalMessageModalClickData) {
        onClickCalled = true
        onClickData = data
    }

    func onCalculate(_ modal: PayPalMessageModal, data: PayPalMessageModalCalculateData) {
        onCalculateCalled = true
        onCalculateData = data
    }

    func onShow(_ modal: PayPalMessageModal) {
        onShowCalled = true
    }

    func onClose(_ modal: PayPalMessageModal) {
        onCloseCalled = true
    }
}

class PayPalMessageModalWebViewMock: WKWebView {

    var loadCalled = false
    var loadRequest: URLRequest?

    var evaluateJavaScriptCalled = false
    var evaluateJavaScriptString: String?
    var evaluateJavaScriptCallback: ((_ javascriptString: String) -> Void)?

    override func load(_ request: URLRequest) -> WKNavigation? {
        loadCalled = true
        loadRequest = request

        return nil
    }

    override func evaluateJavaScript(
        _ javaScriptString: String,
        completionHandler: ((Any?, Error?) -> Void)? = nil
    ) {
        evaluateJavaScriptCalled = true
        evaluateJavaScriptString = javaScriptString
        evaluateJavaScriptCallback?(javaScriptString)
    }
}

class MockNavigationResponse: WKNavigationResponse {

    override var response: URLResponse {
        HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: debugId != nil ? ["Paypal-Debug-Id": debugId ?? ""] : nil
        )! // swiftlint:disable:this force_unwrapping
    }

    var statusCode: Int = 200
    var debugId: String?
    var url = URL(string: "https://www.paypal.com")! // swiftlint:disable:this force_unwrapping

    convenience init(statusCode: Int, debugId: String? = nil, url: URL? = nil) {
        self.init()
        self.statusCode = statusCode
        self.debugId = debugId
        self.url = url ?? self.url
    }
}

class MockScriptMessage: WKScriptMessage {

    override var body: Any { _body }
    private var _body: Any

    init(_ body: Any) {
        _body = body

        super.init()
    }
}
