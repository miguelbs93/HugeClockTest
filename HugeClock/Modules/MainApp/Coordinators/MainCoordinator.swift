import UIKit

final class MainTabBarCoordinator: TabCoordinatorProtocol {
    private let window: UIWindow?
    private let dependencies: Dependencies
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var tabBarController: UITabBarController
    
    init(
        dependencies: Dependencies,
        navigationController: UINavigationController,
        window: UIWindow?
    ) {
        self.dependencies = dependencies
        self.navigationController = navigationController
        self.tabBarController = .init()
        self.window = window
    }
    
    func setTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.view.backgroundColor = .white
        
        let timerModel = dependencies.makeTimerCoordinator(dependencies)
        let timerContext = timerModel.context
        let timerBarItem = UITabBarItem(
            title: timerContext.title,
            image: UIImage(named: timerContext.icon),
            tag: 0
        )
        let timerCoordinator = timerModel.coordinator
        timerCoordinator.navigationController.tabBarItem = timerBarItem
        childCoordinators.append(timerCoordinator)
        timerCoordinator.start()
        
        let remindersModel = dependencies.makeRemindersCoordinator(dependencies)
        let remindersContext = remindersModel.context
        let remindersBarItem = UITabBarItem(
            title: remindersContext.title,
            image: UIImage(named: remindersContext.icon),
            tag: 1
        )
        let remindersCoordinator = remindersModel.coordinator
        remindersCoordinator.navigationController.tabBarItem = remindersBarItem
        childCoordinators.append(remindersCoordinator)
        remindersCoordinator.start()
        
        let clocksModel = dependencies.makeWorldClockCoordinator(dependencies)
        let clocksContext = clocksModel.context
        let clocksBarItem = UITabBarItem(
            title: clocksContext.title,
            image: UIImage(named: clocksContext.icon),
            tag: 2
        )
        let clocksCoordinator = clocksModel.coordinator
        clocksCoordinator.navigationController.tabBarItem = clocksBarItem
        childCoordinators.append(clocksCoordinator)
        clocksCoordinator.start()
        
        tabBarController.viewControllers = [
            timerContext.viewController,
            remindersContext.viewController,
            clocksContext.viewController
        ]
        
        return tabBarController
    }
    
    func start() {
        tabBarController = setTabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    func showError(_ alert: Alert) {
        let selectedIndex = tabBarController.selectedIndex
        let currentVC: UIViewController? = tabBarController.viewControllers?[selectedIndex]
        guard let currentVC else { return }
        dependencies.alertManager.showAlert(with: alert, in: currentVC.topController)
    }
}
