import Foundation
import CoreData

extension ReminderDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReminderDB> {
        return NSFetchRequest<ReminderDB>(entityName: "ReminderDB")
    }

    @NSManaged public var date: Date
    @NSManaged public var detail: String?
    @NSManaged public var title: String?
    @NSManaged public var id: String
}

extension ReminderDB : Identifiable { }

// MARK: - Get Remminder

extension ReminderDB {
    var reminder: Reminder {
        Reminder(
            date: date,
            detail: detail ?? "",
            title: title ?? "",
            id: id
        )
    }
}
