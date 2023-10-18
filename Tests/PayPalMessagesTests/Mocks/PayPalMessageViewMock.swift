import Foundation
import UIKit
@testable import PayPalMessages

class PayPalMessageViewMock: PayPalMessageViewModelDelegate {

    weak var viewModel: PayPalMessageViewModel?
    var refreshContentCalled = false

    func refreshContent(label: String, traits: UIAccessibilityTraits, accessibilityElement: Bool) {
        refreshContentCalled = true
    }
}

class PayPalMessageViewDelegateMock: PayPalMessageViewEventDelegate, PayPalMessageViewStateDelegate {

    var onClickCalled = false
    var onApplyCalled = false
    var onLoadingCalled = false
    var onSuccessCalled = false
    var onErrorCalled = false
    var error: PayPalMessageError?

    func onClick(_ paypalMessageView: PayPalMessageView) {
        onClickCalled = true
    }

    func onApply(_ paypalMessageView: PayPalMessageView) {
        onApplyCalled = true
    }

    func onLoading(_ paypalMessageView: PayPalMessageView) {
        onLoadingCalled = true
    }

    func onSuccess(_ paypalMessageView: PayPalMessageView) {
        onSuccessCalled = true
    }

    func onError(_ paypalMessageView: PayPalMessageView, error: PayPalMessageError) {
        onErrorCalled = true
        self.error = error
    }
}
