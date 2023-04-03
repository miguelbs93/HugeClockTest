import Combine
import Foundation

protocol CitiesStore {
    func getCities() -> AnyPublisher<[City], Never>
}
