import Foundation
import XCTest
@testable import PayPalMessages

class UIViewExtensionTests: XCTestCase {

    var testView: UIView!

    override func setUp() {
        super.setUp()
        testView = UIView()
    }

    override func tearDown() {
        testView = nil
        super.tearDown()
    }

    func testRotateIndefinitely() {
        // Ensure that the view is not already rotating
        XCTAssertNil(testView.layer.animation(forKey: "rotation_animation"))

        // Apply the rotation animation using your extension method
        testView.rotateIndefinitely()


        // Check properties of the animation
        if let rotationAnimation = testView.layer.animation(forKey: "rotation_animation") as? CABasicAnimation {
            XCTAssertEqual(rotationAnimation.keyPath, "transform.rotation.z")
            XCTAssertEqual(rotationAnimation.toValue as? Double, Double.pi * 2)
            XCTAssertEqual(rotationAnimation.duration, 1)
            XCTAssertEqual(rotationAnimation.isCumulative, true)
            XCTAssertEqual(rotationAnimation.repeatCount, .infinity)
            XCTAssertEqual(rotationAnimation.isRemovedOnCompletion, false)
        }
    }
}
