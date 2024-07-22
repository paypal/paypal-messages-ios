import Foundation

/// State Delegate
public protocol PayPalMessageModalStateDelegate: AnyObject {
    /// Function invoked when the message first starts to fetch data
    func onLoading(_ paypalMessageModal: PayPalMessageModal)
    /// Function invoked when the message has rendered
    func onSuccess(_ paypalMessageModal: PayPalMessageModal)
    /// Function invoked when the message encounters an error
    func onError(
        _ paypalMessageModal: PayPalMessageModal,
        error: PayPalMessageError
    )
}

/// Event Delegate
public protocol PayPalMessageModalEventDelegate: AnyObject {
    /// Function invoked when element within modal is tapped
    func onClick(
        _ paypalMessageModal: PayPalMessageModal,
        data: PayPalMessageModalClickData
    )
    /// Function invoked when payment breakdown calculator is submitted
    func onCalculate(
        _ paypalMessageModal: PayPalMessageModal,
        data: PayPalMessageModalCalculateData
    )
    /// Function invoked wehn modal is presented into view
    func onShow(_ paypalMessageModal: PayPalMessageModal)
    /// Function invoked when modal disappears from view
    func onClose(_ paypalMessageModal: PayPalMessageModal)
}

// MARK: - Delegate Data Classes

public class PayPalMessageModalClickData: NSObject {

    let linkName: String
    let linkSrc: String

    init(linkName: String, linkSrc: String) {
        self.linkName = linkName
        self.linkSrc = linkSrc
    }

    deinit {}
}

public class PayPalMessageModalCalculateData: NSObject {

    let value: Double

    init(value: Double) {
        self.value = value
    }

    deinit {}
}
