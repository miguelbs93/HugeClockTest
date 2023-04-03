import UIKit

extension TabItem {
    
    fileprivate struct TabImage {
        static let clockIcon = "world-clock-tab"
    }
    
    static func makeWorldClockTabItem(dependencies: WorldClockCoordinatorDependencies) -> TabItem {
        let coordinator = WorldClockCoordinator(dependencies: dependencies)
        let rootVC = coordinator.navigationController
        return .init(
            context: .init(
                title: "World Clock",
                icon: TabImage.clockIcon,
                viewController: rootVC
            ),
            coordinator: coordinator
        )
    }
}
