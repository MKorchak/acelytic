import Foundation
import CoreData
import RxSwift

class EventLocalDataManager {
    static let shared = EventLocalDataManager()

    private func requestRetrieveEventList() throws -> [EventModel] {
        guard let managedOC = CoreDataStore.shared.managedObjectContext else {
            throw PersistenceError.managedObjectContextNotFound
        }

        let request: NSFetchRequest<AceEvent> = NSFetchRequest(entityName: "Event")
        let events = try managedOC.fetch(request)
        return try events.map {
            EventModel(
                    name: $0.name ?? "",
                    properties: try JSONSerialization.jsonObject(with: ($0.properties?.data(using: .utf8))!) as! [String: String],
                    time: $0.time,
                    id: $0.id ?? "")
        }
    }

    private func requestSaveEvent(eventModel: EventModel) throws {
        guard let managedOC = CoreDataStore.shared.managedObjectContext else {
            throw PersistenceError.managedObjectContextNotFound
        }

        if let newEvent = NSEntityDescription.entity(forEntityName: "Event",
                in: managedOC) {
            let event = AceEvent(entity: newEvent, insertInto: managedOC)
            event.name = eventModel.name
            event.properties = try String(data: JSONSerialization.data(withJSONObject: eventModel.properties), encoding: .utf8)
            event.time = eventModel.time
            event.id = UUID().uuidString
            try managedOC.save()
        } else {
            throw PersistenceError.couldNotSaveObject
        }
    }

    func retrieveEventList() -> [EventModel] {
        do {
            return try requestRetrieveEventList()
        } catch {
            return []
        }
    }

    func saveEvent(eventModel: EventModel) throws {
        try requestSaveEvent(eventModel: eventModel)
    }

    func removeEvents(events: [EventModel]) throws {
        guard let managedOC = CoreDataStore.shared.managedObjectContext else {
            throw PersistenceError.managedObjectContextNotFound
        }

        let ids = events.map {
            $0.id
        }
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        fetch.predicate = NSPredicate(format: "id IN %@", ids)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let _ = try managedOC.execute(request)
    }
}
