import Combine
import XCTest
@testable import HugeClock

final class TimerViewModelTests: XCTestCase {
    private var sut: TimerViewModelType!
    private var cancellable: [AnyCancellable]!
    
    override func setUp() async throws {
        cancellable = []
        resetSUT(with: TimerStoreEmptyDataMockUp())
    }
    
    private func resetSUT(with mockup: TimersStore) {
        let notificationManager = NotificationSchedulingManager()
        let timerStore = mockup
        sut = TimerViewModel(
            notificationManager: notificationManager,
            timerStore: timerStore
        )
    }
    
    override func tearDown() {
        sut = nil
        cancellable = []
    }
    
    func test_timer_init() {
        XCTAssertEqual(sut.duration.value, 0)
        XCTAssertEqual(sut.state.value, .initial)
    }
    
    func test_didLoad_withExistingTimer_Paused() {
        resetSUT(with: TimerStoreDataPausedMockUp())
        XCTAssertEqual(sut.duration.value, 100)
        XCTAssertEqual(sut.state.value, .paused)
    }
    
    func test_didLoad_WithExistingTimer_Running() {
        resetSUT(with: TimerStoreDataMockUp())
        XCTAssertEqual(sut.duration.value, 100)
        XCTAssertEqual(sut.state.value, .running)
    }
    
    func test_timer_end() {
        let duration = 2
        sut.duration.value = duration
        
        XCTAssertEqual(sut.duration.value, duration)
        sut.runPublisher.send()
        XCTAssertEqual(sut.state.value, .running)
        
        let timerEndsExp = expectation(description: "Waiting till the timer finishes")
        
        sut.duration
            .sink { value in
                guard value == 0 else { return }
                timerEndsExp.fulfill()
            }
            .store(in: &cancellable)
        
        wait(for: [timerEndsExp], timeout: 30)
        XCTAssertEqual(sut.duration.value, 0)
        
        let stateChangeExp = expectation(description: "Waiting till the state changes")
        sut.state
            .dropFirst()
            .sink { state in
                XCTAssertEqual(state, .finished)
                stateChangeExp.fulfill()
            }
            .store(in: &cancellable)
        
        wait(for: [stateChangeExp], timeout: 20)
    }
    
    func test_timer_cancelled() {
        let duration = 300
        sut.duration.value = duration
        
        XCTAssertEqual(sut.duration.value, duration)
        sut.runPublisher.send()
        XCTAssertEqual(sut.state.value, .running)
        
        sut.cancelPublisher.send()
        XCTAssertEqual(sut.state.value, .initial)
    }
    
    func test_timer_paused() {
        let duration = 300
        sut.duration.value = duration
        
        XCTAssertEqual(sut.duration.value, duration)
        
        sut.runPublisher.send()
        XCTAssertEqual(sut.state.value, .running)
        
        let timerExp = expectation(description: "Waiting till the time elapse 5 seconds")
        
        sut.duration
            .sink { value in
                guard value == 295 else { return }
                timerExp.fulfill()
            }
            .store(in: &cancellable)
        
        wait(for: [timerExp], timeout: 10)
        sut.pausePublisher.send()
        XCTAssertEqual(sut.state.value, .paused)
        XCTAssertEqual(sut.duration.value, 295)
    }
    
    func test_timer_updateDates() {
        let someDuration = 120
        let expected = "02:00"
        
        XCTAssertEqual(someDuration.timerStringRepresentation, expected)
        let expectation = expectation(description: "Waiting for timerpublisher..")
        sut.timerPublisher
            .dropFirst()
            .sink { text in
                XCTAssertEqual(text, expected)
                expectation.fulfill()
            }
            .store(in: &cancellable)
        
        sut.duration.send(120)
        wait(for: [expectation], timeout: 5)
    }
}
