import Foundation
import CoreData
import RxSwift

class EventLocalDataManager {

    static let shared = EventLocalDataManager()

    private init(){

    }

    private func requestRetrieveEventList() -> Observable<[EventModel]> {
        return Observable.create { observer in
            CoreDataStore.shared.persistentContainer.performBackgroundTask { context in
                do {
                    let request: NSFetchRequest<AceEvent> = NSFetchRequest(entityName: "Event")
                    let events = try context.fetch(request)
                    let eventModels = try events.map {
                        EventModel(
                                name: $0.name ?? "",
                                properties: try JSONSerialization.jsonObject(with: ($0.properties?.data(using: .utf8))!) as! [String: Any],
                                time: $0.time,
                                id: $0.eventId ?? "")
                    }
                    observer.on(.next(eventModels))
                } catch {
                    observer.on(.error(error))
                }
            }
            return Disposables.create()
        }
    }

    private func requestSaveEvent(eventModel: EventModel) {
        CoreDataStore.shared.persistentContainer.performBackgroundTask { context in
            if let newEvent = NSEntityDescription.entity(forEntityName: "Event",
                    in: context) {
                do {
                    let event = AceEvent(entity: newEvent, insertInto: context)
                    event.name = eventModel.name
                    event.properties = try String(data: JSONSerialization.data(withJSONObject: eventModel.properties), encoding: .utf8)
                    event.time = eventModel.time
                    event.eventId = UUID().uuidString
                    try context.save()
                    Logging.shared.log("Event \(eventModel.name) saved to db")
                } catch {
                    Logging.shared.log("Event \(eventModel.name) saved to db error \(error)")
                }
            }
        }
    }

    private func requestRemoveEvents(events: [EventModel]) {
        CoreDataStore.shared.persistentContainer.performBackgroundTask { context in
            let ids = events.map {
                $0.id
            }
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
            fetch.predicate = NSPredicate(format: "eventId IN %@", ids)
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            do {
                let _ = try context.execute(request)
                Logging.shared.log("\(ids.count) events removed from db")
            } catch {
                Logging.shared.log("\(ids.count) events removed from db error")
            }
        }
    }

    func retrieveEventList() -> Observable<[EventModel]> {
        return requestRetrieveEventList().subscribeOn(MainScheduler.instance)
    }

    func saveEvent(eventModel: EventModel) -> Observable<EventModel> {
        return Observable.create { observable in
            self.requestSaveEvent(eventModel: eventModel)
            observable.on(.next(eventModel))
            return Disposables.create()
        }.subscribeOn(MainScheduler.instance)
    }

    func removeEvents(events: [EventModel]) -> Observable<[EventModel]> {
        return Observable.create { observable in
            self.requestRemoveEvents(events: events)
            observable.on(.next(events))
            return Disposables.create()
        }.subscribeOn(MainScheduler.instance)
    }
}
