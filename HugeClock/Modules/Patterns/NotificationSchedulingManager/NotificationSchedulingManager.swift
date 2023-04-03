import UIKit
import UserNotifications

protocol NotificationSchedulingManagerProtocol {
    func getPendingNotifications()
    func requestAuthorization(with completion: @escaping (Bool) -> Void)
    func requestSchedulingNotification(_ notification: Notification)
    func schedule(notification: Notification)
    func removeNotification(with identifier: String)
}

final class NotificationSchedulingManager: NotificationSchedulingManagerProtocol {
    func getPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            for notification in notifications {
                print(notification)
            }
        }
    }
    
    func requestAuthorization(with completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            completion(granted == true && error == nil)
        }
    }
    
    func requestSchedulingNotification(_ notification: Notification) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self?.requestAuthorization { [weak self] granted in
                    if granted {
                        self?.schedule(notification: notification)
                    }
                }
            case .authorized, .provisional:
                self?.schedule(notification: notification)
                
            default:
                break // Do nothing
            }
        }
    }
    
    func schedule(notification: Notification)
    {
        let content      = UNMutableNotificationContent()
        content.title    = notification.title
        content.sound    = UNNotificationSound.default
        content.body     = notification.body
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(notification.timeInterval),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: notification.id,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            guard error == nil else { return }
            debugPrint("Notification scheduled! --- ID = \(notification.id)")
        }
    }
    
    func removeNotification(with identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

struct Notification {
    var id: String
    var title: String
    var datetime: DateComponents
    var timeInterval: Int
    var body: String
}
