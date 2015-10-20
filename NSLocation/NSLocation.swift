import UIKit
import CoreLocation

public class NSLocation : NSObject, CLLocationManagerDelegate {
    
    var delegate : CLLocationManagerDelegate?  // We will call this delegate when we found location update that satisfies the requirements
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    let startingAccuracy : CLLocationAccuracy
    let desiredAccuracy : CLLocationAccuracy
    let desiredIntervalInSeconds : Double
    
    var consecutiveInaccurateLocations = 0
    
    var intervalTimer : NSTimer?    //The timer for collecting locations at desired interval
    
    var updating : Bool = false  // CLLocationManager doesn't allow us to inquery if it's is still updating location, we need to use a boolean to track this state
    var updatingTimer : NSTimer?    // The timer to make sure CLLocationManager won't "forget about us", espcially when desiredAccuracy is too low

    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
        }()
    
    public init(desiredAccuracy: CLLocationAccuracy, desiredIntervalInSeconds: Double) {
        self.desiredAccuracy = desiredAccuracy
        self.startingAccuracy = desiredAccuracy * 3.0
        self.desiredIntervalInSeconds = desiredIntervalInSeconds

        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reinstateBackgroundTask"), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    public func start(delegate: CLLocationManagerDelegate!) {
        if self.delegate != nil {
            NSLog("Warning: start: call is ignored because location is already started")
            return
        }
        self.delegate = delegate
        
        self.resetintervalTimer()
    }
    
    public func stop() {
        self.locationManager.stopUpdatingLocation()
        self.updating = false
        self.delegate = nil
    }


    func resetintervalTimer() {
        if self.intervalTimer != nil {
            self.intervalTimer!.invalidate()
            self.intervalTimer = nil
        }
        self.intervalTimer = NSTimer.scheduledTimerWithTimeInterval(self.desiredIntervalInSeconds, target: self, selector: "getNextLocation", userInfo: nil, repeats: true)
        getNextLocation()
    }
    
    func getNextLocation() {
        if self.updating {
            NSLog("Still updating location. Skipping getNextLocation")
            return
        }

        NSLog("Start collecting next location")
        self.locationManager.desiredAccuracy = self.startingAccuracy
        NSLog(String(format: "Setting to %.0fm!", self.startingAccuracy))
        self.updating = true
        self.locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (self.backgroundTask == UIBackgroundTaskInvalid) { // this is called after we ended the background task. probably our last chance to start a new background task
            registerBackgroundTask()
            
            if !self.updating { // if not updating, we shut off the location update and do nothing
                NSLog("Not updating! This didUpdateLocation call is to daisy-chain background tasks. Stopping updateLocation")
                self.locationManager.stopUpdatingLocation()
                return
            }

        }

        for location in locations {
            NSLog(String(format: "%@", location))

            if NSDate().timeIntervalSinceDate(location.timestamp) > self.desiredIntervalInSeconds {
                NSLog(String(format: "Throwing away outdated location: %@", location.timestamp))
                continue
            }

            if self.updatingTimer != nil {
                self.updatingTimer!.invalidate()
                self.updatingTimer = nil
            }
            
            if location.horizontalAccuracy > self.desiredAccuracy {
                consecutiveInaccurateLocations += 1
                
                self.updatingTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "hasNotUpdatedLocationForTooLong", userInfo: nil, repeats: false)
                
            } else {
                consecutiveInaccurateLocations = 0

                if let unwrappedDelegate = self.delegate {
                    unwrappedDelegate.locationManager!(self.locationManager, didUpdateLocations: [location])
                    
                    if self.updating {
                        NSLog("Desired location found! Stopping updating location")
                        self.locationManager.stopUpdatingLocation()
                        self.updating = false
                    }
                }
            }

            if consecutiveInaccurateLocations > 5 {
                locationManager.desiredAccuracy = self.desiredAccuracy
                NSLog(String(format: "Setting to %.0fm!", self.desiredAccuracy))
            }
        }
    }
    
    func hasNotUpdatedLocationForTooLong() {
        locationManager.desiredAccuracy = self.desiredAccuracy
        NSLog(String(format: "Times up waiting for didUpdatingLocation. Setting to %.0fm!", self.desiredAccuracy))
    }
    
    
    // MARK: background tasks to wake up from sleep

    func registerBackgroundTask() {
        backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            [unowned self] in

            NSLog("Expiration handler called. Time remaining: %f", UIApplication.sharedApplication().backgroundTimeRemaining)

            if self.delegate != nil {
                NSLog("Restart updating location so that at least 1 didUpdateLocation call is guarantted")
                self.locationManager.stopUpdatingLocation()
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.startUpdatingLocation()
            }
            self.endBackgroundTask()
        }
        NSLog(String(format:"Background task %ld started!", backgroundTask))
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        NSLog(String(format:"Ending background task %ld.", backgroundTask))
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func reinstateBackgroundTask() {
        NSLog("Reinstating background task")
        if self.delegate != nil && (backgroundTask == UIBackgroundTaskInvalid) {
            registerBackgroundTask()
        }
    }
}
