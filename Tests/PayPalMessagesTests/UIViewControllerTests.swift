import Foundation
import XCTest
@testable import PayPalMessages

class UIViewControllerExtensionTests: XCTestCase {

    func testPushViewControllerInNavigationStack() {
        // Create a mock navigation controller with a root view controller
        let rootViewController = UIViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)

        // Push a new view controller onto the navigation stack
        let pushedViewController = UIViewController()
        navigationController.pushViewController(pushedViewController, animated: false)

        // Verify that the pushed view controller is now on top of the navigation stack
        XCTAssertEqual(navigationController.topViewController, pushedViewController)
    }

    func testDismissPresentedNavigationController() {
        // Create a mock presenting view controller
        let presentingViewController = UIViewController()

        // Create a mock presented navigation controller with a root view controller
        let rootViewController = UIViewController()
        let presentedNavigationController = UINavigationController(rootViewController: rootViewController)

        // Present the navigation controller
        presentingViewController.present(presentedNavigationController, animated: false, completion: nil)

        // Dismiss the presented navigation controller
        presentedNavigationController.dismiss(animated: false, completion: nil)

        // Verify that the navigation controller and its root view controller are dismissed
        XCTAssertNil(presentedNavigationController.presentingViewController)
        XCTAssertNil(rootViewController.presentingViewController)
    }
}
