import Foundation
import CoreData

@objc(ClockDB)
public class ClockDB: NSManagedObject {

    // MARK: - Getters
    
    class func getClocks(in context: NSManagedObjectContext) -> [ClockDB]? {
        let request = fetchRequest()
        
        var clocks: [ClockDB]?
        
        do  {
            clocks = try (context.fetch(request))
        } catch let error {
            print(error)
            return nil
        }
        
        return clocks
    }
    
    class func getClock(for city: String, in context: NSManagedObjectContext) -> ClockDB? {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "city == %@", city)
        
        var clocks: [ClockDB]?
        
        do  {
            clocks = try (context.fetch(request)) as [ClockDB]
        } catch let error {
            print(error)
            return nil
        }
        
        guard let clocks,
              !clocks.isEmpty else { return nil }
        
        return clocks.last
    }
    
    // MARK: - Insertion
    
    class func addClock(for city: City, in context: NSManagedObjectContext) -> ClockDB? {
        var entity = Self.getClock(
            for: city.name,
            in: context
        )
        
        // Create entity if nil
        
        if entity == nil {
            entity = NSEntityDescription.insertNewObject(
                forEntityName: "ClockDB",
                into: context
            ) as? ClockDB
            entity?.city = city.name
        }
        
        // Update fields
        
        entity?.timezoneIdentifier = city.timezoneIdentifier
        return entity
    }
    
    // MARK: - Deletion
    
    class func deleteClock(for city: String, in context: NSManagedObjectContext) {
        guard let entity = ClockDB.getClock(for: city, in: context) else {
            return
        }
        context.delete(entity)
    }
    
    class func deleteAllClocks(in context: NSManagedObjectContext) {
        guard let entities = ClockDB.getClocks(in: context) else { return }
        for entity in entities {
            context.delete(entity)
        }
    }
}
