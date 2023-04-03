import Combine
import Foundation

// MARK: - Inputs

protocol AddReminderViewModelInputs {
    var titlePublisher: CurrentValueSubject<String, Never> { get }
    var descriptionPublisher: CurrentValueSubject<String, Never> { get }
    var datePublisher: CurrentValueSubject<Date, Never> { get }
    var savePublisher: PassthroughSubject<Void, Never> { get }
}

// MARK: - Outputs

protocol AddReminderViewModelOutputs {
    var alertPublisher: PassthroughSubject<Alert, Never> { get }
    var title: String { get }
    var saveButtonTitle: String { get }
    var titleFieldPlaceHolder: String { get }
    var descriptionFieldPlaceHolder: String { get }
}

// MARK: - ViewModel

protocol AddReminderViewModelType: AddReminderViewModelInputs,
                                   AddReminderViewModelOutputs { }

final class AddReminderViewModel: AddReminderViewModelType {
    
    // Outputs
    
    let title = "Add Reminder"
    let saveButtonTitle = "Save"
    let titleFieldPlaceHolder = "Add Title Here.."
    let descriptionFieldPlaceHolder = "Add Descriptiom Here..."
    let alertPublisher: PassthroughSubject<Alert, Never> = .init()
    
    // Inputs
    
    let titlePublisher: CurrentValueSubject<String, Never> = .init("")
    let descriptionPublisher: CurrentValueSubject<String, Never> = .init("")
    let datePublisher: CurrentValueSubject<Date, Never> = .init(Date())
    let savePublisher: PassthroughSubject<Void, Never> = .init()
    
    // Private Properties
    
    private var subscriptions: Set<AnyCancellable> = []
    private let scheduleNotification: PassthroughSubject<Reminder, Never> = .init()
    
    init(
        notificationService: NotificationSchedulingManagerProtocol,
        remindersService: RemindersStore,
        routePublisher: PassthroughSubject<RemindersRoutes, Never>
    ) {
        
        let isDateValid: CurrentValueSubject<Bool, Never> = .init(false)
        
        datePublisher
            .map {
                let minAcceptedDate = Date(timeIntervalSinceNow: 60)
                return ($0 >= minAcceptedDate)
            }
            .subscribe(isDateValid)
            .store(in: &subscriptions)
        
        savePublisher
            .map { [weak self] Void -> Bool in
                guard let self else { return false }
                guard isDateValid.value else { return false }
                let title = self.titlePublisher.value
                let description = self.descriptionPublisher.value
                let date = self.datePublisher.value
                
                let reminder = Reminder(
                    date: date,
                    detail: description,
                    title: title,
                    id: UUID().uuidString
                )
                
                self.scheduleNotification.send(reminder)
                remindersService.addReminder(reminder)
                return true
            }
            .sink(receiveCompletion: { completion in
                // handle error
            },
                  receiveValue: { isValid in
                isValid ?
                routePublisher.send(.dismissPresented) :
                self.alertPublisher.send(.init(
                    title: "Error",
                    message: "Kindly enter a date that is more than a minute away!",
                    actionTitle: "OK",
                    completion: nil
                ))
            })
            .store(in: &subscriptions)
        
        scheduleNotification
            .sink { reminder in
                let notification = Notification(
                    id: reminder.id,
                    title: reminder.title,
                    datetime: reminder.date.dateComponents,
                    timeInterval: Int(reminder.date.timeIntervalSinceNow),
                    body: reminder.detail
                )
                notificationService.requestSchedulingNotification(notification)
            }
            .store(in: &subscriptions)
    }
}
