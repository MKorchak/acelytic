import Foundation

class TimeChecker {

    static let shared = TimeChecker()

    private var lastTime = Double(0)

    func checkTime() throws {
        if ((NSDate().timeIntervalSince1970 - lastTime) > 3.0) {
            lastTime = NSDate().timeIntervalSince1970
        } else {
            throw BackpressureError.error
        }
    }
}