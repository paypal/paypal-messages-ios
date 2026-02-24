import SwiftUI

struct ReusableTextField: View {

    @Binding var text: String

    var body: some View {
        TextField("", text: $text)
            .modifier(ReusableTextFieldModifier(binding: $text))
            .truncationMode(Text.TruncationMode.tail)
    }
}
