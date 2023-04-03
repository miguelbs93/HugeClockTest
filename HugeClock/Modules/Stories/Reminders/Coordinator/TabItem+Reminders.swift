import UIKit

extension TabItem {
    
    fileprivate struct TabImage {
        static let remindersIcon = "reminders-tab"
    }
    
    static func makeRemindersTabItem(dependencies: RemindersCoordinatorDependencies) -> TabItem {
        let coordinator = RemindersCoordinator(dependencies: dependencies)
        let rootVC = coordinator.navigationController
        return .init(
            context: .init(
                title: "Reminders",
                icon: TabImage.remindersIcon,
                viewController: rootVC
            ),
            coordinator: coordinator
        )
    }
}
