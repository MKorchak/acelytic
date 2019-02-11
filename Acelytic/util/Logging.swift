import Foundation

class Logging {

    static let shared = Logging()

    var isEnabled = false

    func log(_ message: String){
        if(isEnabled) {
            print("📈 Acelytic: \(message)")
        }
    }
}

struct LoggingC {

    static let EVENT_LOGGED = "event_logged"
    static let EVENT_LOGGED_ERROR = "event_logged_error"
}