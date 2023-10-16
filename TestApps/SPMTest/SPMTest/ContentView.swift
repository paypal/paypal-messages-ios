import SwiftUI
import PayPalMessages

struct ContentView: View {
    var message = PayPalMessageView(
        config: .init(
            data: .init(
                clientID: "test_app",
                environment: .sandbox
            )
        )
    )

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
