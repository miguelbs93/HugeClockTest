import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appCoordinator: MainTabBarCoordinator!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        UNUserNotificationCenter.current().delegate = self
        let navigationController: UINavigationController = .init()
        
        window = UIWindow(windowScene: windowScene)
        appCoordinator = MainCoordinatorFactory().makeMainTabCoordinator(navigationController, window: window)
        appCoordinator.start()
    }
}

//MARK: - Notification Delegate

extension SceneDelegate: UNUserNotificationCenterDelegate {

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        //if app is in foreground
        self.handleNotification(notification: notification)
    }
    
    func handleNotification(notification: UNNotification) {
        DispatchQueue.main.async { [weak self] in
            let title = notification.request.content.title
            let description = notification.request.content.body
            self?.appCoordinator.showError(Alert(
                title: title,
                message: description,
                actionTitle: "OK",
                completion: nil)
            )
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //opened app through notification
        self.handleNotification(notification: response.notification)
    }
}
