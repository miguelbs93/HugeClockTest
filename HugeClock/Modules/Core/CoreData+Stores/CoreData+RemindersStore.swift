import Combine
import Foundation

extension CoreDataStore: RemindersStore {
    @discardableResult
    func addReminder(_ reminder: Reminder) -> AnyPublisher<Reminder?, Error> {
        perform { context in
            ReminderDB.addReminder(reminder: reminder, in: context)?.reminder
        }
        .eraseToAnyPublisher()
    }

    func getReminder(with id: String) -> AnyPublisher<Reminder?, Error> {
        perform { context in
            let reminderDB = ReminderDB.getReminder(with: id, in: context)
            return reminderDB?.reminder
        }
        .eraseToAnyPublisher()
    }

    func getAllReminders() -> AnyPublisher<[Reminder]?, Error> {
        perform { context in
            ReminderDB.getReminders(in: context)?
                .map { $0.reminder }
        }
        .eraseToAnyPublisher()
    }

    func deleteReminder(with id: String) -> AnyPublisher<Void, Error> {
        perform { context in
            ReminderDB.deleteReminder(with: id, in: context)
        }
        .eraseToAnyPublisher()
    }

    func deleteAllReminders() -> AnyPublisher<Void, Error> {
        perform { context in
            ReminderDB.deleteAllReminders(in: context)
        }
        .eraseToAnyPublisher()
    }
    
    func updater() -> AnyPublisher<[Reminder], Error> {
        return CDPublisher(
            request: ReminderDB.fetchRequest(),
            context: backgroundContext
        )
        .map { $0.map { $0.reminder } }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
