import Foundation
import XCTest
@testable import PayPalMessages

class PayPalMessageModalTests: XCTestCase {

    let config = PayPalMessageModalConfig(
        data: .init(
            clientID: "Test123",
            environment: .sandbox,
            amount: 100.0,
            offerType: .payLaterLongTerm
        )
    )

    var modalViewController: PayPalMessageModal?

    override func setUp() {
        super.setUp()
        modalViewController = PayPalMessageModal(config: config)
        modalViewController?.loadViewIfNeeded()
    }

    override func tearDown() {
        modalViewController = nil
        super.tearDown()
    }

    func testInitialPropertyValues() {
        let modalViewController = PayPalMessageModal(config: config)

        let supportedOrientations = modalViewController.supportedInterfaceOrientations
        let preferredOrientation = modalViewController.preferredInterfaceOrientationForPresentation
        let shouldAutoRotate = modalViewController.shouldAutorotate

        XCTAssertEqual(supportedOrientations, .portrait)
        XCTAssertEqual(preferredOrientation, .portrait)
        XCTAssertFalse(shouldAutoRotate)
    }

    func testViewOnLoadingDelegate() {
        if let viewController = modalViewController {
            let stateDelegateMock = PayPalMessageModalStateDelegateMock()
            viewController.stateDelegate = stateDelegateMock

            viewController.viewDidLoad()

            XCTAssertTrue(stateDelegateMock.onLoadingCalled)
        }
    }

    func testViewWillAppearCallsOnShowDelegate() {
        if let viewController = modalViewController {
            let eventDelegateMock = PayPalMessageModalEventDelegateMock()
            viewController.eventDelegate = eventDelegateMock

            viewController.viewWillAppear(false)

            XCTAssertTrue(eventDelegateMock.onShowCalled)
        }
    }

    func testModalDismissalCallsOnCloseDelegate() {
        if let viewController = modalViewController {
            let eventDelegateMock = PayPalMessageModalEventDelegateMock()
            viewController.eventDelegate = eventDelegateMock

            viewController.viewDidDisappear(false)

            XCTAssertTrue(eventDelegateMock.onCloseCalled)
        }
    }

    func testModalPresentationAndDismissal() {
        if let viewController = modalViewController {
            let eventDelegateMock = PayPalMessageModalEventDelegateMock()
            viewController.eventDelegate = eventDelegateMock

            viewController.show()
            viewController.viewWillAppear(false)

            XCTAssertTrue(eventDelegateMock.onShowCalled)

            viewController.hide()
            viewController.viewDidDisappear(false)

            XCTAssertTrue(eventDelegateMock.onCloseCalled)
        }
    }

    func testIntegrationInitializer() {
        let clientID = "Client123"
        let merchantID = "Merchant456"
        let partnerAttributionID = "Partner789"
        let amount = 100.0
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
