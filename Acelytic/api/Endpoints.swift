import Foundation

struct API {
    static let baseUrl = "http://204.74.248.204/"
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

