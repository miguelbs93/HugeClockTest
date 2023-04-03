import Combine
import Foundation

// MARK: - Inputs

protocol RemindersViewModelInputs {
    var addReminderPublisher: PassthroughSubject<Void, Never> { get }
}

// MARK: - Outputs

protocol RemindersViewModelOutputs {
    var title: String { get }
    var emptyText: String { get }
    var reminders: CurrentValueSubject<[Reminder], Never> { get }
}

// MARK: - ViewModel

protocol RemindersViewModelType: RemindersViewModelInputs,
                                 RemindersViewModelOutputs { }

final class RemindersViewModel: RemindersViewModelType {
    
    // Outputs
    
    let title = "Reminders"
    let emptyText = "Add a reminder and never forget to do your task!"
    let reminders: CurrentValueSubject<[Reminder], Never> = .init([])
    
    // Inputs
    
    let addReminderPublisher: PassthroughSubject<Void, Never> = .init()
    
    // Private Properties
    
    private let remindersService: RemindersStore
    private var subscriptions: Set<AnyCancellable> = []
    
    init(
        remindersService: RemindersStore,
        routeObserver: PassthroughSubject<RemindersRoutes, Never>
    ) {
        self.remindersService = remindersService
        
        remindersService.updater()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // handle error
            }, receiveValue: { [weak self] reminders in
                self?.reminders.send(reminders)
            })
            .store(in: &subscriptions)
        
        addReminderPublisher
            .map { RemindersRoutes.addReminder }
            .subscribe(routeObserver)
            .store(in: &subscriptions)
    }
}
