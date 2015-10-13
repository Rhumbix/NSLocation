//
//  LocationViewController.swift
//  TheBackgrounder
//
//  Created by Ray Fix on 12/9/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class AutoAdjustedLocationViewController: UIViewController, CLLocationManagerDelegate {
    var consecutiveAccurateLocations = 0
    var consecutiveInaccurateLocations = 0
    var locationCount = 0
    
    var timer : NSTimer?

    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
        }()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func enabledChanged(sender: UISwitch) {
        if sender.on {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {

        // Add another annotation to the map.
        let annotation = MKPointAnnotation()
        annotation.coordinate = newLocation.coordinate
        
        locationCount += 1
        
        mapView.addAnnotation(annotation)
        NSLog(String(format: "%ld: %@", locationCount, newLocation))

        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        
        if newLocation.horizontalAccuracy > 65 {
            consecutiveAccurateLocations = 0
            consecutiveInaccurateLocations += 1
            
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "timesUp", userInfo: nil, repeats: false)
            
        } else {
            consecutiveInaccurateLocations = 0
            consecutiveAccurateLocations += 1
        }
        
        if consecutiveAccurateLocations > 10 {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            NSLog("Setting to 100m!")
        }
        
        if consecutiveInaccurateLocations > 10 {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            NSLog("Setting to 10m!")
        }

    }
    
    func timesUp() {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        NSLog("Times up! Setting to 10m!")
    }
}

