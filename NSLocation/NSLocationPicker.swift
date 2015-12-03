//
//  NSLocationPicker.swift
//  Pods
//
//  Created by Kenneth on 10/20/15.
//
//

import Foundation
import CoreLocation

public class NSLocationPicker {
    let maximumSamples : Int
    let desiredAccuracy : CLLocationAccuracy
    let longestInterval : NSTimeInterval
    
    var locations : [CLLocation]
    
    public init(maximumSamples: Int, desiredAccuracy: CLLocationAccuracy, longestInterval: NSTimeInterval) {
        self.maximumSamples = maximumSamples
        self.desiredAccuracy = desiredAccuracy
        self.longestInterval = longestInterval
        self.locations = []
    }
    
    public func pick(newLocation: CLLocation) -> CLLocation? {
        if NSDate().timeIntervalSinceDate(newLocation.timestamp) > self.longestInterval {
            return nil
        }

        self.locations.append(newLocation)
        
        if newLocation.horizontalAccuracy <= self.desiredAccuracy {
                return newLocation
        }
        
        NSLog(String(format: "location counts: %ld --- max: %ld", self.locations.count, self.maximumSamples))
        if self.locations.count >= self.maximumSamples {
            return self.locations.sort({ $0.horizontalAccuracy < $1.horizontalAccuracy }).first
        }

        return nil
    }
}