import Foundation
import Alamofire

class TokenAdapter: RequestAdapter {

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue("1", forHTTPHeaderField: "Api-Key")

        return urlRequest
    }
}
