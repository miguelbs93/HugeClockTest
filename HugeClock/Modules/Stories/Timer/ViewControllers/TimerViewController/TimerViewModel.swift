import Combine
import Foundation

// MARK: - State

enum TimerState {
    case initial
    case paused
    case running
    case finished
}


// MARK: - Inputs

protocol TimerViewModelInputs {
    var duration: CurrentValueSubject<Int, Never> { get }
    var pausePublisher: PassthroughSubject<Void, Never> { get }
    var runPublisher: PassthroughSubject<Void, Never> { get }
    var cancelPublisher: PassthroughSubject<Void, Never> { get }
    var viewDidLoad: PassthroughSubject<Void, Never> { get }
}

// MARK: - Outputs
protocol TimerViewModelOutputs {
    var title: String { get }
    var state: CurrentValueSubject<TimerState, Never> { get }
    var timerPublisher: AnyPublisher<String, Never> { get }
    var errorPublisher: AnyPublisher<Alert, Never> { get }
}

// MARK: - ViewModel

protocol TimerViewModelType: TimerViewModelInputs,
                             TimerViewModelOutputs { }

final class TimerViewModel: TimerViewModelType {
    
    private struct Constants {
        static let timerID = "TimerAlertID"
    }
    
    // MARK: - Outputs
    
    let title = "Timer"
    let state: CurrentValueSubject<TimerState, Never> = .init(.initial)
    var timerPublisher: AnyPublisher<String, Never> {
        timerPipe.eraseToAnyPublisher()
    }
    var errorPublisher: AnyPublisher<Alert, Never> {
        errorPipe.eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    let pausePublisher: PassthroughSubject<Void, Never> = .init()
    let runPublisher: PassthroughSubject<Void, Never> = .init()
    let cancelPublisher: PassthroughSubject<Void, Never> = .init()
    let duration: CurrentValueSubject<Int, Never> = .init(0)
    let viewDidLoad: PassthroughSubject<Void, Never> = .init()
    
    // MARK: - Private Properties
    
    private let timerPipe: PassthroughSubject<String, Never> = .init()
    private let errorPipe: PassthroughSubject<Alert, Never> = .init()
    private var subscriptions = Set<AnyCancellable>()
    private var notificationManager: NotificationSchedulingManagerProtocol
    private var timer: Timer.TimerPublisher?
    private let timerStore: TimersStore
    private var timerModel: TimerModel? {
        didSet {
            guard let timerModel else { return }
            self.timerStore.addTimer(timerModel)
        }
    }
    
    init(
        notificationManager: NotificationSchedulingManagerProtocol,
        timerStore: TimersStore
    ) {
        self.timerStore = timerStore
        self.notificationManager = notificationManager
        
        // MARK: - Subscriptions
        
        // get existing timer:
        
        timerStore.getTimer()
            .sink { _ in
                // handle error
            } receiveValue: { [weak self] model in
                guard let self,
                      let model
                else { return }
                let elapsedTime = model.isPaused ? 0 : Int(Date().timeIntervalSince(model.startDate))
                guard elapsedTime >= 0 && elapsedTime < model.duration else { return }
                self.duration.value = model.duration - elapsedTime
                self.state.value = model.isPaused ? TimerState.paused : TimerState.running
                self.timerModel = model
                if !model.isPaused { self.resumeTimer() }
            }
            .store(in: &subscriptions)
        
        // Cancel
        
        cancelPublisher.sink(receiveValue: { [weak self] in
            self?.state.send(.initial)
            self?.stopTimer(isCancel: true)
        })
        .store(in: &subscriptions)
        
        // Pause
        
        pausePublisher.sink(receiveValue: { [weak self] in
            guard let self else { return }
            let state = self.state.value
            self.state.send(state == .paused ? .running : .paused)
            (state == .paused) ? self.resumeTimer() : self.stopTimer()
        })
        .store(in: &subscriptions)
        
        // Play
        
        runPublisher.sink(receiveValue: { [weak self] in
            guard let self else { return }
            self.state.send(.running)
            self.createTimer()
        })
        .store(in: &subscriptions)
        
        // duration
        
        duration
            .map { $0.timerStringRepresentation }
            .subscribe(timerPipe)
            .store(in: &subscriptions)
        
        // view did load
        /// Using this to know when the view loaded so i can send initial timer value
        viewDidLoad
            .sink(receiveValue: { [weak self] in
                guard let self else { return }
                self.timerPipe.send(self.duration.value.timerStringRepresentation)
            })
            .store(in: &subscriptions)
    }
}

// MARK: - Private Timer Functions

private extension TimerViewModel {
    func createTimer() {
        if timer != nil {
            timer?.connect().cancel()
        }
        resumeTimer()
    }
    
    func resumeTimer() {
        // updating timer value in db
        timerModel = TimerModel(
            duration: duration.value,
            isPaused: false,
            startDate: Date()
        )
        
        // restarting timer
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
        timer?
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self else { return }
                
                guard self.duration.value > 0 else {
                    self.state.send(.finished)
                    self.timer?.connect().cancel()
                    self.timerStore.deleteTimer()
                    return
                }
                
                self.duration.value -= 1
            }
            .store(in: &self.subscriptions)
        
        notificationManager.schedule(notification: Notification(
            id: Constants.timerID,
            title: "Alert",
            datetime: duration.value.dateComponent,
            timeInterval: duration.value,
            body: "Time is up!"
        ))
    }
    
    func stopTimer(isCancel: Bool = false) {
        timer?.connect().cancel()
        notificationManager.removeNotification(with: Constants.timerID)
        guard isCancel else {
            timerModel = timerModel?.with(isPaused: true, duration: duration.value)
            return
        }
        timerStore.deleteTimer()
    }
}
