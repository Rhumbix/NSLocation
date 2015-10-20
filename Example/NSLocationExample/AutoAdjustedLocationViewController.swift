//
//  LocationViewController.swift
//  TheBackgrounder
//
//  Created by Ray Fix on 12/9/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

import UIKit
import CoreLocation
import NSLocation
import MapKit

class AutoAdjustedLocationViewController: UIViewController, CLLocationManagerDelegate {
   
    var locationMgr : NSLocation?

    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func enabledChanged(sender: UISwitch) {
        if sender.on {
            self.locationMgr = NSLocation(desiredAccuracy: kCLLocationAccuracyNearestTenMeters, desiredIntervalInSeconds: 60.0*2)
            self.locationMgr!.start(self)
        } else {
            if let unwrappedMgr = self.locationMgr {
                unwrappedMgr.stop()
                self.locationMgr = nil
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        mapView.addAnnotations(locations.map
            { (loc: CLLocation) -> MKPointAnnotation in
                let anno = MKPointAnnotation()
                anno.coordinate = loc.coordinate
                return anno
            }
        )
    }
}

