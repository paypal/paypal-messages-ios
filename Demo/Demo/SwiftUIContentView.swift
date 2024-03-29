import SwiftUI
import PayPalMessages

// MARK: - View
struct SwiftUIContentView: View {

    // MARK: Properties
    // Defines the @State variables for managing the input control values

    @State private var logoType: PayPalMessageLogoType = defaultMessageConfig.style.logoType
    @State private var messageColor: PayPalMessageColor = defaultMessageConfig.style.color
    @State private var textAlign: PayPalMessageTextAlign = defaultMessageConfig.style.textAlign

    @State private var clientID: String = defaultMessageConfig.data.clientID
    @State private var amount: Double? = defaultMessageConfig.data.amount
    @State private var pageType: PayPalMessagePageType? = defaultMessageConfig.data.pageType
    @State private var offerType: PayPalMessageOfferType? = defaultMessageConfig.data.offerType
    @State private var buyerCountry: String = defaultMessageConfig.data.buyerCountry ?? ""
    @State private var ignoreCache: Bool = defaultMessageConfig.data.ignoreCache

    @State private var messageState: String = ""
    @State private var debounceTimerInterval: TimeInterval = 1
    @State private var debounceTimer: Timer?
    @State private var backgroundColor: Color = defaultMessageConfig.style.color == .white ? .black : .clear

    // MARK: Initialization
    @State private var messageConfig = defaultMessageConfig

    private func getCurrentConfig() -> PayPalMessageConfig {
        let messageConfig: PayPalMessageConfig = .init(
            data: .init(
                clientID: clientID,
                environment: defaultMessageConfig.data.environment,
                amount: amount,
                pageType: pageType,
                offerType: offerType
            ),
            style: .init(
                logoType: logoType,
                color: messageColor,
                textAlign: textAlign
            )
        )

        if !buyerCountry.isEmpty {
            messageConfig.data.buyerCountry = buyerCountry
        }
        messageConfig.data.ignoreCache = ignoreCache

        return messageConfig
    }

