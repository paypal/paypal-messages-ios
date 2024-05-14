import WebKit

fileprivate final class InputAccessoryHackHelper: NSObject {
    @objc var inputAccessoryView: AnyObject? { return nil }
}

extension WKWebView {
    func hack_removeInputAccessory() {
        print("s")
        guard let target = scrollView.subviews.first(where: {
            String(describing: type(of: $0)).hasPrefix("WKContent")
        }), let superclass = target.superclass else {
            return
        }

        let noInputAccessoryViewClassName = "\(superclass)_NoInputAccessoryView"
        var newClass: AnyClass? = NSClassFromString(noInputAccessoryViewClassName)

        if newClass == nil, let targetClass = object_getClass(target), let classNameCString = noInputAccessoryViewClassName.cString(using: .ascii) {
            newClass = objc_allocateClassPair(targetClass, classNameCString, 0)

            if let newClass = newClass {
                objc_registerClassPair(newClass)
            }
        }

        guard let noInputAccessoryClass = newClass, let originalMethod = class_getInstanceMethod(InputAccessoryHackHelper.self, #selector(getter: InputAccessoryHackHelper.inputAccessoryView)) else {
            return
        }
        class_addMethod(noInputAccessoryClass.self, #selector(getter: InputAccessoryHackHelper.inputAccessoryView), method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        object_setClass(target, noInputAccessoryClass)
    }
}

class PayPalMessageModalViewModel: NSObject, WKNavigationDelegate, WKScriptMessageHandler {

    // MARK: - Properties

    /// Delegate property in charge of announcing rendering and fetching events.
    weak var stateDelegate: PayPalMessageModalStateDelegate?
    /// Delegate property in charge of interaction-related events.
    weak var eventDelegate: PayPalMessageModalEventDelegate?
    /// modal view controller passed into logger and delegate functions
    weak var modal: PayPalMessageModal?

    var environment: Environment {
        didSet { queueUpdate(from: oldValue, to: environment) }
    }

    var clientID: String {
        didSet { queueUpdate(from: oldValue, to: clientID) }
    }

    var merchantID: String? {
        didSet { queueUpdate(from: oldValue, to: merchantID) }
    }

    var partnerAttributionID: String? {
        didSet { queueUpdate(from: oldValue, to: partnerAttributionID) }
    }

    var amount: Double? {
        didSet { queueUpdate(from: oldValue, to: amount) }
    }
    var buyerCountry: String? {
        didSet { queueUpdate(from: oldValue, to: buyerCountry) }
    }
    var offerType: PayPalMessageOfferType? {
        didSet { queueUpdate(from: oldValue, to: offerType) }
    }
    // Content channel
    var channel: String {
        didSet { queueUpdate(from: oldValue, to: channel) }
    }
    // Location within the application
    var pageType: PayPalMessagePageType? {
        didSet { queueUpdate(from: oldValue, to: pageType) }
    }
    // Skip Juno cache
    var ignoreCache: Bool? { // swiftlint:disable:this discouraged_optional_boolean
        didSet { queueUpdate(from: oldValue, to: ignoreCache) }
    }


    // Standalone modal
    var integrationIdentifier: String?

    var merchantProfileHash: String?


    // MARK: - Computed Private Properties

    private var url: URL? {
        let queryParams: [String: String?] = [
            "env": environment.rawValue,
            "client_id": clientID,
            "merchant_id": merchantID,
            "partner_attribution_id": partnerAttributionID,
            "amount": amount?.description,
            "buyer_country": buyerCountry,
            "offer": offerType?.rawValue,
            "channel": channel,
            "page_type": pageType?.rawValue,
            "version": BuildInfo.version,
            "integration_type": BuildInfo.integrationType,
            "integration_identifier": integrationIdentifier,
            "ignore_cache": ignoreCache?.description,
            "integration_version": AnalyticsLogger.integrationVersion,
            "features": "native-modal"
        ].filter {
            guard let value = $0.value else { return false }

            return !value.isEmpty && value.lowercased() != "false"
        }

        return environment.url(.modal, queryParams)
    }

    // MARK: - Private Typealias

    typealias LoadCompletionHandler = (Result<Void, PayPalMessageError>) -> Void

    // MARK: - Private Properties

    /// Config update queue debounce time interval
    private let queueTimeInterval: TimeInterval = 0.01
    private let webView: WKWebView
    /// Timer used to batch update multiple fields via debounce
    private var queuedTimer: Timer?
    /// Completion callback called after webview has loaded and is ready to be viewed
    private var loadCompletionHandler: LoadCompletionHandler?

    let logger: AnalyticsLogger

    // MARK: - Initializers

    init(
        config: PayPalMessageModalConfig,
        webView: WKWebView,
        stateDelegate: PayPalMessageModalStateDelegate? = nil,
        eventDelegate: PayPalMessageModalEventDelegate? = nil,
        modal: PayPalMessageModal
    ) {
        environment = config.data.environment
        clientID = config.data.clientID
        merchantID = config.data.merchantID
        partnerAttributionID = config.data.partnerAttributionID
        amount = config.data.amount
        offerType = config.data.offerType
        buyerCountry = config.data.buyerCountry
        channel = config.data.channel
        pageType = config.data.pageType
        ignoreCache = config.data.ignoreCache

        self.webView = webView
        self.stateDelegate = stateDelegate
        self.eventDelegate = eventDelegate
        self.modal = modal

        self.logger = AnalyticsLogger(.modal(Weak(modal)))

        super.init()

        // Used to remove input accessory bar (next/previous/Done)
        webView.hack_removeInputAccessory()
        // Used to hook into navigation lifecycle events
        webView.navigationDelegate = self
        // Used to communicate inside the webview
        webView.configuration.userContentController.add(self, name: "paypalMessageModalCallbackHandler")
    }

