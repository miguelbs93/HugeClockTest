import UIKit

extension TabItem {
    fileprivate struct TabImage {
        static let timerIcon = "timer-tab"
    }
    
    static func makeTimerTabItem(dependencies: TimerCoordinatorDependencies) -> TabItem {
        let coordinator = TimerCoordinator(dependencies: dependencies)
        let rootVC = coordinator.navigationController
        return .init(
            context: .init(
                title: "Timer",
                icon: TabImage.timerIcon,
                viewController: rootVC
            ),
            coordinator: coordinator
        )
    }
}

