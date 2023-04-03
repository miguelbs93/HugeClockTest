import Foundation
import CoreData

@objc(TimerDB)
public class TimerDB: NSManagedObject {
    class func getTimer(in context: NSManagedObjectContext) -> TimerDB? {
        let request = fetchRequest()
        var entity: TimerDB?
        
        do  {
            entity = try (context.fetch(request)).first
        } catch let error {
            print(error)
            return nil
        }
        
        return entity
    }
    
    @discardableResult
    class func addTimer(_
                        timer: TimerModel,
                        in context: NSManagedObjectContext
    ) -> TimerDB? {
        var entity = TimerDB.getTimer(in: context)
        
        // Create entity if nil
        
        if entity == nil {
            entity = NSEntityDescription.insertNewObject(
                forEntityName: "TimerDB",
                into: context
            ) as? TimerDB
        }
        
        entity?.duration = Int16(timer.duration)
        entity?.startDate = timer.startDate
        entity?.isPaused = timer.isPaused
        return entity
    }
    
    class func deleteTimer(in context: NSManagedObjectContext) {
        guard let timer = getTimer(in: context) else { return }
        context.delete(timer)
    }
}
