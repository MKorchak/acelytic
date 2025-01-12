import Foundation
import RxSwift
import RxAlamofire
import Alamofire
import ObjectMapper

class RemoteApiService {

    static let shared = RemoteApiService()

    private init(){

    }

    var apiKey: String = ""

    private lazy var sessionManager = getSessionManager()

    func saveEvents(events: [EventModel]) -> Observable<Response> {
        return sessionManager
                .requestRx(
                method: .post,
                url: Endpoints.SaveEvent.fetch.url,
                parameters: Mapper<EventModel>().toJSONDictionaryOfArrays(["events": events]),
                encoding: JSONEncoding.default
                )
    }
}


extension RemoteApiService {

    func getSessionManager() -> SessionManager {
        let sessionManager = SessionManager()
        sessionManager.adapter = ApiKeyAdapter(apiKey)
        return sessionManager
    }
}
