import UIKit
import CoreLocation

public class NSLocation : NSObject, CLLocationManagerDelegate {
    var delegate : CLLocationManagerDelegate?  // We will call this delegate when we found location update that satisfies the requirements
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    let startingAccuracy : CLLocationAccuracy
    let desiredAccuracy : CLLocationAccuracy
    let desiredInterval : NSTimeInterval
    
    var intervalTimer : NSTimer?    //The timer for collecting locations at desired interval
    
    var updating : Bool = false  // CLLocationManager doesn't allow us to inquery if it's is still updating location, we need to use a boolean to track this state
    var updatingTimer : NSTimer?    // The timer to make sure CLLocationManager won't "forget about us", espcially when desiredAccuracy is too low

    
    var locationPicker : NSLocationPicker?

    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
        }()
    
    public init(desiredAccuracy: CLLocationAccuracy, desiredInterval: NSTimeInterval) {
        self.desiredAccuracy = desiredAccuracy
        self.startingAccuracy = desiredAccuracy * 3.0
        self.desiredInterval = desiredInterval

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
        self.locationManager.startMonitoringSignificantLocationChanges()

        self.resetintervalTimer()
    }
    
    public func stop() {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.stopMonitoringSignificantLocationChanges()
        self.endBackgroundTask()
        self.updating = false
        self.delegate = nil
    }


    func resetintervalTimer() {
        if self.intervalTimer != nil {
            self.intervalTimer!.invalidate()
            self.intervalTimer = nil
        }
        self.intervalTimer = NSTimer.scheduledTimerWithTimeInterval(self.desiredInterval, target: self, selector: "getNextLocation", userInfo: nil, repeats: true)
        getNextLocation()
    }
    
    func getNextLocation() {
        if self.updating {
            NSLog("Still updating location. Skipping getNextLocation")
            return
        }

        NSLog("Start collecting next location")
        
        self.locationPicker = NSLocationPicker(maximumSamples: 10, desiredAccuracy: self.desiredAccuracy, longestInterval: self.desiredInterval)
        
        self.locationManager.desiredAccuracy = self.startingAccuracy
        NSLog(String(format: "Setting accuracy to %.0fm!", self.startingAccuracy))
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
            NSLog(String(format: "updating: %@ --- location: %@", self.updating, location))

            if self.updatingTimer != nil {
                self.updatingTimer!.invalidate()
                self.updatingTimer = nil
            }
            
            if let unwrappedLocation = self.locationPicker!.pick(location) {

                if let unwrappedDelegate = self.delegate {
                    if self.updating {
                        NSLog("Desired location found! Stopping updating location")
                        unwrappedDelegate.locationManager!(self.locationManager, didUpdateLocations: [unwrappedLocation])
                        self.locationManager.stopUpdatingLocation()
                        self.updating = false
                    }

            } else {

                if self.updating {
                    locationManager.desiredAccuracy = self.desiredAccuracy
                    NSLog(String(format: "Setting accuracy to %.0fm!", self.desiredAccuracy))
                    self.updatingTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "hasNotUpdatedLocationForTooLong", userInfo: nil, repeats: false)
                }

            }
        }
    }
    
    func hasNotUpdatedLocationForTooLong() {
        if !self.updating {
            return
        }
        locationManager.desiredAccuracy = self.desiredAccuracy
        NSLog(String(format: "Times up waiting for didUpdatingLocation. Setting accuracy to %.0fm!", self.desiredAccuracy))
    }
    
    
    // MARK: background tasks to wake up from sleep

    func registerBackgroundTask() {
        backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            [unowned self] in
            NSLog("Expiration handler called! Time remaining: %f", UIApplication.sharedApplication().backgroundTimeRemaining)
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
        NSLog(String(format:"Background task %ld started!", backgroundTask))

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            while true {
                let timeRemaining = UIApplication.sharedApplication().backgroundTimeRemaining
                NSLog(String(format:"backgroundTimeRemaining: %f", timeRemaining))
                if timeRemaining < 30.0 {
                    self.backgroundTaskAboutToExpire()
                    return
                }
                sleep(5)
            }
        }
    }

    func backgroundTaskAboutToExpire() {
        NSLog("backgroundTaskAboutToExpire called. Time remaining: %f", UIApplication.sharedApplication().backgroundTimeRemaining)
        
        if self.delegate != nil {
            NSLog("Restart updating location so that at least 1 didUpdateLocation call is guarantted")
            if self.updating {
                self.locationManager.stopUpdatingLocation()
            }
            self.locationManager.startUpdatingLocation()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        self.endBackgroundTask()
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
