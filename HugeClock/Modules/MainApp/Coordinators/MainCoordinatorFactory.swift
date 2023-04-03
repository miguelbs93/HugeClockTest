import CoreData
import UIKit

protocol MainCoordinatorFactoryProtocol {
    func makeMainTabCoordinator(_
        navigationController: UINavigationController,
        window: UIWindow?
    ) -> MainTabBarCoordinator
}

final class MainCoordinatorFactory: MainCoordinatorFactoryProtocol {
    func makeMainTabCoordinator(_
        navigationController: UINavigationController,
        window: UIWindow?
    ) -> MainTabBarCoordinator {
        let coreData = try! CoreDataStore(storeURL: NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("huge-clock-store.sqlite"))
        let notificationManager = NotificationSchedulingManager()
        let alertManager = AlertManager()
        
        let dependency = MainTabBarCoordinator.Dependencies(
            alertManager: alertManager,
            dataStore: coreData,
            makeRemindersCoordinator: { dependency in
                    .makeRemindersTabItem(dependencies: dependency)
            },
            makeWorldClockCoordinator: { dependency in
                    .makeWorldClockTabItem(dependencies: dependency)
            },
            makeTimerCoordinator: { dependency in
                    .makeTimerTabItem(dependencies: dependency)
            },
            notificationManager: notificationManager
        )
        
        let coordinator = MainTabBarCoordinator(
            dependencies: dependency,
            navigationController: navigationController,
            window: window
        )
        
        return coordinator
    }
}
