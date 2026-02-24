import SwiftUI

struct ReusableCurrencyTextField: View {

    @Binding var value: Double?
    @State private var stringValue: String = ""

    init(value: Binding<Double?>) {
        _value = value
        _stringValue = State(initialValue: value.wrappedValue?.description ?? "")
    }

    var body: some View {
        let stringBinding = Binding(
            get: { stringValue },
            set: { newValue in
                stringValue = newValue
                value = Double(newValue)
            }
        )
        return TextField("", text: stringBinding)
            .modifier(ReusableTextFieldModifier(binding: stringBinding))
            .truncationMode(Text.TruncationMode.tail)
            .onChange(of: value) { newValue in
                if let newValue {
                    stringValue = newValue.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(newValue)) : newValue.description
                } else {
                    stringValue = "" // Clear the text field when value is set to nil
                }
            }
    }
}
