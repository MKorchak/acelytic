import Foundation
import ObjectMapper

struct NetworkError: Mappable {
    var message: String = ""

    init?(map: Map) {

    }

    init(_ message: String) {
        self.message = message
    }

    mutating func mapping(map: Map) {
        message <- map["message"]
    }
}