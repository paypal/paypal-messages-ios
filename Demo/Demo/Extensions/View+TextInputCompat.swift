import SwiftUI

extension View {

    @ViewBuilder
    func noAutocap() -> some View {
        if #available(iOS 15.0, *) {
            self.textInputAutocapitalization(.never)
        } else {
            self
        }
    }

    @ViewBuilder
    func autocorrectionOff() -> some View {
        if #available(iOS 15.0, *) {
            self.autocorrectionDisabled(true)
        } else {
            self
        }
    }
}
