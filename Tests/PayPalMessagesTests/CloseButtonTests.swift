@testable import PayPalMessages
import XCTest

class CloseButtonTests: XCTestCase {

    var closeButton: CloseButton?
    var onTapCalled = false

    override func setUp() {
        super.setUp()

        // Initialize a CloseButton with a tap closure
        closeButton = CloseButton {
            self.onTapCalled = true
        }
    }

    override func tearDown() {
        closeButton = nil
        super.tearDown()
    }

    func testButtonInitialization() {
        if let button = closeButton {
            XCTAssertNotNil(button)
            XCTAssertEqual(button.alpha, 1.0)
            XCTAssertEqual(button.accessibilityLabel, "Cancel")
            XCTAssertEqual(button.imageView?.contentMode, .scaleAspectFit)
        }
    }

    func testButtonHighlightAnimation() {
        if let button = closeButton {
            // Initially, the button should not be highlighted
            XCTAssertFalse(button.isHighlighted)
            XCTAssertEqual(button.alpha, 1.0)

            // Simulate the button being highlighted
            button.isHighlighted = true

            // Use XCTAssertEqual with a tolerance parameter
            XCTAssertEqual(button.alpha, CloseButton.Constants.fadeOutAlpha, accuracy: 0.001)

            // Simulate the button being unhighlighted
            button.isHighlighted = false

            // Use XCTAssertEqual with a tolerance parameter
            XCTAssertEqual(button.alpha, 1.0, accuracy: 0.001)
        }
    }

    func testIntrinsicContentSize() {
        if let button = closeButton {
            // Calculate the expected intrinsic content size based on your constants
            let expectedWidth = CloseButton.Constants.buttonSize.width +
                (CloseButton.Constants.contenInset.left + CloseButton.Constants.contenInset.right)
            let expectedHeight = CloseButton.Constants.buttonSize.height +
                (CloseButton.Constants.contenInset.top + CloseButton.Constants.contenInset.bottom)

            // Get the actual intrinsic content size from the button
            let intrinsicSize = button.intrinsicContentSize

            // Assert that the actual intrinsic content size matches the expected size
            XCTAssertEqual(intrinsicSize.width, expectedWidth)
            XCTAssertEqual(intrinsicSize.height, expectedHeight)
        }
    }

    func testInitWithoutClosure() {
        if let button = closeButton {
            // Initialize a CloseButton using the init() method
            closeButton = CloseButton()

            // Assert that the button is not nil
            XCTAssertNotNil(closeButton)

            // Assert that the button is properly configured
            XCTAssertEqual(button.alpha, 1.0)
            XCTAssertEqual(button.accessibilityLabel, "Cancel")
            XCTAssertEqual(button.imageView?.contentMode, .scaleAspectFit)
        }
    }

    func testTappedCloseButtonCallsOnTap() {
        // Create a CloseButton instance
        let closeButton = CloseButton()

        // Assign an onTap closure to the CloseButton
        closeButton.onTap = {
            self.onTapCalled = true
        }

        // Simulate tapping the CloseButton
        closeButton.tappedCloseButton(closeButton)

        // Verify that onTap was called
        XCTAssertTrue(onTapCalled)
    }
}
