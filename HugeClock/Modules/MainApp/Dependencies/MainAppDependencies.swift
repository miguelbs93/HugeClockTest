import CoreData
import Foundation

extension MainTabBarCoordinator {
    struct Dependencies {
        let alertManager: AlertManagerProtocol
        let dataStore: CoreDataStore
        let makeRemindersCoordinator: (RemindersCoordinatorDependencies) -> TabItem
        let makeWorldClockCoordinator: (WorldClockCoordinatorDependencies) -> TabItem
        let makeTimerCoordinator: (TimerCoordinatorDependencies) -> TabItem
        let notificationManager: NotificationSchedulingManagerProtocol
        
        init(
            alertManager: AlertManagerProtocol,
            dataStore: CoreDataStore,
            makeRemindersCoordinator: @escaping (RemindersCoordinatorDependencies) -> TabItem,
            makeWorldClockCoordinator: @escaping (WorldClockCoordinatorDependencies) -> TabItem,
            makeTimerCoordinator: @escaping (TimerCoordinatorDependencies) -> TabItem,
            notificationManager: NotificationSchedulingManagerProtocol
        ) {
            self.alertManager = alertManager
            self.dataStore = dataStore
            self.makeRemindersCoordinator = makeRemindersCoordinator
            self.makeWorldClockCoordinator = makeWorldClockCoordinator
            self.makeTimerCoordinator = makeTimerCoordinator
            self.notificationManager = notificationManager
        }
    }
}
