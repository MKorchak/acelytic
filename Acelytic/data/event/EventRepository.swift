import Foundation
import RxSwift

class EventRepository {


    func logEvent(event: EventModel) -> Observable<Response> {
        return Observable.just(TimeChecker.shared)
                .do(onNext: {
                    try $0.checkTime()
                })
                .observeOn(MainScheduler.instance)
                .do(onError: { _ in
                    self.saveEventToDB(event: event)
                })
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .flatMap { _ in
                    self.internalSendEvent(event: event)
                }

    }

    //Call in background
    private func internalSendEvent(event: EventModel) -> Observable<Response> {
        return RemoteApiService.shared.saveEvents(events: [event])
                .observeOn(MainScheduler.instance)
                .do(onError: { _ in
                    self.saveEventToDB(event: event)
                })
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .flatMap {
                    self.internalSendEvents()
                            .ifEmpty(switchTo: Observable.just($0))
                }
    }

    //Call in background
    private func internalSendEvents() -> Observable<Response> {
        return Observable.just(EventLocalDataManager.shared.retrieveEventList())
                .filter {
                    !$0.isEmpty
                }
                .flatMap { events in
                    RemoteApiService.shared.saveEvents(events: events)
                            .observeOn(MainScheduler.instance)
                            .do(onNext: { response in
                                self.removeEvents(events: events)
                            })
                }
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }

    //Call in background
    private func removeEvents(events: [EventModel]) {
        do {
            try EventLocalDataManager.shared.removeEvents(events: events)
        } catch {

        }

    }

    //Call in background
    private func saveEventToDB(event: EventModel) {
        do {
            try insert(event: event)
        } catch {

        }
    }

    //Call in background
    private func insert(event: EventModel) throws {
        try EventLocalDataManager.shared.saveEvent(eventModel: event)
    }

}