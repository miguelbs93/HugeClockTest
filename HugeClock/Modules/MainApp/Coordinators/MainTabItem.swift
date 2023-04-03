import UIKit

struct TabContext {
    let title: String
    let icon: String
    let viewController: UIViewController
    
    init(
        title: String,
        icon: String,
        viewController: UIViewController
    ) {
        self.title = title
        self.icon = icon
        self.viewController = viewController
    }
}

struct TabItem {
    let context: TabContext
    let coordinator: Coordinator
    
    init(context: TabContext, coordinator: Coordinator) {
        self.context = context
        self.coordinator = coordinator
    }
}
