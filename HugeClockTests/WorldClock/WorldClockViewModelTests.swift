import Combine
import XCTest
@testable import HugeClock

final class WorldClockTests: XCTestCase {
    private var sut: WorldClockViewModelType!
    private var cancellable: [AnyCancellable]!
    private var routeObserver: PassthroughSubject<WorldClockRoutes, Never>!
    private var store: WorldClockMockup!
    
    override func setUp() async throws {
        cancellable = []
        routeObserver = .init()
        resetSUT(with: WorldClockMockup())
    }
    
    override func tearDown() {
        sut = nil
        cancellable = []
        routeObserver = nil
    }
    
    func resetSUT(with store: WorldClockMockup) {
        self.store = store
        sut = WorldClockViewModel(
            clockStore: store,
            routePublisher: routeObserver
        )
    }
    
    func test_loadData_withItems() {
        let dataExpectation = expectation(description: "Waiting to retrieve data")
        
        var clocks: [Clock] = []
        sut.clocks
            .delay(for: 2, scheduler: DispatchQueue.main)
            .sink { values in
                clocks = values
                guard values.count > 0 else { return }
                dataExpectation.fulfill()
            }
            .store(in: &cancellable)
        
        wait(for: [dataExpectation], timeout: 10)
        
        XCTAssertEqual(clocks.count, 2)
        
        let clock1 = clocks[0]
        XCTAssertEqual(clock1.city, "Auckland")
        XCTAssertEqual(clock1.timezoneIdentifier, "Pacific/Auckland")
        
        let clock2 = clocks[1]
        XCTAssertEqual(clock2.city, "Chatham")
        XCTAssertEqual(clock2.timezoneIdentifier, "Pacific/Chatham")
    }
    
    func test_loadData_empty() {
        resetSUT(with: WorldClockStoreEmptyMockup())
        let dataExpectation = expectation(description: "Waiting to retrieve data")
        
        var clocks: [Clock] = []
        sut.clocks
            .sink { values in
                clocks = values
                guard values.count == 0 else { return }
                dataExpectation.fulfill()
            }
            .store(in: &cancellable)
        
        wait(for: [dataExpectation], timeout: 10)
        
        XCTAssertEqual(clocks.count, 0)
    }
    
    func test_addButtonPressed_Router() {
        let expectation = expectation(description: "Waiting to go to addReminder")
        routeObserver
            .sink { route in
                XCTAssertEqual(route, .addClock)
                expectation.fulfill()
            }
            .store(in: &cancellable)
        
        sut.addButtonPublisher.send()
        wait(for: [expectation], timeout: 5)
    }
    
    func test_update_clocks() {
        let dataExpectation = expectation(description: "Waiting to retrieve data")
        
        var clocks: [Clock] = []
        sut.clocks
            .delay(for: 2, scheduler: DispatchQueue.main)
            .sink { values in
                clocks = values
                guard values.count > 0 else { return }
                dataExpectation.fulfill()
            }
            .store(in: &cancellable)
        
        wait(for: [dataExpectation], timeout: 10)
        
        XCTAssertEqual(clocks.count, 2)
        
        sut.timerPublisher
            .sink { [weak self] date in
                let clocksToBeUpdated = clocks.map { $0.getFormattedDate(from: date) }
                let date1 = self?.store.clocks.first?.getFormattedDate(from: date)
                let date2 = self?.store.clocks.last?.getFormattedDate(from: date)
                XCTAssertEqual(clocksToBeUpdated.first, date1)
                XCTAssertEqual(clocksToBeUpdated.last, date2)
            }
            .store(in: &cancellable)
    }
}
