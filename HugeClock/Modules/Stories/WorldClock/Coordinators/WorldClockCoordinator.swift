import Combine
import UIKit

// MARK: - Dependencies

protocol WorldClockCoordinatorDependencies {
    var clockStore: ClocksStore { get }
}

extension MainTabBarCoordinator.Dependencies: WorldClockCoordinatorDependencies {
    var clockStore: ClocksStore { dataStore }
}

// MARK: - Routes

enum WorldClockRoutes {
    case addClock
    case dismissPresented
}

// MARK: - Coordinator

final class WorldClockCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator]
    
    // Private properties
    
    private let dependencies: WorldClockCoordinatorDependencies!
    private let routePublisher: PassthroughSubject<WorldClockRoutes, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    func start() {
        showWorldClockCoordinator()
    }
    
    init(_
         navigationController: UINavigationController = UINavigationController(),
         dependencies: WorldClockCoordinatorDependencies
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

private extension WorldClockCoordinator {
    func showWorldClockCoordinator() {
        let viewModel = WorldClockViewModel(
            clockStore: dependencies.clockStore,
            routePublisher: routePublisher
        )
        let viewController = WorldClockViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
    }
    
    func showAddClock() {
        let viewModel = CitiesListViewModel(
            citiesService: CitiesService(),
            clockStore: dependencies.clockStore,
            routeObserver: routePublisher
        )
        let vc = CitiesListViewController(viewModel: viewModel)
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .formSheet
        navigationController.present(nvc, animated: true)
    }
    
    func handle(route: WorldClockRoutes) {
        switch route {
        case .addClock:
            showAddClock()
        case .dismissPresented:
            navigationController.presentedViewController?.dismiss(animated: true)
        }
    }
}
