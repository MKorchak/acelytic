import Foundation
import CoreData

class CoreDataStore {

    static let shared = CoreDataStore()

    lazy var persistentContainer: NSPersistentContainer = {
//        let modelURL = Bundle(for: type(of: self)).url(forResource: "Acelytic", withExtension: "momd")!
//        let managedObjectModel = NSManagedObjectModel.mergedModel(from: nil)!

//        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        let container = NSPersistentContainer(name: "Acelytic")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in })
        return container
    }()


    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? =  {
        return persistentContainer.persistentStoreCoordinator
    }()

    lazy var managedObjectModel: NSManagedObjectModel? = {
        return persistentContainer.managedObjectModel
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        return self.persistentContainer.viewContext
    }()
}

