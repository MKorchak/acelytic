import Foundation

class TimeChecker {

    static let shared = TimeChecker()

    private static let BPTime = 0.2

    private init(){

    }

    private var lastTime = Double(0)

    func checkTime() throws {
        if ((NSDate().timeIntervalSince1970 - lastTime) > TimeChecker.BPTime) {
            lastTime = NSDate().timeIntervalSince1970
        } else {
            throw AcelyticError.backPressureError
        }
    }
}