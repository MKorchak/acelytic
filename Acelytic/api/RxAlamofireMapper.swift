import Foundation
import RxSwift
import ObjectMapper
import Alamofire


extension ObservableType {

    public func mapObject<T: Mappable>(type: T.Type) -> Observable<T> {
        return flatMap { data -> Observable<T> in
            let json = data as AnyObject?
            guard let object = Mapper<T>().map(JSONObject: json) else {
                throw NSError(
                        domain: "",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "ObjectMapper can't mapping"]
                )
            }

            return Observable.just(object)
        }
                .catchError { error -> Observable<T> in
                    return Observable.error(error)
                }
    }

    public func mapArray<T: Mappable>(type: T.Type) -> Observable<[T]> {
        return flatMap { data -> Observable<[T]> in
            let json = data as AnyObject?
            guard let objects = Mapper<T>().mapArray(JSONObject: json) else {
                throw NSError(
                        domain: "",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "ObjectMapper can't mapping"]
                )
            }

            return Observable.just(objects)
        }
    }
}
