import Combine
import Foundation

protocol RemindersStore {
    @discardableResult
    func addReminder(_ reminder: Reminder) -> AnyPublisher<Reminder?, Error>
    func getReminder(with id: String) -> AnyPublisher<Reminder?, Error>
    func getAllReminders() -> AnyPublisher<[Reminder]?, Error>
    func deleteReminder(with id: String) -> AnyPublisher<Void, Error>
    func deleteAllReminders() -> AnyPublisher<Void, Error>
    func updater() -> AnyPublisher<[Reminder], Error>
}
