import UIKit
import SwiftUI

public final class PayPalMessageView: UIControl {

    public typealias Proxy<T> = AnyProxy<PayPalMessageView, T>

    // MARK: - Properties

    /// Delegate property in charge of announcing rendering and fetching events.
    @Proxy(\.viewModel.stateDelegate)
    public var stateDelegate: PayPalMessageViewStateDelegate?

    /// Delegate property in charge of interaction-related events.
    @Proxy(\.viewModel.eventDelegate)
    public var eventDelegate: PayPalMessageViewEventDelegate?

    @Proxy(\.viewModel.clientID)
    public var clientID: String

    @Proxy(\.viewModel.merchantID)
    public var merchantID: String?

    @Proxy(\.viewModel.partnerAttributionID)
    public var partnerAttributionID: String?

    @Proxy(\.viewModel.environment)
    public var environment: Environment

    /// Read-write property that holds the displayed amount in the message.
    @Proxy(\.viewModel.amount)
    public var amount: Double?

    /// Read-write property that holds the message placement.
    @Proxy(\.viewModel.placement)
    public var placement: PayPalMessagePlacement?

    /// Read-write property that holds the message offer type.
    @Proxy(\.viewModel.offerType)
    public var offerType: PayPalMessageOfferType?

    /// Read-write property that holds the buyer country.
    @Proxy(\.viewModel.buyerCountry)
    public var buyerCountry: String?

    /// Read-write property that holds the message's logo style.
    @Proxy(\.viewModel.logoType)
    public var logoType: PayPalMessageLogoType

    /// Read-write property that holds the message's color style.
    @Proxy(\.viewModel.color)
    public var color: PayPalMessageColor

    /// Read-write property that holds the message's alignment.
    @Proxy(\.viewModel.alignment)
    public var alignment: PayPalMessageTextAlignment

    /// Read-write property that holds the cache status
    @Proxy(\.viewModel.ignoreCache)
    public var ignoreCache: Bool

    /// Private property that holds the message configuration.
    /// We are using set/get methods for accessing to discourage attempting to edit parts of the config to make changes
    @Proxy(\.viewModel.config)
    private var config: PayPalMessageConfig

    /// Associated ViewModel that performs the update and fetch operations.
    private let viewModel: PayPalMessageViewModel

    // MARK: - Subviews

    private let containerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    private let messageLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsFontForContentSizeCategory = true
        view.numberOfLines = 0
        view.textColor = .clear
        return view
    }()

    // MARK: - Initializers

    /// Initialize a PayPalMessageView instance.
    /// Receives an optional configuration object and delegates.
    /// Performs a fetch with the given information before displaying content.
    ///
    /// - Parameters:
    ///   - config: Config object that holds all of the required parameters for the message view.
    ///   - stateDelegate: Delegate property in charge of announcing rendering and fetching events.
    ///   - eventDelegate: Delegate property in charge of interaction-related events.
    public required init(
        config: PayPalMessageConfig,
        stateDelegate: PayPalMessageViewStateDelegate? = nil,
        eventDelegate: PayPalMessageViewEventDelegate? = nil
    ) {
        self.viewModel = PayPalMessageViewModel(config: config)

        super.init(frame: .zero)

        self.stateDelegate = stateDelegate
        self.eventDelegate = eventDelegate

        configDelegates()
        configViews()
        configTouchTarget()

        // Manually fetch the content instead of immediately as part of the view model constructor
        // so that the delegates and message instance can be passed in before any callbacks fire
        self.viewModel.queueMessageContentUpdate(fireImmediately: true)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {}

    // MARK: - Config getters and setters
    // They are necessary to prevent users from modifying the Config property directly

    /// Sets the config to the desired value.
    /// Changing its value will cause the message content being refetched *always*.
    /// When changing several properties, this is the preferred way of doing so, as it won't suffer from updates being locked due to another one being in progress.
    public func setConfig(_ config: PayPalMessageConfig) {
        self.config = config
    }

    /// Gets the current config object.
    public func getConfig() -> PayPalMessageConfig {
        config
    }

    // MARK: - Lifecycle Events and Properties

    override public var isHighlighted: Bool {
        didSet {
            configHighlight()
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        refreshContent()
    }

    override public var intrinsicContentSize: CGSize {
        messageLabel.intrinsicContentSize
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        return messageLabel.sizeThatFits(size)
    }

    // MARK: - Config Functions

    private func configDelegates() {
        viewModel.stateDelegate = stateDelegate
        viewModel.eventDelegate = eventDelegate
        viewModel.delegate = self
        viewModel.messageView = self
    }

    private func configViews() {
        backgroundColor = .clear
        layer.masksToBounds = true

        containerView.addSubview(messageLabel)
        addSubview(containerView)

        configConstraints()
    }

    private func configConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    private func configTouchTarget() {
        addTarget(self, action: #selector(onTapLearnMore), for: .touchUpInside)
    }

    private func configHighlight() {
        UIView.animate(
            withDuration: Constants.highlightedAnimationDuration,
            delay: 0,
            options: isHighlighted ? .curveEaseOut : .curveEaseIn,
            animations: {
                self.alpha = self.isHighlighted ? Constants.highlightedAlpha : Constants.regularAlpha
            },
            completion: nil
        )
    }

    // MARK: - Actions

    @objc private func onTapLearnMore() {
        viewModel.showModal()
    }
}

// MARK: - PayPalMessageViewModelDelegate Methods

extension PayPalMessageView: PayPalMessageViewModelDelegate {

    /// Recreates the message content from the existing data. **Does not triggers a networking event.**
    func refreshContent() {
        let params = viewModel.messageParameters
        messageLabel.attributedText = PayPalMessageAttributedStringBuilder().makeMessageString(params)
        // Force recalculation for layout
        invalidateIntrinsicContentSize()

        // Update accessibility properties
        self.accessibilityLabel = params?.accessibilityLabel ?? ""
        self.accessibilityTraits = params?.accessibilityTraits ?? .none
        self.isAccessibilityElement = params?.isAccessibilityElement ?? false
    }
}

// MARK: - Accessibility Helpers

extension PayPalMessageView {

    /// Called when the accessibility or orientation traits have changed. Reloads the content accordingly.
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        refreshContent()
    }
}

// MARK: - Constants

extension PayPalMessageView {

    private enum Constants {
        static let highlightedAnimationDuration: CGFloat = 1.0
        static let highlightedAlpha: CGFloat = 0.75
        static let regularAlpha: CGFloat = 1.0
        static let fontSize: CGFloat = 14.0
    }
}

// MARK: - SwiftUI Compatibility

@available(iOS 13.0, *)
extension PayPalMessageView {

    public struct Representable: UIViewRepresentable {

        private let config: PayPalMessageConfig
        private let stateDelegate: PayPalMessageViewStateDelegate?
        private let eventDelegate: PayPalMessageViewEventDelegate?

        public init(
            config: PayPalMessageConfig,
            stateDelegate: PayPalMessageViewStateDelegate? = nil,
            eventDelegate: PayPalMessageViewEventDelegate? = nil
        ) {
            self.config = config
            self.stateDelegate = stateDelegate
            self.eventDelegate = eventDelegate
        }

        public func makeUIView(context: Context) -> PayPalMessageView {
            PayPalMessageView(
                config: config,
                stateDelegate: stateDelegate,
                eventDelegate: eventDelegate
            )
        }

        public func updateUIView(_ view: PayPalMessageView, context: Context) {
            view.stateDelegate = stateDelegate
            view.eventDelegate = eventDelegate
            view.setConfig(config)
        }
    }
}
