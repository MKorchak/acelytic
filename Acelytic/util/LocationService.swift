import Foundation
import CoreLocation

class LocationService: NSObject {

    let locationManager = CLLocationManager()

    let geocoder = CLGeocoder()

    private weak var delegate: LocationServiceDelegate?

    func setUp(delegate: LocationServiceDelegate?) {
        self.delegate = delegate
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {
            return
        }
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in

            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }

            if (placemarks?.count)! > 0 {
                let pm = placemarks?[0]
                self.delegate?.updateAddress(location: location,
                        country: pm?.country ?? "",
                        adminArea: pm?.administrativeArea ?? "",
                        city: pm?.locality ?? "")
                self.locationManager.stopUpdatingLocation()
            }
        })
    }
}

protocol LocationServiceDelegate: class {

    func updateAddress(location: CLLocation, country: String, adminArea: String, city: String)
}