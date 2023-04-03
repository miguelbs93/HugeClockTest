import Foundation
import CoreData

extension ClockDB {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClockDB> {
        return NSFetchRequest<ClockDB>(entityName: "ClockDB")
    }

    @NSManaged public var city: String?
    @NSManaged public var timezoneIdentifier: String?
}

extension ClockDB : Identifiable { }

// MARK: - Clock Getter

extension ClockDB {
    var clock: Clock {
        Clock(
            city: city ?? "",
            timezoneIdentifier: timezoneIdentifier ?? ""
        )
    }
}
