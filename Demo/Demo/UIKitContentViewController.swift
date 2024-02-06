import Foundation
import UIKit
import PayPalMessages

// swiftlint:disable:next type_body_length
class UIKitContentViewController: UIViewController {

    // MARK: - Views
    /// Scroll view which will auto size
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        return scrollView
    }()

    lazy var paypalMessage: PayPalMessageView = {
        PayPalMessageView(config: defaultMessageConfig, stateDelegate: self, eventDelegate: self)
    }()

    lazy var messageConfigHeaderLabel = getLabel(text: "Message Configuration", font: UIFont.systemFont(ofSize: 20, weight: .semibold))

    lazy var clientIDLabel = getLabel(text: "Client ID")

    lazy var styleOptionsLabel = getLabel(text: "Style Options")

    lazy var offerTypeLabel = getLabel(text: "Offer Type")

    lazy var amountLabel = getLabel(text: "Amount")

    lazy var buyerCountryLabel = getLabel(text: "Buyer Country")

    lazy var ignoreCacheLabel = getLabel(text: "Ignore Cache")

    lazy var logoTypePicker: UISegmentedControl = getSegmentedControl(
        action: #selector(updatePayPalMessageMessage),
        forType: PayPalMessageLogoType.self
    )

    lazy var colorTypePicker: UISegmentedControl = getSegmentedControl(
        action: #selector(updatePayPalMessageMessage),
        forType: PayPalMessageColor.self
    )

    lazy var alignmentTypePicker: UISegmentedControl = getSegmentedControl(
        action: #selector(updatePayPalMessageMessage),
        forType: PayPalMessageTextAlign.self
    )

    lazy var offerTypePicker: UISegmentedControl = getSegmentedControl(
        action: #selector(updatePayPalMessageMessage),
        forType: PayPalMessageOfferType.self
    )

    lazy var amountTextField: UITextField = getTextField(
        action: #selector(updatePayPalMessageMessage),
        keyboardType: .numberPad,
        autoCapitalizationType: .none
    )

    lazy var buyerCountryField: UITextField = getTextField(
        action: #selector(updatePayPalMessageMessage),
        keyboardType: .alphabet,
        autoCapitalizationType: .allCharacters
    )

    lazy var ignoreCacheSwitch: UISwitch = getSwitch(
        isOn: defaultMessageConfig.data.ignoreCache,
        action: #selector(updatePayPalMessageMessage)
    )

    lazy var clientIDField: UITextField = getTextField(
        action: #selector(updatePayPalMessageMessage),
        keyboardType: .default,
        autoCapitalizationType: .none,
        text: defaultMessageConfig.data.clientID
    )

    lazy var statusTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.textColor = .lightGray
        textView.textAlignment = .right
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = true
        return textView
    }()

    lazy var resetButton: UIButton = {
        getButton(title: "Reset", action: #selector(resetConfig(_:)))
    }()

    lazy var stackView: UIStackView = {
        paypalMessage.translatesAutoresizingMaskIntoConstraints = false

        return getStackView(
            subviews: [
                messageConfigHeaderLabel,

                getStackView(
                    subviews: [
                        clientIDLabel,
                        clientIDField
                    ],
                    axis: .horizontal
                ),

                styleOptionsLabel,
                logoTypePicker,
                colorTypePicker,
                alignmentTypePicker,

                offerTypeLabel,
                offerTypePicker,

                getStackView(
                    subviews: [
                        amountLabel,
                        amountTextField
                    ],
                    axis: .horizontal
                ),
                getStackView(
                    subviews: [
                        buyerCountryLabel,
                        buyerCountryField
                    ],
                    axis: .horizontal
                ),
                getStackView(
                    subviews: [
                        ignoreCacheSwitch,
                        ignoreCacheLabel
                    ],
                    axis: .horizontal
                ),
                getSeparator(),
                paypalMessage
            ],
            padding: 12
        )
    }()

    // Debounce timer used to slightly delay updating the message to allow typing
    // into text fields without immediately fetching new message content
    private let debounceTimerInterval: TimeInterval = 1
    private var debounceTimer: Timer?

    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        setViews()
        loadDefaultSelections()
    }

    private func setViews() {
        // Add subviews
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
        view.addSubview(statusTextView)
        view.addSubview(resetButton)

        view.backgroundColor = UIColor.systemBackground

        NSLayoutConstraint.activate(constraints())
    }

    private func loadDefaultSelections() {
        loadSegmentedIndex(item: defaultMessageConfig.style.logoType, picker: logoTypePicker)
        loadSegmentedIndex(item: defaultMessageConfig.style.color, picker: colorTypePicker)
        loadSegmentedIndex(item: defaultMessageConfig.style.textAlign, picker: alignmentTypePicker)
        buyerCountryField.text = defaultMessageConfig.data.buyerCountry
        ignoreCacheSwitch.isOn = defaultMessageConfig.data.ignoreCache

        if let amount = defaultMessageConfig.data.amount {
            amountTextField.text = String(format: "%f", amount)
        } else {
            amountTextField.text = nil
        }

        if let offerType = defaultMessageConfig.data.offerType,
           let offerIndex = PayPalMessageOfferType.allCases.firstIndex(of: offerType) {
            offerTypePicker.selectedSegmentIndex = offerIndex
        } else {
            offerTypePicker.selectedSegmentIndex = UISegmentedControl.noSegment
        }

        paypalMessage.backgroundColor = defaultMessageConfig.style.color == .white ? .black : .clear

        clientIDField.text = defaultMessageConfig.data.clientID
    }

    private func loadSegmentedIndex<T: PayPalMessageEnumType>(item: T, picker: UISegmentedControl) {
        let fallback = picker.selectedSegmentIndex
        let newSelection = T.allCases.firstIndex(of: item) as? Int
        picker.selectedSegmentIndex = newSelection ?? fallback
    }

    // MARK: - Actions
    @objc private func updatePayPalMessageMessage() {
        debounceTimer?.invalidate()

        debounceTimer = Timer.scheduledTimer(
            withTimeInterval: debounceTimerInterval,
            repeats: false
        ) { [weak self] _ in
            guard let self = self else { return }

            let config = self.getCurrentConfig()

            self.paypalMessage.backgroundColor = config.style.color == .white ? .black : .clear

            self.paypalMessage.setConfig(config)
        }
    }

    @objc private func resetConfig(_ sender: UIView) {
        paypalMessage.setConfig(defaultMessageConfig)
        loadDefaultSelections()
    }

    // MARK: - Styling Helpers
    private func getCurrentConfig() -> PayPalMessageConfig {
        let config = PayPalMessageConfig(
            data: .init(
                clientID: getCurrentClientID() ?? defaultMessageConfig.data.clientID,
                environment: defaultMessageConfig.data.environment,
                amount: getCurrentAmount(),
                offerType: getCurrentOfferType()
            ),
            style: .init(
                logoType: getCurrentLogoType(),
                color: getCurrentMessageColor(),
                textAlign: getCurrentAlignment()
            )
        )

        config.data.buyerCountry = getCurrentBuyerCountry()
        config.data.ignoreCache = getCurrentIgnoreCache()

        return config
    }

    // MARK: - Input Control Value Getters
    private func getCurrentLogoType() -> PayPalMessageLogoType {
        PayPalMessageLogoType.allCases[logoTypePicker.selectedSegmentIndex]
    }

    private func getCurrentMessageColor() -> PayPalMessageColor {
        PayPalMessageColor.allCases[colorTypePicker.selectedSegmentIndex]
    }

    private func getCurrentAlignment() -> PayPalMessageTextAlign {
        PayPalMessageTextAlign.allCases[alignmentTypePicker.selectedSegmentIndex]
    }

    private func getCurrentOfferType() -> PayPalMessageOfferType? {
        guard offerTypePicker.selectedSegmentIndex != -1 else { return nil }
        return PayPalMessageOfferType.allCases[offerTypePicker.selectedSegmentIndex]
    }

    private func getCurrentAmount() -> Double? {
        Double(amountTextField.text ?? "")
    }

    private func getCurrentBuyerCountry() -> String? {
        guard let text = buyerCountryField.text, !text.isEmpty else { return nil }

        return text
    }

    private func getCurrentIgnoreCache() -> Bool {
        ignoreCacheSwitch.isOn
    }

    private func getCurrentClientID() -> String? {
        guard let text = clientIDField.text, !text.isEmpty else { return nil }

        return text
    }

    // MARK: - Constraints
    // In order to self size scroll view, constraint UIScrollView to all four corners
    // of parent view constraint, then stackView to top bottom sides of parent scroll view
    // content layout guide, centerX of scrollView and set width and height equal
    // to frame layout guide. Ensure that stack view height constraint has a low priority.
    private func constraints() -> [NSLayoutConstraint] {
        let stackViewHeight = stackView.heightAnchor.constraint(
            equalTo: scrollView.frameLayoutGuide.heightAnchor
        )
        stackViewHeight.priority = .defaultLow
        return [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackViewHeight,
            stackView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),
            stackView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),
            stackView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),
            stackView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            stackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),
            statusTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statusTextView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -10
            ),
            // MARK: FIX RESET BUTTON
            resetButton.heightAnchor.constraint(equalToConstant: 44),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            resetButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: 4
            )
        ]
    }
}

// MARK: - Delegates
extension UIKitContentViewController: PayPalMessageViewStateDelegate {

    func onLoading(_ paypalMessageView: PayPalMessageView) {
        statusTextView.text = "Loading..."
    }

    func onSuccess(_ paypalMessageView: PayPalMessageView) {
        statusTextView.text = "Success"
    }

    func onError(_ paypalMessageView: PayPalMessageView, error: PayPalMessageError) {
        if let paypalDebugID = error.paypalDebugId {
            statusTextView.text = "Error (\(paypalDebugID))"
        } else {
            statusTextView.text = "Error"
        }
    }
}

extension UIKitContentViewController: PayPalMessageViewEventDelegate {

    func onClick(_ paypalMessageView: PayPalMessageView) {
        statusTextView.text = "Clicked"
    }

    func onApply(_ paypalMessageView: PayPalMessageView) {
        statusTextView.text = "Applied"
    }
}
