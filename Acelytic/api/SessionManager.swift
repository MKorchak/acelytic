import Foundation
import ObjectMapper
import RxSwift
import Alamofire


extension SessionManager {

    func request<M: Mappable>(_ method: Alamofire.HTTPMethod,
                              _ url: URLConvertible,
                              parameters: [String: Any]? = nil,
                              encoding: ParameterEncoding = URLEncoding.default,
                              headers: [String: String]? = nil) -> Observable<M> {
        return rx
                .request(method, url, parameters: parameters, encoding: encoding, headers: headers)
                .responseJSON()
                .flatMap { response -> Observable<Any> in
                    if ((200..<300).contains(response.response?.statusCode ?? 0)) {
                        return Observable.just(response.value ?? "{}")
                    } else {
                        guard let networkError = Mapper<NetworkError>().map(JSONObject: response.value ?? "{}")?.toJSON() else {
                            throw NSError(domain: "UnexpectedError", code: -1, userInfo: NetworkError("UnexpectedError").toJSON())
                        }
                        let error = NSError(domain: "ServerError", code: response.response?.statusCode ?? 0, userInfo: networkError)

                        return Observable.error(error)
                    }

                }
                .mapObject(type: M.self)
    }
}