    deinit {}

    /// Update the modal config options
    func setConfig(_ config: PayPalMessageModalConfig) {
        environment = config.data.environment
        clientID = config.data.clientID
        merchantID = config.data.merchantID
        partnerAttributionID = config.data.partnerAttributionID
        amount = config.data.amount
        offerType = config.data.offerType
        buyerCountry = config.data.buyerCountry
        channel = config.data.channel
        pageType = config.data.pageType
        ignoreCache = config.data.ignoreCache
    }

    func makeConfig() -> PayPalMessageModalConfig {
        let config = PayPalMessageModalConfig(data: .init(
            clientID: self.clientID,
            environment: self.environment,
            amount: self.amount,
            pageType: self.pageType,
            offerType: self.offerType
        ))

        config.data.merchantID = merchantID
        config.data.partnerAttributionID = partnerAttributionID
        config.data.buyerCountry = buyerCountry
        config.data.channel = channel
        config.data.ignoreCache = ignoreCache

        return config
    }

    /// Load the webview modal URL based on the current config options
    func loadModal(_ completionHandler: LoadCompletionHandler?) {
        guard let safeUrl = url else { return }

        loadCompletionHandler = completionHandler

        log(.debug, "Load modal webview URL: \(safeUrl)", for: environment)

        webView.load(URLRequest(url: safeUrl))
    }

    // MARK: - WebView Communication
    private func queueUpdate<T: Equatable>(from oldValue: T, to newValue: T) {
        guard oldValue != newValue else { return }

        updateWebViewProps()
    }

    private func updateWebViewProps() {
        guard !webView.isLoading else { return }

        queuedTimer?.invalidate()

        queuedTimer = Timer.scheduledTimer(
            withTimeInterval: queueTimeInterval,
            repeats: false
        ) { _ in
            self.flushUpdates()
        }
    }

    // Exposed internally for tests
    func flushUpdates() {
        guard let jsonData = try? JSONEncoder().encode(self.makeConfig()),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }

        log(.debug, "Update props: \(jsonString)", for: environment)

        self.webView.evaluateJavaScript(
            "window.actions.updateProps(\(jsonString))"
        ) { _, _ in
            // TODO: Does the JS error text get returned here?
        }

        queuedTimer?.invalidate()
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard let bodyString = message.body as? String,
              let bodyData = bodyString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any],
              let eventName = json["name"] as? String,
              var eventArgs = json["args"] as? [[String: Any]] else {
            log(.error, "Unable to parse modal event body", for: environment)
            return
        }

        log(.debug, "Modal event: [\(eventName)] \(eventArgs)", for: environment)

        guard !eventArgs.isEmpty else { return }

        // If __shared__ exists, remove it from the individual event and include it as
        // part of the component level logger dynamic data
        if let shared = eventArgs[0].removeValue(forKey: "__shared__") as? [String: Any] {
            for (key, value) in shared {
                logger.dynamicData[key] = AnyCodable(value)
            }
        }

        var encodableDict: [String: AnyCodable] = [:]
        for (key, value) in eventArgs[0] {
            encodableDict[key] = AnyCodable(value)
        }
        logger.addEvent(.dynamic(data: encodableDict))

        switch eventName {
        case "onCalculate":
            if let modal, let amount = eventArgs[0]["amount"] as? Double {
                eventDelegate?.onCalculate(modal, data: .init(value: amount))
            }

        case "onClick":
            if let modal,
               let src = eventArgs[0]["page_view_link_source"] as? String,
               let linkName = eventArgs[0]["page_view_link_name"] as? String {
                eventDelegate?.onClick(modal, data: .init(linkName: linkName, linkSrc: src))
            }

        default:
            break
        }
    }

    // MARK: - WebView Protocol Functions

    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        switch environment {
        case .live, .sandbox:
            completionHandler(.performDefaultHandling, nil)
        case .develop:
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                return completionHandler(.performDefaultHandling, nil)
            }
            // Credential override methods warn when run on the main thread
            DispatchQueue.global(qos: .background).async {
                // Allow webview to connect to webpage using self-signed HTTPS certs
                let exceptions = SecTrustCopyExceptions(serverTrust)
                SecTrustSetExceptions(serverTrust, exceptions)

                completionHandler(.useCredential, URLCredential(trust: serverTrust))
            }
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        guard let response = navigationResponse.response as? HTTPURLResponse else {
            loadCompletionHandler?(.failure(.invalidResponse()))
            return decisionHandler(.cancel)
        }

        guard response.statusCode == 200 else {
            loadCompletionHandler?(.failure(
                .invalidResponse(paypalDebugID: response.paypalDebugID)
            ))
            return decisionHandler(.cancel)
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        loadCompletionHandler?(.success(()))
    }
}

