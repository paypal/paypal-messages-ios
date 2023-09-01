import UIKit

extension UIViewController {

    static func getPresentingViewController() -> UIViewController? {
        let keyWindow = UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .last { $0.isKeyWindow }

        if var rootViewController = keyWindow?.rootViewController {
            while let presentedViewController = rootViewController.presentedViewController {
                rootViewController = presentedViewController
            }

            return rootViewController
        }
        return nil
    }
}
