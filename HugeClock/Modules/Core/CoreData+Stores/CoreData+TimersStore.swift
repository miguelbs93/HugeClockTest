import Combine
import Foundation

extension CoreDataStore: TimersStore {
    @discardableResult
    func addTimer(_ timer: TimerModel) -> AnyPublisher<TimerModel?, Error> {
        perform { context in
            TimerDB.addTimer(timer, in: context)
                .map { $0.model }
        }
        .eraseToAnyPublisher()
    }
    
    func getTimer() -> AnyPublisher<TimerModel?, Error> {
        perform { context in
            TimerDB.getTimer(in: context)
                .map { $0.model }
        }
        .eraseToAnyPublisher()
    }
    
    @discardableResult
    func deleteTimer() -> AnyPublisher<Void, Error> {
        perform { context in
            TimerDB.deleteTimer(in: context)
        }
        .eraseToAnyPublisher()
    }
}
