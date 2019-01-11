import Foundation
import Alamofire

class ApiKeyAdapter: RequestAdapter {

    var apiKey: String = ""

    init(_ apiKey: String){
       self.apiKey = apiKey
    }

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        print("-----\(apiKey)-------")
        urlRequest.setValue(apiKey, forHTTPHeaderField: "Api-Key")

        return urlRequest
    }
}
