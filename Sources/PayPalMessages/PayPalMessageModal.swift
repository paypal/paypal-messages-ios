import SafariServices
import UIKit
import WebKit

final class PayPalMessageModal: UIViewController, WKUIDelegate {

    typealias Proxy<T> = AnyProxy<PayPalMessageModal, T>

    // MARK: - Properties

    /// Delegate property in charge of announcing rendering and fetching events.
    @Proxy(\.viewModel.stateDelegate)
    var stateDelegate: PayPalMessageModalStateDelegate?

    /// Delegate property in charge of interaction-related events.
    @Proxy(\.viewModel.eventDelegate)
    var eventDelegate: PayPalMessageModalEventDelegate?

    @Proxy(\.viewModel.clientID)
    var clientID: String

    @Proxy(\.viewModel.environment)
    var environment: Environment

    @Proxy(\.viewModel.amount)
    var amount: Double?

    @Proxy(\.viewModel.buyerCountry)
    var buyerCountry: String?

    @Proxy(\.viewModel.offerType)
    var offerType: PayPalMessageOfferType?

    // Content channel
    @Proxy(\.viewModel.channel)
    var channel: String?

    // Location within the application
    @Proxy(\.viewModel.placement)
    var placement: PayPalMessagePlacement?

    // Skip Juno cache
    @Proxy(\.viewModel.ignoreCache)
    var ignoreCache: Bool?

    // Standalone modal
    @Proxy(\.viewModel.integrationIdentifier)
    var integrationIdentifier: String?

    // Modal close button
    var modalCloseButtonConfig: ModalCloseButtonConfig

    // MARK: - Private Properties

    private let viewModel: PayPalMessageModalViewModel
    /// Flag set when modal webview has successfully loaded the first time which will prevent
    /// reloading the webview after reopening the modal after an error state
    private var hasSuccessfullyLoaded = false

    // MARK: - Subviews

    private let webView = WKWebView(frame: .zero)
    private let backgroundView = UIView(frame: .zero)
    private let loadingCircleView = UIImageView(frame: .zero)
    private lazy var closeButton: CloseButton = {
        CloseButton { self.hide() }
    }()

    // MARK: - ViewController Overrides

    // TODO: These should probably be removed as they don't appear supported for formSheet modals
    // Force modal ViewController to portrait orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
    override var shouldAutorotate: Bool { false }

    // MARK: - Initializers

    required init(
        config: PayPalMessageModalConfig,
        stateDelegate: PayPalMessageModalStateDelegate? = nil,
        eventDelegate: PayPalMessageModalEventDelegate? = nil
    ) {
        viewModel = PayPalMessageModalViewModel(
            config: config,
            webView: webView,
            stateDelegate: stateDelegate,
            eventDelegate: eventDelegate
        )
        modalCloseButtonConfig = config.data.modalCloseButton

        super.init(nibName: nil, bundle: nil)
        // Used to pass the modal reference into the delegate functions
        viewModel.modal = self

        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .formSheet
        preferredContentSize = .init(width: 640, height: 900)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {}

    // MARK: - ViewController Lifecycle Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        stateDelegate?.onLoading(self)
        configViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        eventDelegate?.onShow(self)

        guard !hasSuccessfullyLoaded && !webView.isLoading else { return }

        showLoadingScreen(false)

        viewModel.loadModal { result in
            switch result {
            case .success:
                self.hasSuccessfullyLoaded = true
                self.showWebView(true)
                self.stateDelegate?.onSuccess(self)

            case .failure(let error):
                self.stateDelegate?.onError(self, error: error)
                // In the event of an error to retreive the lander details in the webview,
                // we will automatically redirect the user to the Safari browser in order to reattempt the modal lander request.
                // This is due to complaince reasons where terms must be one click away.
                guard let landerUrl = self.webView.url,
                      UIApplication.shared.canOpenURL(landerUrl) else {
                    return
                }
                UIApplication.shared.open(landerUrl, options: [:])
                self.hide()
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        eventDelegate?.onClose(self)
    }

    // MARK: - Config Functions

    private func configViews() {
        // FIXME: Prevent this click from applying to the core modal body
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.hide))
        )

