import UIKit

protocol PayPalMessageViewModelDelegate: AnyObject {
    /// Requests the delegate to perform a content refresh.
    func refreshContent(messageParameters: PayPalMessageViewParameters?)
}

// swiftlint:disable:next type_body_length
class PayPalMessageViewModel: PayPalMessageModalEventDelegate {

    // MARK: - Properties

    weak var delegate: PayPalMessageViewModelDelegate?
    weak var stateDelegate: PayPalMessageViewStateDelegate?
    weak var eventDelegate: PayPalMessageViewEventDelegate?
    weak var messageView: PayPalMessageView?

    /// This property is not being stored in the ViewModel, it will just update all related properties and compute itself on the getter.
    /// Changing its value will cause the message content being refetched *always*.
    var config: PayPalMessageConfig {
        get { makeConfig() }
        set { updateConfig(newValue) }
    }

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

    /// Changing its value will cause the message content being refetched only if an update is detected.
    var pageType: PayPalMessagePageType? {
        didSet { queueUpdate(from: oldValue, to: pageType) }
    }

    /// Changing its value will cause the message content being refetched only if an update is detected.
    var amount: Double? {
        didSet { queueUpdate(from: oldValue, to: amount) }
    }

    /// Changing its value will cause the message content being refetched only if an update is detected.
    var offerType: PayPalMessageOfferType? {
        didSet { queueUpdate(from: oldValue, to: offerType) }
    }

    /// Changing its value will cause the message content being refetched only if an update is detected.
    var buyerCountry: String? {
        didSet { queueUpdate(from: oldValue, to: buyerCountry) }
    }

    /// Changing its value will cause the message content being refetched only if an update is detected.
    var logoType: PayPalMessageLogoType {
        didSet { queueUpdate(from: oldValue, to: logoType) }
    }

    /// Changing its value will not cause the message content being refetched. It will only trigger an UI update.
    var color: PayPalMessageColor {
        didSet { queueUpdate(from: oldValue, to: color, requiresFetch: false) }
    }

    /// Changing its value will not cause the message content being refetched. It will only trigger an UI update.
    var textAlign: PayPalMessageTextAlign {
        didSet { queueUpdate(from: oldValue, to: textAlign, requiresFetch: false) }
    }

    var ignoreCache: Bool {
        didSet { queueUpdate(from: oldValue, to: ignoreCache) }
    }

    var merchantProfileHash: String?

    /// Update the messageView's interactivity based on the boolean flag. Disabled by default.
    var isMessageViewInteractive = false

    /// returns the parameters for the style and content the message's Attributed String according to the server response
    var messageParameters: PayPalMessageViewParameters? { makeViewParameters() }

    // MARK: - Private Properties
    /// used to avoid property update related requests from being executed when there's a config requesting a fetch
    private var fetchMessageContentPending = false

    /// Config update queue debounce time interval
    private let queueTimeInterval: TimeInterval = 0.001

    /// Timer used to batch update multiple fields via debounce
    private var queuedTimer: Timer?

    /// stores the last message response for the fetch
    private var messageResponse: MessageResponse?

    /// Datetime when the last render occurred
    private var renderStart: Date?

    /// sends the API request
    private let requester: MessageRequestable

    /// helper class to build the parameters for the PayPalMessageView
    private let parameterBuilder = PayPalMessageViewParametersBuilder()

    /// obtains the Merchant Hash and requests it if necessary
    private let merchantProfileProvider: MerchantProfileHashGetable

    /// modal instance attached to the message
    private var modal: PayPalMessageModal?

    /// Tracking logger
    private let logger: AnalyticsLogger

    // MARK: - Inits and Setters

    init(
        config: PayPalMessageConfig,
        requester: MessageRequestable,
        merchantProfileProvider: MerchantProfileHashGetable,
        stateDelegate: PayPalMessageViewStateDelegate? = nil,
        eventDelegate: PayPalMessageViewEventDelegate? = nil,
        delegate: PayPalMessageViewModelDelegate? = nil,
        messageView: PayPalMessageView
    ) {
        self.clientID = config.data.clientID
        self.merchantID = config.data.merchantID
        self.partnerAttributionID = config.data.partnerAttributionID
        self.environment = config.data.environment
        self.amount = config.data.amount
        self.pageType = config.data.pageType
        self.offerType = config.data.offerType
        self.buyerCountry = config.data.buyerCountry
        self.color = config.style.color
        self.logoType = config.style.logoType
        self.textAlign = config.style.textAlign
        self.ignoreCache = config.data.ignoreCache

        self.requester = requester
        self.merchantProfileProvider = merchantProfileProvider
        self.delegate = delegate
        self.eventDelegate = eventDelegate
        self.stateDelegate = stateDelegate
        self.messageView = messageView

        self.logger = AnalyticsLogger(.message(Weak(messageView)))

        queueMessageContentUpdate(fireImmediately: true)
    }

