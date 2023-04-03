import Combine
import CoreData

public final class CoreDataStore {
    private static let modelName = "HugeClock"
    private static let pathComponent = "huge-clock-store.sqlite"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataStore.self))
    
    public var mainContext: NSManagedObjectContext { container.viewContext }
    public let backgroundContext: NSManagedObjectContext
    public let container: NSPersistentContainer
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL) throws {
        let storeURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("huge-clock-store.sqlite")
        
        guard let model = CoreDataStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataStore.modelName, model: model, url: storeURL)
            backgroundContext = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }

    public func perform<T>(_ block: @escaping (NSManagedObjectContext) -> T) -> AnyPublisher<T, Error> {
        Future<T, Error> { [weak self] promise in
            guard let self else { return }
            let context = self.backgroundContext
            context.perform {
                let result = block(context)
                
                guard context.hasChanges else {
                    promise(.success(result))
                    return
                }
                
                do {
                    try context.save()
                    promise(.success(result))
                } catch {
                    context.rollback()
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
