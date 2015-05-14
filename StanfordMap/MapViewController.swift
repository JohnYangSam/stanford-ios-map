//
//  MapViewController.swift
//  StanfordMap
//
//  Created by John YS on 5/14/15.
//  Copyright (c) 2015 Silicon Valley Insight. All rights reserved.
//


import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show the user's location on the map (can also set in storyboard instead)
        mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // We want to listen to the LocationManager's "radio station"
        // and execute the following code whenever a new location is "broadcast" out
        LocationManager.sharedInstance.subscribeToLocationUpdatesWithBlock { (location:CLLocation) -> Void in
            println("Received location update!")
            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        LocationManager.sharedInstance.removeObserverForLocationUpdates(self)
    }
}