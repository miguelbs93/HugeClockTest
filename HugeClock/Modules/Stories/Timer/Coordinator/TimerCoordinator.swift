import Combine
import UIKit

// MARK: - Dependencies

protocol TimerCoordinatorDependencies {
    var timerStore: TimersStore { get }
    var alertManager: AlertManagerProtocol { get }
    var notificationManager: NotificationSchedulingManagerProtocol { get }
}

extension MainTabBarCoordinator.Dependencies: TimerCoordinatorDependencies {
    var timerStore: TimersStore { dataStore }
}

// MARK: - Coordinator

final class TimerCoordinator: Coordinator {
    private let dependencies: TimerCoordinatorDependencies!
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    
    private var subscriptions: Set<AnyCancellable> = []
    
    func start() {
        showTimerViewController()
    }
    
    init(
        navigationController: UINavigationController = UINavigationController(),
        dependencies: TimerCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.childCoordinators = []
    }
    
    private func showTimerViewController() {
        let viewModel = TimerViewModel(
            notificationManager: dependencies.notificationManager,
            timerStore: dependencies.timerStore
        )
        let viewController = TimerViewController(viewModel: viewModel)
        
        viewModel.errorPublisher
            .sink(receiveValue: { [weak self] model in
                self?.dependencies.alertManager
                    .showAlert(with: model, in: viewController)
            })
            .store(in: &subscriptions)
        
        navigationController.viewControllers = [viewController]
    }
}
