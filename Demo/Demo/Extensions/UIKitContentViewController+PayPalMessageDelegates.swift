import UIKit
import PayPalMessages

// MARK: - PayPal Message View State Delegate
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

// MARK: - PayPal Message View Event Delegate
extension UIKitContentViewController: PayPalMessageViewEventDelegate {

    func onClick(_ paypalMessageView: PayPalMessageView) {
        statusTextView.text = "Clicked"
    }

    func onApply(_ paypalMessageView: PayPalMessageView) {
        statusTextView.text = "Applied"
    }
}
