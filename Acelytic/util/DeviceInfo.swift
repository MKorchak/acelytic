import Foundation
import CoreTelephony
import ObjectMapper
import UIKit
import AdSupport
import CoreLocation

class DeviceInfo: Mappable, LocationServiceDelegate {

    var versionName = ""

    var osVersion = ""

    var osName = "IOS"

    var brand = "Apple"

    var carrierName = ""

    var model = ""

    var language = Locale.current.languageCode

    var deviceId = ""

    var latitude = ""

    var longitude = ""

    var adminArea = ""

    var city = ""

    var country = ""

    var locationService = LocationService()

    init() {
        carrierName = getCarrierName()
        versionName = getVersionName()
        osVersion = getOSInfo()
        model = UIDevice.current.modelName
        deviceId = getDeviceId()
    }

    required init?(map: Map) {

    }



    func mapping(map: Map) {
        versionName <- map["versionName"]
        osName <- map["osName"]
        brand <- map["brand"]
        carrierName <- map["carrierName"]
        model <- map["model"]
        language <- map["language"]
        deviceId <- map["deviceId"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        country <- map["country"]
        adminArea <- map["adminArea"]
        city <- map["city"]
    }

    func updateAddress(location: CLLocation, country: String, adminArea: String, city: String) {
        latitude = String(location.coordinate.latitude)
        longitude = String(location.coordinate.longitude)
        self.country = country
        self.adminArea = adminArea
        self.city = city
    }

    func startUpdateLocation(){
        locationService.setUp(delegate: self)
    }

    private func getVersionName() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    private func getCarrierName() -> String {
        return CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName ?? ""
    }

    private func getOSInfo() -> String {
        let os = ProcessInfo().operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }

    private func getDeviceId() -> String {
        return identifierForAdvertising() ?? UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    private func identifierForAdvertising() -> String? {
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
            return nil
        }

        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
}