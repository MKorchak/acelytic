import Foundation

struct API {
    static var baseUrl = "http://acelytic.ace.date/"
}

protocol Endpoint {
    var path: String { get }
    var url: String { get }
}

enum Endpoints {

    enum SaveEvent: Endpoint {
        case fetch

        public var path: String {
            switch self {
            case .fetch: return "v1/event/save"
            }
        }

        public var url: String {
            switch self {
            case .fetch: return "\(API.baseUrl)\(path)"
            }
        }
    }
}

