@ViewBuilder
    func body(content: Content) -> some View {
        applyAutocorrection(to: content
            .frame(width: 200)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .textFieldStyle(RoundedBorderTextFieldStyle()))
            .truncationMode(Text.TruncationMode.tail)
            .overlay(clearButtonOverlay(for: binding))
    }
    
    @ViewBuilder
    private func applyAutocorrection<V: View>(to view: V) -> some View {
        if #available(iOS 15.0, *) {
            view.autocorrectionDisabled(true)
        } else {
            view.disableAutocorrection(true)
        }
    }