    deinit {}

    private func updateConfig(_ config: PayPalMessageConfig) {
        self.clientID = config.data.clientID
        self.amount = config.data.amount
        self.pageType = config.data.pageType
        self.offerType = config.data.offerType
        self.buyerCountry = config.data.buyerCountry
        self.color = config.style.color
        self.logoType = config.style.logoType
        self.textAlign = config.style.textAlign
        self.ignoreCache = config.data.ignoreCache
    }

    // MARK: - Fetch Methods

    private func queueUpdate<T: Equatable>(
        from oldValue: T,
        to newValue: T,
        requiresFetch: Bool = true
    ) {
        guard oldValue != newValue else { return }

        return queueMessageContentUpdate(requiresFetch: requiresFetch)
    }

    /// When the message is being fetch from a Property update, it considers whether an update is not being currently executed or requested
    private func queueMessageContentUpdate(requiresFetch: Bool = true, fireImmediately: Bool = false) {
        renderStart = Date()

        if requiresFetch {
            self.fetchMessageContentPending = true
        }

        queuedTimer?.invalidate()

        queuedTimer = Timer.scheduledTimer(
            withTimeInterval: queueTimeInterval,
            repeats: false
        ) { _ in
            self.flushUpdates()
        }

        if fireImmediately {
            queuedTimer?.fire()
        }
    }

    // Exposed internally for tests
    func flushUpdates() {
        if fetchMessageContentPending {
            fetchMessageContent()
            fetchMessageContentPending = false
        } else {
            delegate?.refreshContent(messageParameters: self.messageParameters)
        }

        queuedTimer?.invalidate()
    }

    /// Refreshes the Message content only if there's a new amount or logo type set
    private func fetchMessageContent() {
        if let stateDelegate, let messageView {
            stateDelegate.onLoading(messageView)
        }

        merchantProfileProvider.getMerchantProfileHash(
            environment: environment,
            clientID: clientID,
            merchantID: merchantID
        ) { [weak self] profileHash in
            guard let self else { return }

            self.merchantProfileHash = profileHash

            let parameters = self.makeRequestParameters()

            self.requester.fetchMessage(parameters: parameters) { [weak self] result in
                switch result {
                case .success(let response):
                    self?.onMessageRequestReceived(response: response)

                case .failure(let error):
                    self?.onMessageRequestFailed(error: error)
                }
            }
        }
    }

    // MARK: - Fetch Helpers

    private func onMessageRequestFailed(error: PayPalMessageError) {
        messageResponse = nil

        let errorDescription = error.description ?? ""
        self.logger.addEvent(.messageError(
            errorName: "\(error)",
            errorDescription: errorDescription
        ))

        if let stateDelegate, let messageView {
            stateDelegate.onError(messageView, error: error)
        }

        // Disable the tap gesture
        isMessageViewInteractive = false

        delegate?.refreshContent(messageParameters: messageParameters)
    }

    private func onMessageRequestReceived(response: MessageResponse) {
        messageResponse = response
        logger.dynamicData = response.trackingData

        if let stateDelegate, let messageView {
            stateDelegate.onSuccess(messageView)
        }

        delegate?.refreshContent(messageParameters: messageParameters)

        logger.addEvent(.messageRender(
            // Convert to milliseconds
            renderDuration: Int((renderStart?.timeIntervalSinceNow ?? 1 / 1000) * -1000),
            requestDuration: Int((messageResponse?.requestDuration ?? 1 / 1000) * -1000)
        ))

        // Enable the tap gesture
        isMessageViewInteractive = true

        if let modal {
            modal.merchantProfileHash = merchantProfileHash
            modal.setConfig(makeModalConfig())
        }

        log(.debug, "onMessageRequestReceived is \(String(describing: response.defaultMainContent))")
    }

