import Combine
import Foundation

protocol WorldClockViewModelInputs {
    var addButtonPublisher: PassthroughSubject<Void, Never> { get }
}

protocol WorldClockViewModelOutputs {
    var clocks: AnyPublisher<[Clock], Never> { get }
    var emptyText: String { get }
    var maxClocks: Int { get }
    var timerPublisher: AnyPublisher<Date, Never> { get }
    var title: String { get }
}

protocol WorldClockViewModelType: WorldClockViewModelInputs,
                                  WorldClockViewModelOutputs { }

final class WorldClockViewModel: WorldClockViewModelType {
    // Outputs
    
    let title = "World Clock"
    let emptyText = "Keep track of the time in your favorite cities by pressing the + button on top"
    
    var clocks: AnyPublisher<[Clock], Never> {
        clocksPipe.eraseToAnyPublisher()
    }
    
    var timerPublisher: AnyPublisher<Date, Never> {
        timerPipe.eraseToAnyPublisher()
    }
    
    let maxClocks: Int
    
    // Inputs
    
    let addButtonPublisher: PassthroughSubject<Void, Never> = .init()
    
    // Private Properties
    
    private let clocksPipe = CurrentValueSubject<[Clock], Never>([])
    private let clockStore: ClocksStore
    private let routePublisher: PassthroughSubject<WorldClockRoutes, Never>
    private var subscriptions: Set<AnyCancellable> = []
    private let timer: Timer.TimerPublisher
    private let timerPipe: PassthroughSubject<Date, Never> = .init()
    
    init(
        clockStore: ClocksStore,
        maxClocks: Int = 4,
        routePublisher: PassthroughSubject<WorldClockRoutes, Never>
    ) {
        self.clockStore = clockStore
        self.maxClocks = maxClocks
        self.routePublisher = routePublisher
        
        timer = Timer
            .publish(
                every: 1,
                on: .main,
                in: .common
            )
        
        timer
            .autoconnect()
            .sink(receiveValue: { [weak self] date in
                self?.timerPipe.send(date)
            })
            .store(in: &subscriptions)
        
        addButtonPublisher
            .map { WorldClockRoutes.addClock }
            .subscribe(routePublisher)
            .store(in: &subscriptions)
        
        clockStore.updater()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // handle error
            }, receiveValue: { [weak self] clocks in
                self?.clocksPipe.send(clocks)
            })
            .store(in: &subscriptions)
    }
}
