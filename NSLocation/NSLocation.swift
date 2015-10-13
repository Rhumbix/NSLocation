import UIKit
import CoreLocation

public class NSLocation : NSObject, CLLocationManagerDelegate {
    
    let bestAccuracy = kCLLocationAccuracyNearestTenMeters
    let desiredAccuracy : CLLocationAccuracy
    var delegate : CLLocationManagerDelegate?  // We will call this delegate when we found location update that satisfies the requirements

    var consecutiveAccurateLocations = 0
    var consecutiveInaccurateLocations = 0
    var locationCount = 0
    
    var timer : NSTimer?
    
    public init(desiredAccuracy : CLLocationAccuracy) {
        self.desiredAccuracy = desiredAccuracy
    }

    public func start(delegate: CLLocationManagerDelegate!) {
        self.delegate = delegate
        self.locationManager.startUpdatingLocation()
    }
    
    public func stop() {
        self.locationManager.stopUpdatingLocation()
        self.delegate = nil
    }
    
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
        }()

    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        for location in locations {
            locationCount += 1
            
            NSLog(String(format: "%ld: %@", locationCount, location))
            
            
            if timer != nil {
                timer!.invalidate()
                timer = nil
            }
            
            if location.horizontalAccuracy > self.desiredAccuracy {
                consecutiveAccurateLocations = 0
                consecutiveInaccurateLocations += 1
                
                timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "timesUp", userInfo: nil, repeats: false)
                
            } else {
                consecutiveInaccurateLocations = 0
                consecutiveAccurateLocations += 1
                
                if let unwrappedDelegate = self.delegate {
                    unwrappedDelegate.locationManager!(self.locationManager, didUpdateLocations: [location])
                }
            }
            
            if consecutiveAccurateLocations > 10 {
                locationManager.desiredAccuracy = self.desiredAccuracy
                NSLog(String(format: "Setting to %@!", self.desiredAccuracy))
            }
            
            if consecutiveInaccurateLocations > 10 {
                locationManager.desiredAccuracy = self.bestAccuracy
                NSLog(String(format: "Setting to %@!", self.bestAccuracy))
            }
        }
    }
    
    func timesUp() {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        NSLog(String(format: "Setting to %@!", self.bestAccuracy))
    }
}
