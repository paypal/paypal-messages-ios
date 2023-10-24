import WebKit

class PayPalMessageModalViewModel: NSObject, WKNavigationDelegate, WKScriptMessageHandler {

    // MARK: - Properties

    /// Delegate property in charge of announcing rendering and fetching events.
    weak var stateDelegate: PayPalMessageModalStateDelegate?
    /// Delegate property in charge of interaction-related events.
    weak var eventDelegate: PayPalMessageModalEventDelegate?

    var modal: PayPalMessageModal?

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
    var currency: String? {
        didSet { queueUpdate(from: oldValue, to: currency) }
    }
    var buyerCountry: String? {
        didSet { queueUpdate(from: oldValue, to: buyerCountry) }
    }
    var offerType: PayPalMessageOfferType? {
        didSet { queueUpdate(from: oldValue, to: offerType) }
    }
    // Content channel
    var channel: String? {
        didSet { queueUpdate(from: oldValue, to: channel) }
    }
    // Location within the application
    var placement: PayPalMessagePlacement? {
        didSet { queueUpdate(from: oldValue, to: placement) }
    }
    // Skip Juno cache
    var ignoreCache: Bool? { // swiftlint:disable:this discouraged_optional_boolean
        didSet { queueUpdate(from: oldValue, to: ignoreCache) }
    }
    // Development content
    var devTouchpoint: Bool? { // swiftlint:disable:this discouraged_optional_boolean
        didSet { queueUpdate(from: oldValue, to: devTouchpoint) }
    }
    // Custom development stage modal bundle
    var stageTag: String? {
        didSet { queueUpdate(from: oldValue, to: stageTag) }
    }
    // Standalone modal
    var integrationIdentifier: String?

    // MARK: - Computed Private Properties

    private var url: URL? {
        let queryParams: [String: String?] = [
            "env": environment.rawValue,
            "client_id": clientID,
            "merchant_id": merchantID,
            "partner_attribution_id": partnerAttributionID,
            "amount": amount?.description,
            "currency": currency,
            "buyer_country": buyerCountry,
            "offer": offerType?.rawValue,
            "channel": channel,
            "placement": placement?.rawValue,
            "integration_type": integrationType,
            "integration_identifier": integrationIdentifier,
            // Dev options
            "ignore_cache": ignoreCache?.description,
            "dev_touchpoint": devTouchpoint?.description,
            "stage_tag": stageTag,
            "integration_version": Logger.integrationVersion,
            "device_id": Logger.deviceID,
            "session_id": Logger.sessionID,
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

    private let integrationType: String = "NATIVE_IOS"
    /// Config update queue debounce time interval
    private let queueTimeInterval: TimeInterval = 0.01
    private let webView: WKWebView
    /// Timer used to batch update multiple fields via debounce
    private var queuedTimer: Timer?
    /// Completion callback called after webview has loaded and is ready to be viewed
    private var loadCompletionHandler: LoadCompletionHandler?

    let logger: ComponentLogger

    // MARK: - Initializers

    init(
        config: PayPalMessageModalConfig,
        webView: WKWebView,
        stateDelegate: PayPalMessageModalStateDelegate? = nil,
        eventDelegate: PayPalMessageModalEventDelegate? = nil
    ) {
        environment = config.data.environment
        clientID = config.data.clientID
        merchantID = config.data.merchantID
        partnerAttributionID = config.data.partnerAttributionID
        amount = config.data.amount
        currency = config.data.currency
        offerType = config.data.offerType
        buyerCountry = config.data.buyerCountry
        channel = config.data.channel
        placement = config.data.placement
        ignoreCache = config.data.ignoreCache
        devTouchpoint = config.data.devTouchpoint
        stageTag = config.data.stageTag

        self.webView = webView
        self.stateDelegate = stateDelegate
        self.eventDelegate = eventDelegate

        self.logger = Logger.createModalLogger(
            environment: environment,
            clientID: clientID,
            merchantID: merchantID,
            partnerAttributionID: partnerAttributionID,
            offerType: offerType,
            amount: amount,
            placement: placement,
            buyerCountryCode: buyerCountry
        )

        super.init()

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
        currency = config.data.currency
        offerType = config.data.offerType
        buyerCountry = config.data.buyerCountry
        channel = config.data.channel
        placement = config.data.placement
        ignoreCache = config.data.ignoreCache
        devTouchpoint = config.data.devTouchpoint
        stageTag = config.data.stageTag
    }

    func makeConfig() -> PayPalMessageModalConfig {
        let config = PayPalMessageModalConfig(data: .init(
            clientID: self.clientID,
            environment: self.environment,
            amount: self.amount,
            currency: self.currency,
            placement: self.placement,
            offerType: self.offerType
        ))

        config.data.merchantID = merchantID
        config.data.partnerAttributionID = partnerAttributionID
        config.data.buyerCountry = buyerCountry
        config.data.channel = channel
        config.data.stageTag = stageTag
        config.data.devTouchpoint = devTouchpoint
        config.data.ignoreCache = ignoreCache

        return config
    }

    /// Load the webview modal URL based on the current config options
    func loadModal(_ completionHandler: LoadCompletionHandler?) {
        guard let safeUrl = url else { return }

        loadCompletionHandler = completionHandler

        log(.info, "Load modal webview URL: \(safeUrl)")

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
            guard let jsonData = try? JSONEncoder().encode(self.makeConfig()),
                  let jsonString = String(data: jsonData, encoding: .utf8) else { return }

            log(.info, "Update props: \(jsonString)")

            self.webView.evaluateJavaScript(
                "window.actions.updateProps(\(jsonString))"
            ) { _, _ in
                // TODO: Does the JS error text get returned here?
            }
        }
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
            log(.error, "Unable to parse modal event body")
            return
        }

        log(.info, "Modal event: [\(eventName)] \(eventArgs)")

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
            if let amount = eventArgs[0]["amount"] as? Double,
               let modal = modal {
                eventDelegate?.onCalculate(modal, data: .init(value: amount))
            }

        case "onClick":
            if let src = eventArgs[0]["link_src"] as? String,
               let linkName = eventArgs[0]["link_name"] as? String,
               let modal {
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
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return completionHandler(.useCredential, nil)
        }
        switch environment {
        case .local, .stage:
            // Allow webview to connect to webpage using invalid local HTTPS certs
            let exceptions = SecTrustCopyExceptions(serverTrust)
            SecTrustSetExceptions(serverTrust, exceptions)
        default: break
        }
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
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
