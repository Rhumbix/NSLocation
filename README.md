# NSLocation - No-Sweat Location Service for iOS
Collecting locations at specified interval and accuracy even when the app is in background mode.

iOS location service can be pain-in-the-ass to work with, especially when your app wants to collect location while in background. This package is to provide a No-Sweat way to accomplish it while minimizing battery consumption.

# How to use it

## Enable backround mode in Info.plist
Add entries to Info.plist as shown in ![this screenshot](https://cloud.githubusercontent.com/assets/779786/13442091/676dc918-dfaf-11e5-974a-a3c598b49e37.png?raw=true "Turn on background mode")

## Add the following to your code

    ...
    import CoreLocation
    import NSLocation
    ...
    
        // In your ViewController
        var locationMgr : NSLocation?
    
        ...
    
        // turn on NSLocation
        self.locationMgr = NSLocation(desiredAccuracy: kCLLocationAccuracyNearestTenMeters, desiredInterval: 60.0*10)
        self.locationMgr!.start(self)
    
        ...
    
        // turn off NSLocation
        self.locationMgr!.stop()
        self.locationMgr = nil
    
        ...
    
        // Delegate to receive location update
        func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
          // Your location processing code here
    
        }
    
# How to test it
* Open Example/NSLocationExample/ in your xcode. 
* In xcode choose NSLocationExample scheme.
* Run it in an iOS device.
* In "Auto Location" tab, switch on the toggle on the top-left corner to activate location service
