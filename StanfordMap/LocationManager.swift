//
//  LocationManager.swift
//  StanfordMap
//
//  Created by John YS on 5/14/15.
//  Copyright (c) 2015 Silicon Valley Insight. All rights reserved.
//
// Referenced from the CodePath Frameworks Demo

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = LocationManager()
    
    // Location manager
    let locationManager = CLLocationManager()
    
    // Keep track of the number of "radio station listeners".
    // If the number of listeners changes to 0, stop asking
    // for location updates (to save battery).  If we get a listener
    // for the first time, start updating our location.
    var numberOfListeners = 0 {
        didSet {
            if numberOfListeners == 0 {
                println("Stopping location updates...")
                locationManager.stopUpdatingLocation()
            } else if numberOfListeners == 1 {
                println("Starting location updates...")
                
                // If we've already been authorized, start updating location
                // If we haven't, ask for permission first (see
                // locationManager:didChangeAuthorizationStatus: for a callback
                // for asking for permissions)
                if CLLocationManager.authorizationStatus() == .AuthorizedAlways ||
                    CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
                        locationManager.startUpdatingLocation()
                } else { locationManager.requestWhenInUseAuthorization() }
            }
        }
    }
    
    // The name of our "radio station"/NSNotificationCenter notification
    // (can be anything)
    let LOCATION_UPDATED_NOTIFICATION_NAME = "LocationUpdatedNotification"
    
    // The key to access the location data inside the notification's userInfo
    // dictionary (can be anything)
    let NEW_LOCATION_NOTIFICATION_KEY = "location"
    
    
    // Initialize our location manager and ask for permission
    // to access the user's location (the app only asks permission
    // once ever, even though this line is executed every time).
    // Note that we can call super.init() first because all of our
    // instance variables are instantiated inline above.  (You need
    // to initialize all your own instance variables before super.init())
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    
    // This delegate method is called once the user responds to our
    // request for location permission.  If they said OK, start location updates.
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    
    // One of the CLLocationManagerDelegate functions for getting
    // location updates.  Passes in an array of CLLocation objects, from
    // oldest to newest (sometimes it's only 1, sometimes more than 1 if
    // there was a backlog in location data gathering).
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        // Get the most recent location data
        let location = locations.last as! CLLocation
        
        // Broadcast out to our "radio listeners" that there's a new
        // location update, and include the location in the userInfo dictionary
        // that's "attached" to the notification when it's broadcast.
        NSNotificationCenter.defaultCenter()
            .postNotificationName(LOCATION_UPDATED_NOTIFICATION_NAME, object: nil, userInfo: [NEW_LOCATION_NOTIFICATION_KEY: location])
    }
    
    
    // This method takes a block from a "radio listener" that they
    // want to be executed whenever something new is broadcast out.  We
    // take care of "subscribing" them to our radio station, so they don't
    // have to.
    func subscribeToLocationUpdatesWithBlock(block:(CLLocation) -> Void) {
        
        numberOfListeners++
        
        // This block is triggered whenever we broadcast a new
        // location.  We want to get the location data out of the
        // NSNotification and call the listener's block, passing in
        // the new location data so they can use it.
        NSNotificationCenter.defaultCenter().addObserverForName(LOCATION_UPDATED_NOTIFICATION_NAME, object: nil, queue: NSOperationQueue.mainQueue()) { (notif: NSNotification!) -> Void in
            
            let location = notif.userInfo?["location"] as! CLLocation
            block(location)
        }
    }
    
    
    // This method takes a "listener" that wants to be unsubscribed
    // from our new location updates.  We remove them from the notification
    // center list.
    func removeObserverForLocationUpdates(observer: AnyObject) {
        numberOfListeners--
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
}