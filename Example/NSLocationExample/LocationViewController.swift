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

class LocationViewController: UIViewController, CLLocationManagerDelegate {
  var locations = [MKPointAnnotation]()
  
  lazy var locationManager: CLLocationManager! = {
    let manager = CLLocationManager()
    manager.desiredAccuracy = kCLLocationAccuracyBest
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
  
  @IBAction func accuracyChanged(sender: UISegmentedControl) {
    let accuracyValues = [
      kCLLocationAccuracyBestForNavigation,
      kCLLocationAccuracyBest,
      kCLLocationAccuracyNearestTenMeters,
      kCLLocationAccuracyHundredMeters,
      kCLLocationAccuracyKilometer,
      kCLLocationAccuracyThreeKilometers]
    
    locationManager.desiredAccuracy = accuracyValues[sender.selectedSegmentIndex];
  }
  
  // MARK: - CLLocationManagerDelegate
  
  func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {


    
    // Add another annotation to the map.
    let annotation = MKPointAnnotation()
    annotation.coordinate = newLocation.coordinate
    
    // Also add to our map so we can remove old values later
    locations.append(annotation)
    
    // Remove values if the array is too big
    while locations.count > 5000 {
      let annotationToRemove = locations.first!
      locations.removeAtIndex(0)
      
      // Also remove from the map
      mapView.removeAnnotation(annotationToRemove)
    }
      mapView.addAnnotation(annotation)
    NSLog(String(format: "%ld - %ld : %@", locations.count, mapView.annotations.count, newLocation))
    //    NSLog(String(format: "old Loc: %@", oldLocation))
  }
}

