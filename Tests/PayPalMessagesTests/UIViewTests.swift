import Foundation
import XCTest
@testable import PayPalMessages

final class UIViewExtensionTests: XCTestCase {

    var testView: UIView?

    override func setUp() {
        super.setUp()
        testView = UIView()
    }

    override func tearDown() {
        testView = nil
        super.tearDown()
    }


    func testRotateIndefinitely() {
        if let view = testView {
            // Ensure that the view is not already rotating
            XCTAssertNil(view.layer.animation(forKey: "rotation_animation"))

            // Apply the rotation animation using your extension method
            view.rotateIndefinitely()


            // Check properties of the animation
            if let rotationAnimation = view.layer.animation(forKey: "rotation_animation") as? CABasicAnimation {
                XCTAssertEqual(rotationAnimation.keyPath, "transform.rotation.z")
                XCTAssertEqual(rotationAnimation.toValue as? Double, Double.pi * 2)
                XCTAssertEqual(rotationAnimation.duration, 1)
                XCTAssertEqual(rotationAnimation.isCumulative, true)
                XCTAssertEqual(rotationAnimation.repeatCount, .infinity)
                XCTAssertEqual(rotationAnimation.isRemovedOnCompletion, false)
            }
        }
    }
}