        configBackgroundView()
        configLoadingCircle()
        configWebView()
        configCloseButton()
    }

    private func configBackgroundView() {
        backgroundView.backgroundColor = .white
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.layer.cornerRadius = .modalCornerRadius
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        // Constrainsts to create a max width and centered modal on a rotated iPhone since
        // we do not want the webview to grow larger than the preferredCntentSize.width
        let fullWidthConstraint = backgroundView.widthAnchor.constraint(equalTo: view.widthAnchor)
        let maxWidthConstraint = backgroundView.widthAnchor.constraint(
            lessThanOrEqualToConstant: preferredContentSize.width
        )
        fullWidthConstraint.priority = .defaultLow
        maxWidthConstraint.priority = .defaultHigh

        view.addSubview(backgroundView)

        NSLayoutConstraint.activate(
            [
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                maxWidthConstraint,
                fullWidthConstraint
            ]
        )
    }

    private func configLoadingCircle() {
        loadingCircleView.image = ImageAsset.image(.loadingCircle, CGSize(width: 50, height: 50))
        loadingCircleView.translatesAutoresizingMaskIntoConstraints = false
        loadingCircleView.rotateIndefinitely()

        view.addSubview(loadingCircleView)

        NSLayoutConstraint.activate(
            [
                loadingCircleView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
                loadingCircleView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
            ]
        )
    }

    private func configWebView() {
        // Used to handle opening up new SafariWebViews for external links
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        // Allow the webview page to span the whole screen (outisde the safe areas)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.layer.cornerRadius = .modalCornerRadius
        webView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        webView.layer.masksToBounds = true

        view.addSubview(webView)

        NSLayoutConstraint.activate(
            [
                webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                // Lock the webview to the side edges of the background for rotated iPhone
                webView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
            ]
        )
    }

    private func configCloseButton() {
        let closeButtonHeight = CGFloat(modalCloseButtonConfig.height)
        let closeButtonWidth = CGFloat(modalCloseButtonConfig.width)
        let availableHeight = CGFloat(modalCloseButtonConfig.availableHeight)
        let availableWidth = CGFloat(modalCloseButtonConfig.availableWidth)

        let imageSize = CGSize(width: closeButtonWidth, height: closeButtonHeight)
        if let closeIconImage = closeButton.image(for: .normal) {
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
            closeIconImage.draw(in: CGRect(origin: .zero, size: imageSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            closeButton.setImage(resizedImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        }

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.isAccessibilityElement = true
        closeButton.accessibilityLabel = "PayPal Learn More Modal Close"

        view.addSubview(closeButton)

        NSLayoutConstraint.activate(
            [
                closeButton.topAnchor.constraint(equalTo: backgroundView.topAnchor),
                closeButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
                // Centered within the height of the sticky header
                closeButton.heightAnchor.constraint(equalToConstant: availableHeight),
                closeButton.widthAnchor.constraint(equalToConstant: availableWidth)
            ]
        )
    }

    // MARK: - Screen Change Functions

    private func showLoadingScreen(_ animated: Bool) {
        let getEndState = {
            self.webView.alpha = 0
            self.loadingCircleView.alpha = 1
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: getEndState)
        } else {
            getEndState()
        }
    }

    private func showWebView(_ animated: Bool) {
        let getEndState = {
            self.webView.alpha = 1
            self.closeButton.tintColor = self.modalCloseButtonConfig.color
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: getEndState)
        } else {
            getEndState()
        }
    }

    // MARK: - Modal Control Functions

    func show(config: PayPalMessageModalConfig? = nil) {
        if let safeConfig = config {
            viewModel.setConfig(safeConfig)
        }

        guard let presentingViewController = UIViewController.getPresentingViewController() else {
            log(.error, "Unable to retrieve presenting view controller")
            return
        }

        if presentingViewController == self {
            log(.warn, "Modal is already presenting")
            return
        }

        presentingViewController.present(self, animated: true)
    }

    @objc func hide() {
        dismiss(animated: true)
    }

    func setConfig(_ config: PayPalMessageModalConfig) {
        viewModel.setConfig(config)
    }

    // MARK: - WKUIDelegate Protocol Functions

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        // Open external link clicks in SFSafariViewController
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url {
                let config = SFSafariViewController.Configuration()
                config.barCollapsingEnabled = true

                let safariWebView = SFSafariViewController(url: url, configuration: config)
                safariWebView.modalTransitionStyle = .crossDissolve
                safariWebView.modalPresentationStyle = .formSheet

                self.present(safariWebView, animated: true)
            }
        }

        return nil
    }
}
