import Combine
import Foundation
@testable import HugeClock

class ReminderStoreMockUp: RemindersStore {
    func addReminder(_ reminder: Reminder) -> AnyPublisher<Reminder?, Error> {
        CurrentValueSubject<Reminder?, Error>(reminder).eraseToAnyPublisher()
    }
    
    func getReminder(with id: String) -> AnyPublisher<Reminder?, Error> {
        let reminder = Reminder(date: Date(timeIntervalSinceNow: 100), detail: "Get Veggies & Fruits", title: "Groceries!", id: id)
        return CurrentValueSubject<Reminder?, Error>(reminder).eraseToAnyPublisher()
    }
    
    func getAllReminders() -> AnyPublisher<[Reminder]?, Error> {
        let reminder = Reminder(date: Date(timeIntervalSinceNow: 100), detail: "Get Veggies & Fruits", title: "Groceries!", id: "123")
        let reminder2 = Reminder(date: Date(timeIntervalSinceNow: 120), detail: "Work on your chest today", title: "Go to the gym", id: "1213")
        let reminders = [reminder, reminder2]
        return CurrentValueSubject<[Reminder]?, Error>(reminders).eraseToAnyPublisher()
    }
    
    func deleteReminder(with id: String) -> AnyPublisher<Void, Error> {
        PassthroughSubject<Void, Error>().eraseToAnyPublisher()
    }
    
    func deleteAllReminders() -> AnyPublisher<Void, Error> {
        PassthroughSubject<Void, Error>().eraseToAnyPublisher()
    }
    
    func updater() -> AnyPublisher<[Reminder], Error> {
        return CurrentValueSubject<[Reminder], Error>(self.reminders).eraseToAnyPublisher()
    }
    
}

extension ReminderStoreMockUp {
    var reminders: [Reminder] {
        let reminder = Reminder(date: Date(timeIntervalSinceNow: 100), detail: "Get Veggies & Fruits", title: "Groceries!", id: "123")
        let reminder2 = Reminder(date: Date(timeIntervalSinceNow: 120), detail: "Work on your chest today", title: "Go to the gym", id: "1213")
        return [reminder, reminder2]
    }
}

class ReminderStoreEmptyDataMockUp: ReminderStoreMockUp {
    override func getAllReminders() -> AnyPublisher<[Reminder]?, Error> {
        return CurrentValueSubject<[Reminder]?, Error>([]).eraseToAnyPublisher()
    }
    
    override func updater() -> AnyPublisher<[Reminder], Error> {
        return CurrentValueSubject<[Reminder], Error>([]).eraseToAnyPublisher()
    }
}
