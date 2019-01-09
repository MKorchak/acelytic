import Foundation
import ObjectMapper

struct EventModel: Mappable {

    var name: String
    var properties: [String: String]
    var time = NSDate().timeIntervalSince1970

    init?(map: Map) {
        setUp(map: map)
    }

    func setUp(map: Map) {
        name <- map["name"]
        properties <- map["properties"]
        time <- map["time"]
    }
}