import Combine
import Foundation
@testable import HugeClock

class TimerStoreEmptyDataMockUp: TimersStore {
    @discardableResult
    func addTimer(_ timer: TimerModel) -> AnyPublisher<TimerModel?, Error> {
        CurrentValueSubject<TimerModel?, Error>(nil)
            .eraseToAnyPublisher()
    }
    
    func getTimer() -> AnyPublisher<TimerModel?, Error> {
        CurrentValueSubject<TimerModel?, Error>(nil)
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    func deleteTimer() -> AnyPublisher<Void, Error> {
        PassthroughSubject<Void, Error>()
            .eraseToAnyPublisher()
    }
}

class TimerStoreDataMockUp: TimerStoreEmptyDataMockUp {
    override func getTimer() -> AnyPublisher<TimerModel?, Error> {
        let timer = TimerModel(duration: 100, isPaused: false, startDate: Date())
        return CurrentValueSubject<TimerModel?, Error>(timer)
            .eraseToAnyPublisher()
    }
}

class TimerStoreDataPausedMockUp: TimerStoreEmptyDataMockUp {
    override func getTimer() -> AnyPublisher<TimerModel?, Error> {
        let timer = TimerModel(duration: 100, isPaused: true, startDate: Date())
        return CurrentValueSubject<TimerModel?, Error>(timer)
            .eraseToAnyPublisher()
    }
}
