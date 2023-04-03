import Combine
import Foundation
@testable import HugeClock

class WorldClockMockup: ClocksStore {
    func addClock(for city: City) -> AnyPublisher<Clock?, Error> {
        let clock = Clock(city: city.name, timezoneIdentifier: city.timezoneIdentifier)
        return CurrentValueSubject<Clock?, Error>(clock).eraseToAnyPublisher()
    }
    
    func getClock(for city: String) -> AnyPublisher<Clock?, Error> {
        let clock = Clock(city: city, timezoneIdentifier: "Pacific/Auckland")
        return CurrentValueSubject<Clock?, Error>(clock).eraseToAnyPublisher()
    }
    
    func getAllClocks() -> AnyPublisher<[Clock]?, Error> {
        return CurrentValueSubject<[Clock]?, Error>(clocks).eraseToAnyPublisher()
    }
    
    func deleteClock(for city: String) -> AnyPublisher<Void, Error> {
        PassthroughSubject<Void, Error>().eraseToAnyPublisher()
    }
    
    func deleteAllClocks() -> AnyPublisher<Void, Error> {
        PassthroughSubject<Void, Error>().eraseToAnyPublisher()
    }
    
    func updater() -> AnyPublisher<[Clock], Error> {
        return CurrentValueSubject<[Clock], Error>(clocks).eraseToAnyPublisher()
    }
}

extension WorldClockMockup {
    var clocks: [Clock] {
        [
            Clock(city: "Auckland", timezoneIdentifier: "Pacific/Auckland"),
            Clock(city: "Chatham", timezoneIdentifier: "Pacific/Chatham")
        ]
    }
}

class WorldClockStoreEmptyMockup: WorldClockMockup {
    override func getAllClocks() -> AnyPublisher<[Clock]?, Error> {
        return CurrentValueSubject<[Clock]?, Error>([]).eraseToAnyPublisher()
    }

    override func updater() -> AnyPublisher<[Clock], Error> {
        return CurrentValueSubject<[Clock], Error>([]).eraseToAnyPublisher()
    }
}
