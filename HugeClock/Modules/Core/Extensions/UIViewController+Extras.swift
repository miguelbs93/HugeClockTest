import UIKit

extension UIViewController {
    var topController: UIViewController {
        var topController: UIViewController = self
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
}
