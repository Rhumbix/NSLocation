//
//  FetchViewController.swift
//  TheBackgrounder
//
//  Created by Ray Fix on 12/9/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import NSLocation

class FetchViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationPicker : NSLocationPicker?
    
    var updatingTimer : NSTimer?    // The timer to make sure CLLocationManager won't "forget about us", espcially when desiredAccuracy is too low

    var updating = false
    
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
        }()
    
    @IBAction func enabledChanged(sender: UISwitch) {
        if sender.on {
            self.start()
        } else {
            self.stop()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            NSLog(String(format: "updating: %@ --- location: %@", self.updating, location))
            
            if self.updatingTimer != nil {
                self.updatingTimer!.invalidate()
                self.updatingTimer = nil
            }

            if let unwrappedLocation = self.locationPicker!.pick(location) {
                
                if self.updating {
                    self.mapView.addAnnotations(locations.map
                        { (loc: CLLocation) -> MKPointAnnotation in
                            let anno = MKPointAnnotation()
                            anno.coordinate = loc.coordinate
                            return anno
                        }
                    )
                        self.locationManager.stopUpdatingLocation()
                }
                    
            } else {
                    
                    if self.updating {
                        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                        NSLog(String(format: "Setting accuracy to %.0fm!", kCLLocationAccuracyNearestTenMeters))
                        self.updatingTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "hasNotUpdatedLocationForTooLong", userInfo: nil, repeats: false)
                    }
                    
                }
            }
        }
    
    func hasNotUpdatedLocationForTooLong() {
        if !self.updating {
            return
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        NSLog(String(format: "Times up waiting for didUpdatingLocation. Setting accuracy to %.0fm!", kCLLocationAccuracyNearestTenMeters))
    }
  
    func fetch() {
        NSLog("Fetch is called")
    self.start()
  }
    
    func start() {
        if self.updating {
            return
        }
        
        self.updating = true
        self.locationPicker = NSLocationPicker(maximumSamples: 10, desiredAccuracy: kCLLocationAccuracyNearestTenMeters, longestInterval: 120)
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        NSLog(String(format: "Setting accuracy to %.0fm!", kCLLocationAccuracyHundredMeters))
        self.locationManager.startUpdatingLocation()
    }
    
    func stop() {
            self.locationManager.stopUpdatingHeading()
        self.updating = false
    }

}
