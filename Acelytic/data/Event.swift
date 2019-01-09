import Foundation
import CoreData

class Event: NSManagedObject {

}

extension Event {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Evente>(entityName: "Event");
    }

    @NSManaged public var name: String
    @NSManaged public var properties: [String: String]
    @NSManaged public var time: Double
    @NSManaged public var id: Int32
}