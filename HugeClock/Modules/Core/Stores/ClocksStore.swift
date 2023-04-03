import Combine
import Foundation

protocol ClocksStore {
    func addClock(for city: City) -> AnyPublisher<Clock?, Error>
    func getClock(for city: String) -> AnyPublisher<Clock?, Error>
    func getAllClocks() -> AnyPublisher<[Clock]?, Error>
    func deleteClock(for city: String) -> AnyPublisher<Void, Error>
    func deleteAllClocks() -> AnyPublisher<Void, Error>
    func updater() -> AnyPublisher<[Clock], Error>
}
