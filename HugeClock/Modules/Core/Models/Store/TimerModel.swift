import Foundation

struct TimerModel {
    let duration: Int
    let isPaused: Bool
    let startDate: Date
}

extension TimerModel {
    /// Update  isPaused
    func with(
        isPaused: Bool,
        duration: Int? = nil,
        startDate: Date? = nil
    ) -> Self {
        .init(
            duration: duration ?? self.duration,
            isPaused: isPaused,
            startDate: startDate ?? self.startDate
        )
    }
    
    /// Update  elapsed time
    func with(duration: Int) -> Self {
        .init(
            duration: duration,
            isPaused: isPaused,
            startDate: startDate
        )
    }
}
