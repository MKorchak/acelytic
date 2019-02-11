import Foundation
import RxSwift

class EventRepository {


    func logEvent(event: EventModel) -> Observable<Response> {
        return Observable.just(TimeChecker.shared)
                .do(onNext: {
                    try $0.checkTime()
                })
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .catchError { error in
                    Logging.shared.log("Event \(event.name) logged error \(error)")
                    return EventLocalDataManager.shared.saveEvent(eventModel: event)
                            .flatMap { _ in
                                Observable<TimeChecker>.error(error)
                            }
                }
                .flatMap { [weak self] _ in
                    self?.internalSendEvent(event: event) ?? Observable.error(AcelyticError.unexpectedError)
                }

    }

    //Call in background
    private func internalSendEvent(event: EventModel) -> Observable<Response> {
        return RemoteApiService.shared.saveEvents(events: [event])
                .catchError { error in
                    Logging.shared.log("Event \(event.name) logged error \(error)")
                    return EventLocalDataManager.shared.saveEvent(eventModel: event)
                            .flatMap { _ in
                                Observable<Response>.error(error)
                            }
                }
                .do(onNext: { _ in
                    Logging.shared.log("Event \(event.name) logged success")
                })
                .flatMap { [weak self] in
                    (self?.internalSendEvents() ?? .empty())
                            .ifEmpty(switchTo: Observable.just($0))
                }
    }

    //Call in background
    private func internalSendEvents() -> Observable<Response> {
        return EventLocalDataManager.shared.retrieveEventList()
                .do(onNext: { events in
                    Logging.shared.log("\(events.count) events retrieved from db")
                })
                .filter {
                    !$0.isEmpty
                }
                .flatMap { events in
                    RemoteApiService.shared.saveEvents(events: events)
                            .do(onError: { error in
                                Logging.shared.log("\(events.count) events logged error \(error)")
                            })
                            .flatMap { response in
                                EventLocalDataManager.shared.removeEvents(events: events).flatMap { _ in Observable.just(response) }
                            }
                }
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }

}