import Foundation
import RxSwift
import RxAlamofire
import Alamofire
import ObjectMapper

class RemoteApiService: RemoteApiServiceProtocol {

    private lazy var sessionManager = getSessionManager()

    func saveEvents(events: [EventModel]) -> Observable<Response> {
        return sessionManager
                .request(.post, parameters: events.map {
            Mapper<EventModel>.map(JSON: events)
        }, Endpoints.SaveEvent.fetch.url)
    }
}

protocol RemoteApiServiceProtocol {

    func saveEvents(event: [EventModel]) -> Observable<Response>
}


extension RemoteApiServiceProtocol {

    func getSessionManager() -> SessionManager {
        let sessionManager = SessionManager()
        sessionManager.adapter = TokenAdapter()
        return sessionManager
    }
}