    // MARK: Debouncer
    private func debounceConfigUpdate() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceTimerInterval, repeats: false) { _ in

            messageConfig = getCurrentConfig()

            if messageColor == .white {
                backgroundColor = .black
            } else {
                backgroundColor = .clear
            }
        }
    }

    // MARK: - View Body

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            ReusableTextView(text: "Message Configuration", font: .title3, weight: .semibold)

            HStack {
                // Client ID
                ReusableTextView(text: "Client ID", font: .subheadline, weight: .semibold)

                ReusableTextField(text: $clientID)
                    .onChange(of: clientID) { _ in
                        debounceConfigUpdate()
                    }
            }

            // MARK: Style Options

            Group {
                ReusableTextView(text: "Style Options", font: .subheadline, weight: .semibold)

                // Logo Type
                ReusablePicker(options: PayPalMessageLogoType.allCases, selectedOption: $logoType)
                    .onChange(of: logoType) { _ in
                        debounceConfigUpdate()
                    }

                // Message Color
                ReusablePicker(options: PayPalMessageColor.allCases, selectedOption: $messageColor)
                    .onChange(of: messageColor) { _ in
                        debounceConfigUpdate()
                    }

                // Text Alignment
                ReusablePicker(options: PayPalMessageTextAlign.allCases, selectedOption: $textAlign)
                    .onChange(of: textAlign) { _ in
                        debounceConfigUpdate()
                    }
            }

            // MARK: Data Options

            Group {
                // Offer Type
                ReusableTextView(text: "Offer Type", font: .subheadline, weight: .semibold)

                Picker("", selection: $offerType) {
                    ForEach(PayPalMessageOfferType.allCases, id: \.self) { offerTypeCase in
                        Text(offerTypeCase.description).tag(Optional(offerTypeCase))
                    }
                }
                .onChange(of: offerType) { _ in
                    debounceConfigUpdate()
                }
                .pickerStyle(SegmentedPickerStyle())

                HStack {
                    // Amount
                    ReusableTextView(text: "Amount", font: .subheadline, weight: .semibold)

                    ReusableCurrencyTextField(value: $amount)
                        .onChange(of: amount) { _ in
                            debounceConfigUpdate()
                        }
                }
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))

                HStack {
                    // Buyer Country
                    ReusableTextView(text: "Buyer Country", font: .subheadline, weight: .semibold)

                    ReusableTextField(text: $buyerCountry)
                        .onChange(of: buyerCountry) { _ in
                            debounceConfigUpdate()
                        }
                }
            }

            HStack {
                // Ignore Cache
                ReusableToggle(isOn: $ignoreCache, label: "ignoreCache")

                ReusableTextView(
                    text: "Ignore Cache",
                    font: .system(size: 14),
                    weight: .semibold,
                    padding: .init(top: 0, leading: 16, bottom: 0, trailing: 0)
                )
                .onChange(of: ignoreCache) { _ in
                    debounceConfigUpdate()
                }
            }

            Divider()

            // MARK: PayPal Message

            PayPalMessageView.Representable(config: messageConfig, stateDelegate: messageStateDelegate, eventDelegate: messageEventDelegate)
                .background(backgroundColor)

            HStack {
                // Reset configuration
                Button("Reset", action: loadDefaultSelections)
                    .foregroundColor(.blue)
                Spacer()
                // Loading, Success, Error
                ReusableTextView(
                    text: messageState,
                    font: .system(size: 14),
                    weight: .regular,
                    foregroundColor: .gray,
                    padding: .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                )
            }
            .frame( maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .padding()
    }

    // MARK: - Load Defaults
    private func loadDefaultSelections() {
        let defaultData = defaultMessageConfig.data
        let defaultStyle = defaultMessageConfig.style

        logoType = defaultStyle.logoType
        messageColor = defaultStyle.color
        textAlign = defaultStyle.textAlign
        offerType = defaultData.offerType
        amount = defaultData.amount
        buyerCountry = defaultData.buyerCountry ?? ""
        ignoreCache = defaultData.ignoreCache
        clientID = defaultData.clientID
    }

    // MARK: - Delegates

    class MessageViewStateDelegate: PayPalMessageViewStateDelegate {

        @Binding var messageState: String

        init(messageState: Binding<String>) {
            self._messageState = messageState
        }

        func onLoading(_ paypalMessageView: PayPalMessageView) {
            DispatchQueue.main.async {
                self.messageState = "Loading..."
            }
        }

        func onSuccess(_ paypalMessageView: PayPalMessageView) {
            DispatchQueue.main.async {
                self.messageState = "Success"
            }
        }

        func onError(_ paypalMessageView: PayPalMessageView, error: PayPalMessageError) {
            DispatchQueue.main.async {
                if let paypalDebugID = error.paypalDebugId {
                    self.messageState = "Error (\(paypalDebugID))"
                } else {
                    self.messageState = "Error"
                }
            }
        }
    }

    private var messageStateDelegate: PayPalMessageViewStateDelegate {
        MessageViewStateDelegate(messageState: $messageState)
    }

    class MessageViewEventDelegate: PayPalMessageViewEventDelegate {

        @Binding var messageState: String

        init(messageState: Binding<String>) {
            self._messageState = messageState
        }

        func onClick(_ paypalMessageView: PayPalMessageView) {
            DispatchQueue.main.async {
                self.messageState = "Clicked"
            }
        }

        func onApply(_ paypalMessageView: PayPalMessageView) {
            DispatchQueue.main.async {
                self.messageState = "Applied"
            }
        }
    }

    private var messageEventDelegate: PayPalMessageViewEventDelegate {
        MessageViewEventDelegate(messageState: $messageState)
    }

    struct ContentView_Previews: PreviewProvider {

        static var previews: some View {
            SwiftUIContentView()
        }
    }
}
