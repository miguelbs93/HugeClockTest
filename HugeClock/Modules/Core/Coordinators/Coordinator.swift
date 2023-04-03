import UIKit

public protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    func start()
    func finish()
}

public extension Coordinator {
    func finish() {
        childCoordinators.removeAll()
    }
}
