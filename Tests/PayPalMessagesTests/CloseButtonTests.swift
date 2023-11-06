@testable import PayPalMessages
import XCTest

class CloseButtonTests: XCTestCase {

    var closeButton: CloseButton!
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
        XCTAssertNotNil(closeButton)
        XCTAssertEqual(closeButton.alpha, 1.0)
        XCTAssertEqual(closeButton.accessibilityLabel, "Cancel")
        XCTAssertEqual(closeButton.imageView?.contentMode, .scaleAspectFit)
    }

    func testButtonHighlightAnimation() {
        // Initially, the button should not be highlighted
        XCTAssertFalse(closeButton.isHighlighted)
        XCTAssertEqual(closeButton.alpha, 1.0)

        // Simulate the button being highlighted
        closeButton.isHighlighted = true

        // Use XCTAssertEqual with a tolerance parameter
        XCTAssertEqual(closeButton.alpha, CloseButton.Constants.fadeOutAlpha, accuracy: 0.001)

        // Simulate the button being unhighlighted
        closeButton.isHighlighted = false

        // Use XCTAssertEqual with a tolerance parameter
        XCTAssertEqual(closeButton.alpha, 1.0, accuracy: 0.001)
    }

    func testIntrinsicContentSize() {
        // Calculate the expected intrinsic content size based on your constants
        let expectedWidth = CloseButton.Constants.buttonSize.width + (CloseButton.Constants.contenInset.left + CloseButton.Constants.contenInset.right)
        let expectedHeight = CloseButton.Constants.buttonSize.height + (CloseButton.Constants.contenInset.top + CloseButton.Constants.contenInset.bottom)

        // Get the actual intrinsic content size from the button
        let intrinsicSize = closeButton.intrinsicContentSize

        // Assert that the actual intrinsic content size matches the expected size
        XCTAssertEqual(intrinsicSize.width, expectedWidth)
        XCTAssertEqual(intrinsicSize.height, expectedHeight)
    }

    func testInitWithoutClosure() {
        // Initialize a CloseButton using the init() method
        closeButton = CloseButton()

        // Assert that the button is not nil
        XCTAssertNotNil(closeButton)

        // Assert that the button is properly configured
        XCTAssertEqual(closeButton.alpha, 1.0)
        XCTAssertEqual(closeButton.accessibilityLabel, "Cancel")
        XCTAssertEqual(closeButton.imageView?.contentMode, .scaleAspectFit)
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
