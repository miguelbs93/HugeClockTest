import Combine
import Foundation

enum CityRoute {
    case didPick(city: City)
}

// MARK: - Dependencies

protocol CitiesListViewModelDependencies {
    var citiesService: CitiesStore { get }
}

// MARK: - Inputs

protocol CitiesListViewModelInputs {
    var citySelection: PassthroughSubject<City, Never> { get }
}

// MARK: - Outputs

protocol CitiesListViewModelOutputs {
    var title: String { get }
    var citiesPublisher: CurrentValueSubject<[City], Never> { get }
}

// MARK: - ViewModelType

protocol CitiesListViewModelType: CitiesListViewModelInputs,
                                  CitiesListViewModelOutputs,
                                  CitiesListViewModelDependencies { }

// MARK: - ViewModel

final class CitiesListViewModel: CitiesListViewModelType {
    let citiesService: CitiesStore
    
    // Outputs
    
    let title = "Choose a city"
    let citiesPublisher: CurrentValueSubject<[City], Never> = .init([])
    
    // Inputs
    
    let citySelection: PassthroughSubject<City, Never> = .init()
    
    private let clockStore: ClocksStore
    private var subscriptions: Set<AnyCancellable> = []
    
    init(
        citiesService: CitiesStore,
        clockStore: ClocksStore,
        routeObserver: PassthroughSubject<WorldClockRoutes, Never>
    ) {
        self.citiesService = citiesService
        self.clockStore = clockStore
        
        citiesService.getCities()
            .sink(receiveValue: { [weak self] cities in
                self?.citiesPublisher.send(cities)
            })
            .store(in: &subscriptions)
        
        citySelection
            .map { clockStore.addClock(for: $0) }
            .sink { clock in
            }
            .store(in: &subscriptions)
        
        citySelection
            .map { _ in
                return WorldClockRoutes.dismissPresented
            } //CityRoute.didPick(city: $0) }
            .subscribe(routeObserver)
            .store(in: &subscriptions)
    }
}
