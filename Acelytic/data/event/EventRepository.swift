import Foundation
import RxSwift

class EventRepository {

    private var userProperties: [String: Any]?
    
    func setUserProperties(_ userProperties: [String: Any]) {
        UserPropertiesLocalDataManager.shared.saveUserProperties(userProperties)
        self.userProperties = userProperties
    }
    
    func clearUserProperties() {
        UserPropertiesLocalDataManager.shared.clearUserProperties()
        userProperties = nil
    }
    
    func logEvent(event: EventModel) -> Observable<Response> {
        eventWithUserProperties(event)
            .asObservable()
            .flatMap { event -> Observable<Response> in
                Observable.just(TimeChecker.shared)
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
                .flatMap { [weak self] in self?.eventsWithUserProperties($0) ?? .just($0) }
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
    
    private func eventWithUserProperties(_ event: EventModel) -> Single<EventModel> {
        getUserProperties().map {
            event.properties[C.ACE_USER] = $0
            
            return event
        }
    }
    
    private func eventsWithUserProperties(_ events: [EventModel]) -> Single<[EventModel]> {
        getUserProperties().map { properties in
            events.map {
                $0.properties[C.ACE_USER] = properties
                
                return $0
            }
        }
    }
    
    private func getUserProperties() -> Single<[String: Any]> {
        (userProperties.map(Maybe.just) ?? Maybe.empty())
            .ifEmpty(
                switchTo: UserPropertiesLocalDataManager
                    .shared
                    .fetchUserProperties()
                    .do(onNext: { [weak self] in self?.userProperties = $0 })
            )
            .ifEmpty(default: [:])
            .catchErrorJustReturn([:])
    }
}
