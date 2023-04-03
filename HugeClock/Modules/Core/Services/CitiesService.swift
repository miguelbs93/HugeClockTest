import Combine
import Foundation

final class CitiesService: CitiesStore {
    func getCities() -> AnyPublisher<[City], Never> {
        return Future<[City], Never> { promise in
            let countries = TimeZone.knownTimeZoneIdentifiers.map { identifier in
                let name = identifier.split(separator: "/").last
                return City(name: "\(name ?? "")", timezoneIdentifier: identifier)
            }
            promise(.success(countries))
        }
        .eraseToAnyPublisher()
    }
}
