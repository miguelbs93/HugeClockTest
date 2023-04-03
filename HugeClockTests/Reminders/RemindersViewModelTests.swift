import Combine
import XCTest
@testable import HugeClock

final class RemindersViewModelTests: XCTestCase {
    private var sut: RemindersViewModelType!
    private var cancellable: [AnyCancellable]!
    private var routeOsberver: PassthroughSubject<RemindersRoutes, Never>!
    
    override func setUp() async throws {
        cancellable = []
        routeOsberver = .init()
        resetSUT(with: ReminderStoreMockUp())
    }
    
    override func tearDown() {
        sut = nil
        cancellable = []
        routeOsberver = nil
    }
    
    func resetSUT(with store: RemindersStore) {
        sut = RemindersViewModel(remindersService: store, routeObserver: routeOsberver)
    }
    
    func test_loadData_withItems() {
        let dataExpectation = expectation(description: "Waiting to retrieve data")
        
        sut.reminders
            .delay(for: 2, scheduler: DispatchQueue.main)
            .sink { values in
                guard values.count > 0 else { return }
                dataExpectation.fulfill()
            }
            .store(in: &cancellable)
        
        wait(for: [dataExpectation], timeout: 10)
        
        XCTAssertEqual(sut.reminders.value.count, 2)
        
        let reminder1 = sut.reminders.value[0]
        XCTAssertEqual(reminder1.title, "Groceries!")
        XCTAssertEqual(reminder1.detail, "Get Veggies & Fruits")
        XCTAssertEqual(reminder1.id, "123")
        
        let reminder2 = sut.reminders.value[1]
        XCTAssertEqual(reminder2.title, "Go to the gym")
        XCTAssertEqual(reminder2.detail, "Work on your chest today")
        XCTAssertEqual(reminder2.id, "1213")
    }
    
    func test_loadData_empty() {
        resetSUT(with: ReminderStoreEmptyDataMockUp())
        let dataExpectation = expectation(description: "Waiting to retrieve data")
        
        sut.reminders
            .sink { values in
                guard values.count == 0 else { return }
                dataExpectation.fulfill()
            }
            .store(in: &cancellable)
        
        wait(for: [dataExpectation], timeout: 10)
        
        XCTAssertEqual(sut.reminders.value.count, 0)
    }
    
    func test_addButtonPressed_Router() {
        let expectation = expectation(description: "Waiting to go to addReminder")
        routeOsberver
            .sink { route in
                XCTAssertEqual(route, .addReminder)
                expectation.fulfill()
            }
            .store(in: &cancellable)
        
        sut.addReminderPublisher.send()
        wait(for: [expectation], timeout: 5)
    }
}
