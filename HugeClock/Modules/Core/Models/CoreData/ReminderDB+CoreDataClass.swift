import Foundation
import CoreData

@objc(ReminderDB)
public class ReminderDB: NSManagedObject {
    
    // MARK: - Getters
    
    class func getReminders(in context: NSManagedObjectContext) -> [ReminderDB]? {
        let request = fetchRequest()
        
        var reminders: [ReminderDB]?
        
        do  {
            reminders = try (context.fetch(request))
        } catch let error {
            print(error)
            return nil
        }
        
        return reminders
    }
    
    class func getReminder(with id: String, in context: NSManagedObjectContext) -> ReminderDB? {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        var reminders: [ReminderDB]?
        
        do  {
            reminders = try (context.fetch(request)) as [ReminderDB]
        } catch let error {
            print(error)
            return nil
        }
        
        guard let reminders,
              !reminders.isEmpty else { return nil }
        
        return reminders.last
    }
    
    // MARK: - Insertion
    
    class func addReminder(reminder: Reminder, in context: NSManagedObjectContext) -> ReminderDB? {
        var entity = ReminderDB.getReminder(
            with: reminder.id,
            in: context
        )
        
        // Create entity if nil
        
        if entity == nil {
            entity = NSEntityDescription.insertNewObject(
                forEntityName: "ReminderDB",
                into: context
            ) as? ReminderDB
            entity?.id = reminder.id
        }
        
        // Update fields
        
        entity?.date = reminder.date
        entity?.detail = reminder.detail
        entity?.title = reminder.title
        return entity
    }
    
    // MARK: - Deletion
    
    class func deleteReminder(with id: String, in context: NSManagedObjectContext) {
        guard let reminder = ReminderDB.getReminder(with: id, in: context) else {
            return
        }
        
        context.delete(reminder)
    }
    
    class func deleteAllReminders(in context: NSManagedObjectContext) {
        guard let reminders = ReminderDB.getReminders(in: context) else { return }
        for reminder in reminders {
            context.delete(reminder)
        }
    }
}
