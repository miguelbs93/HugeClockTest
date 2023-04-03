import Combine
import Foundation

protocol TimersStore {
    @discardableResult
    func addTimer(_ timer: TimerModel) -> AnyPublisher<TimerModel?, Error>
    func getTimer() -> AnyPublisher<TimerModel?, Error>
    @discardableResult
    func deleteTimer() -> AnyPublisher<Void, Error>
}