    // MARK: - Message Request Builder

    private func makeRequestParameters() -> MessageRequestParameters {
        .init(
            environment: environment,
            clientID: clientID,
            merchantID: merchantID,
            partnerAttributionID: partnerAttributionID,
            logoType: logoType,
            buyerCountry: buyerCountry,
            pageType: pageType,
            amount: amount,
            offerType: offerType,
            merchantProfileHash: merchantProfileHash,
            ignoreCache: ignoreCache,
            instanceID: logger.instanceId
        )
    }

    // MARK: - Message Styling Builders

    private func makeViewParameters() -> PayPalMessageViewParameters? {
        guard let response = messageResponse else { return nil }

        return parameterBuilder
            .makeParameters(
                message: response.defaultMainContent,
                messageAlternative: response.defaultMainAlternative,
                offerType: response.offerType,
                linkDescription: response.defaultDisclaimer,
                logoPlaceholder: response.logoPlaceholder,
                logoType: logoType,
                payPalAlign: textAlign,
                payPalColor: color,
                productGroup: response.productGroup
            )
    }

    // MARK: - Config Exporter

    private func makeConfig() -> PayPalMessageConfig {
        let config = PayPalMessageConfig(
            data: .init(
                clientID: clientID,
                environment: environment,
                amount: amount,
                pageType: pageType,
                offerType: offerType
            ),
            style: .init(
                logoType: logoType,
                color: color,
                textAlign: textAlign
            )
        )
        config.data.merchantID = merchantID
        config.data.partnerAttributionID = partnerAttributionID
        config.data.buyerCountry = buyerCountry
        config.data.ignoreCache = ignoreCache

        return config
    }

    // MARK: - Modal Methods

    private func makeModalConfig() -> PayPalMessageModalConfig {
        let offerType = PayPalMessageOfferType(rawValue: messageResponse?.offerType.rawValue ?? "")

        var color: UIColor?
        if let colorString = messageResponse?.modalCloseButtonColor {
            color = UIColor(hexString: colorString)
        }

        let modalCloseButton = ModalCloseButtonConfig(
            width: messageResponse?.modalCloseButtonWidth,
            height: messageResponse?.modalCloseButtonHeight,
            availableWidth: messageResponse?.modalCloseButtonAvailWidth,
            availableHeight: messageResponse?.modalCloseButtonAvailHeight,
            color: color,
            colorType: messageResponse?.modalCloseButtonColorType,
            alternativeText: messageResponse?.modalCloseButtonAlternativeText
        )

        let config = PayPalMessageModalConfig(
            data: .init(
                clientID: clientID,
                environment: environment,
                amount: amount,
                pageType: pageType,
                offerType: offerType,
                modalCloseButton: modalCloseButton
            )
        )
        // Partner options
        config.data.merchantID = merchantID
        config.data.partnerAttributionID = partnerAttributionID
        // Non-standard options
        config.data.buyerCountry = buyerCountry
        config.data.modalCloseButton = modalCloseButton
        // Dev options
        config.data.ignoreCache = ignoreCache

        return config
    }

    func showModal() {
        guard isMessageViewInteractive else {
            return
        }

        if let eventDelegate, let messageView {
            eventDelegate.onClick(messageView)
        }

        logger.addEvent(.messageClick(
            linkName: messageResponse?.defaultDisclaimer ?? "Learn More",
            linkSrc: "learn_more"
        ))

        if modal == nil {
            modal = PayPalMessageModal(config: makeModalConfig(), eventDelegate: self)
        }

        if let modal {
            modal.merchantProfileHash = merchantProfileHash
            modal.show()
        }
    }

    // MARK: Modal Event Delegate Functions

    func onClick(_ modal: PayPalMessageModal, data: PayPalMessageModalClickData) {
        if let eventDelegate, let messageView, data.linkName.contains("Apply Now") {
            eventDelegate.onApply(messageView)
        }
    }

    func onCalculate(_ modal: PayPalMessageModal, data: PayPalMessageModalCalculateData) {}
    func onShow(_ modal: PayPalMessageModal) {}
    func onClose(_ modal: PayPalMessageModal) {}
}
// swiftlint:disable:this file_length
