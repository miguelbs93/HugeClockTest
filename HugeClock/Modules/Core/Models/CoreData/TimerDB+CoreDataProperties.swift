import Foundation
import CoreData

extension TimerDB {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TimerDB> {
        return NSFetchRequest<TimerDB>(entityName: "TimerDB")
    }

    @NSManaged public var duration: Int16
    @NSManaged public var isPaused: Bool
    @NSManaged public var startDate: Date
}

// MARK: - Get TimerModel

extension TimerDB {
    var model: TimerModel {
        TimerModel(
            duration: Int(duration),
            isPaused: isPaused,
            startDate: startDate
        )
    }
}
