import Combine
import CoreData
import Foundation

extension CoreDataStore: ClocksStore {
    func addClock(for city: City) -> AnyPublisher<Clock?, Error> {
        perform { context in
            ClockDB.addClock(for: city, in: context)?.clock
        }
        .eraseToAnyPublisher()
    }
    
    func getClock(for city: String) -> AnyPublisher<Clock?, Error> {
        perform { context in
            let entity = ClockDB.getClock(for: city, in: context)
            return entity?.clock
        }
        .eraseToAnyPublisher()
    }
    
    func getAllClocks() -> AnyPublisher<[Clock]?, Error> {
        perform { context in
            ClockDB.getClocks(in: context)?
                .map { $0.clock }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteClock(for city: String) -> AnyPublisher<Void, Error> {
        perform { context in
            ClockDB.deleteClock(for: city, in: context)
        }
        .eraseToAnyPublisher()
    }
    
    func deleteAllClocks() -> AnyPublisher<Void, Error> {
        perform { context in
            ClockDB.deleteAllClocks(in: context)
        }
        .eraseToAnyPublisher()
    }
    
    func updater() -> AnyPublisher<[Clock], Error> {
        return CDPublisher(
            request: ClockDB.fetchRequest(),
            context: backgroundContext
        )
        .map { $0.map { $0.clock } }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
