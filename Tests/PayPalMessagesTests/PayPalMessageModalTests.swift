import Foundation
import XCTest
@testable import PayPalMessages

class PayPalMessageModalTests: XCTestCase {
    let config = PayPalMessageModalConfig(
        data: .init(
            clientID: "Test123",
            environment: .sandbox,
            amount: 100.0,
            currency: "USD",
            offerType: .payLaterLongTerm
        )
    )

    var modalViewController: PayPalMessageModal!

    override func setUpWithError() throws {
        // Create an instance of PayPalMessageModal for testing
        modalViewController = PayPalMessageModal(config: config)
        modalViewController.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        // Clean up after each test
        modalViewController = nil
    }

    func testShowWithConfig() {
        let presentingViewController = UIViewController()

        // Getting the all scenes
        let scenes = UIApplication.shared.connectedScenes
        // Getting windowScene from scenes
        let windowScene = scenes.first as? UIWindowScene
        // Getting window from windowScene
        let window = windowScene?.windows.first
        window?.rootViewController = presentingViewController

        presentingViewController.loadViewIfNeeded()
        modalViewController.loadViewIfNeeded()

        // Create an expectation to track the modal presentation
        let presentationExpectation = XCTestExpectation(description: "Modal presentation")

        modalViewController.show(config: config) // Replace with your mock configuration

        // Add a brief delay for animations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Increase the delay if needed
            // Verify that the modal view controller is presented modally
            XCTAssertTrue(self.modalViewController.modalPresentationStyle == .formSheet)

            // Fulfill the presentation expectation
            presentationExpectation.fulfill()
        }

        // Wait for the presentation expectation with an appropriate timeout
        wait(for: [presentationExpectation], timeout: 5.0)
    }


    func testSupportedInterfaceOrientations() {
        let orientations = modalViewController.supportedInterfaceOrientations

        XCTAssertEqual(orientations, .portrait)
    }

    func testPreferredInterfaceOrientationForPresentation() {
        let orientation = modalViewController.preferredInterfaceOrientationForPresentation

        XCTAssertEqual(orientation, .portrait)
    }

    func testShouldAutorotate() {
        let shouldAutoRotate = modalViewController.shouldAutorotate

        XCTAssertFalse(shouldAutoRotate)
    }

    func testModalDismissal() {
        // Present the modal
        modalViewController.show()

        // Dismiss the modal
        modalViewController.hide()

        // Ensure that the modal is dismissed
        XCTAssertNil(modalViewController.presentingViewController)
    }


    func testIntegrationInitializer() {
        let clientID = "Client123"
        let merchantID = "Merchant456"
        let partnerAttributionID = "Partner789"
        let amount = 100.0
        let currency = "USD"
        let placement = PayPalMessagePlacement.home
        let offerType = PayPalMessageOfferType.payLaterShortTerm
        let closeButtonWidth = 30
        let closeButtonHeight = 30
        let closeButtonAvailableWidth = 70
        let closeButtonAvailableHeight = 70
        let closeButtonColor = UIColor(hexString: "#001435")
        let closeButtonColorType = "light"
        let environment = Environment.sandbox

        let modalDataConfig = PayPalMessageModalDataConfig(
            clientID: clientID,
            merchantID: merchantID,
            environment: environment,
            partnerAttributionID: partnerAttributionID,
            amount: amount,
            currency: currency,
            placement: placement,
            offerType: offerType,
            modalCloseButton: ModalCloseButtonConfig(
                width: closeButtonWidth,
                height: closeButtonHeight,
                availableWidth: closeButtonAvailableWidth,
                availableHeight: closeButtonAvailableHeight,
                color: closeButtonColor,
                colorType: closeButtonColorType
            )
        )

        XCTAssertEqual(modalDataConfig.clientID, clientID)
        XCTAssertEqual(modalDataConfig.merchantID, merchantID)
        XCTAssertEqual(modalDataConfig.partnerAttributionID, partnerAttributionID)
        XCTAssertEqual(modalDataConfig.amount, amount)
        XCTAssertEqual(modalDataConfig.currency, currency)
        XCTAssertEqual(modalDataConfig.placement, placement)
        XCTAssertEqual(modalDataConfig.offerType, offerType)
        XCTAssertEqual(modalDataConfig.modalCloseButton.width, closeButtonWidth)
        XCTAssertEqual(modalDataConfig.modalCloseButton.height, closeButtonHeight)
        XCTAssertEqual(modalDataConfig.modalCloseButton.availableWidth, closeButtonAvailableWidth)
        XCTAssertEqual(modalDataConfig.modalCloseButton.availableHeight, closeButtonAvailableHeight)
        XCTAssertEqual(modalDataConfig.modalCloseButton.color, closeButtonColor)
        XCTAssertEqual(modalDataConfig.modalCloseButton.colorType, closeButtonColorType)
        XCTAssertEqual(modalDataConfig.environment, environment)
    }
}

func testSetGlobalAnalytics() {
    let integrationName = "MyIntegration"
    let integrationVersion = "1.0"
    let deviceID = "Device123"
    let sessionID = "Session456"

    PayPalMessageModalConfig.setGlobalAnalytics(
        integrationName: integrationName,
        integrationVersion: integrationVersion,
        deviceID: deviceID,
        sessionID: sessionID
    )

    XCTAssertEqual(Logger.integrationName, integrationName)
    XCTAssertEqual(Logger.integrationVersion, integrationVersion)
    XCTAssertEqual(Logger.deviceID, deviceID)
    XCTAssertEqual(Logger.sessionID, sessionID)
}

func testSetGlobalAnalyticsWithDefaults() {
    let integrationName = "MyIntegration"
    let integrationVersion = "1.0"

    PayPalMessageConfig.setGlobalAnalytics(
        integrationName: integrationName,
        integrationVersion: integrationVersion
    )

    XCTAssertEqual(Logger.integrationName, integrationName)
    XCTAssertEqual(Logger.integrationVersion, integrationVersion)
    XCTAssertNil(Logger.deviceID)
    XCTAssertNil(Logger.sessionID)
}
