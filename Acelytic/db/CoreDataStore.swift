import Foundation
import CoreData

class CoreDataStore {

    static let shared = CoreDataStore()

    lazy var persistentContainer: NSPersistentContainer  = {
        let modelURL = Bundle(for: type(of: self)).url(forResource: "Acelytic", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
        let container = NSPersistentContainer(name: "Acelytic", managedObjectModel: managedObjectModel)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in})
        return container
    }()
}

