import PayPalMessages

let defaultMessageConfig: PayPalMessageConfig = {
    var config = PayPalMessageConfig(
        data: .init(
            // See developer documentation for more information on how to create a client ID and client secret.
            // https://developer.paypal.com/api/rest/#link-getclientidandclientsecret
            clientID: "YOUR_CLIENT_ID",
            environment: .sandbox
        ),
        style: .init()
    )
    // Override defaults for ease of development
    config.data.ignoreCache = false

    return config
}()
