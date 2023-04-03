import Combine
import UIKit

// MARK: - Dependencies

protocol RemindersCoordinatorDependencies {
    var alertManager: AlertManagerProtocol { get }
    var reminderStore: RemindersStore { get }
    var notificationManager: NotificationSchedulingManagerProtocol { get }
}

extension MainTabBarCoordinator.Dependencies: RemindersCoordinatorDependencies {
    var reminderStore: RemindersStore { dataStore }
}

// MARK: - Routes

enum RemindersRoutes {
    case addReminder
    case dismissPresented
}

// MARK: - Coordinator

final class RemindersCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    
    // Private Properties
    
    private var dependencies: RemindersCoordinatorDependencies!
    private var subscriptions: Set<AnyCancellable> = []
    private let routePublisher: PassthroughSubject<RemindersRoutes, Never> = .init()
    
    func start() {
        showRemindersViewController()
    }
    
    init(_
         navigationController: UINavigationController = UINavigationController(),
         dependencies: RemindersCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.childCoordinators = []
        
        routePublisher
            .sink { [weak self] route in
                self?.handle(route: route)
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Views & Routing

private extension RemindersCoordinator {
    func showRemindersViewController() {
        let viewModel = RemindersViewModel(
            remindersService: dependencies.reminderStore,
            routeObserver: routePublisher
        )
        let viewController = RemindersViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
    }
    
    func showAddReminder() {
        let viewModel = AddReminderViewModel(
            notificationService: dependencies.notificationManager,
            remindersService: dependencies.reminderStore,
            routePublisher: routePublisher
        )
        let addReminderViewController = AddReminderViewController(viewModel: viewModel)
        let addReminderNVC = UINavigationController(rootViewController: addReminderViewController)
        viewModel.alertPublisher
            .sink { [weak self] alert in
                self?.dependencies.alertManager.showAlert(
                    with: alert,
                    in: addReminderNVC
                )
            }
            .store(in: &subscriptions)
        navigationController.present(addReminderNVC, animated: true)
    }
    
    func handle(route: RemindersRoutes) {
        switch route {
        case .addReminder:
            showAddReminder()
        case .dismissPresented:
            navigationController.presentedViewController?.dismiss(animated: true)
        }
    }
}
