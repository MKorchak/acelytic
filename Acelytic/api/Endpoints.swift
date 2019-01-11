import Foundation

struct API {
    static let baseUrl = "http://172.16.67.141/"
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
