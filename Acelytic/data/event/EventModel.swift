import Foundation
import ObjectMapper

class EventModel: Mappable {

    var name: String = ""
    var properties: [String: String] = [:]
    var time = NSDate().timeIntervalSince1970
    var id: String = ""

    init(name: String = "",
         properties: [String: String] = [:],
         time: Double = 0,
         id: String = "") {

        self.name = name
        self.properties = properties
        self.time = time
        self.id = id
    }

    init(name: String = "",
         properties: [String: String] = [:]) {

        self.name = name
        self.properties = properties
    }

    func mapping(map: Map) {
        name <- map["name"]
        properties <- map["properties"]
        time <- map["time"]
    }

    required init?(map: Map) {

    }
}

