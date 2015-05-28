//
//  MapViewController.swift
//  StanfordMap
//
//  Created by John YS on 5/14/15.
//  Copyright (c) 2015 Silicon Valley Insight. All rights reserved.
//


import UIKit
import MapKit

class MapViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchSuggestionsTableView: UITableView!
    var searchBar:UISearchBar = UISearchBar()
    var client:StanfordPlacesClient = StanfordPlacesClient()
    let startingLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(37.4282631), longitude: CLLocationDegrees(-122.1712559))
    var searchResults:[Building] = []
    var buildingChosen:Building?
    var button:MKAnnotationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Search Suggestion Code
        
        // Start with the table view hidden
        self.searchSuggestionsTableView.hidden = true
        
        // Set up the tableview
        self.searchSuggestionsTableView.delegate = self
        self.searchSuggestionsTableView.dataSource = self
        self.searchSuggestionsTableView.rowHeight = UITableViewAutomaticDimension
        
        // Setup search bar
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        // Location code
        // Show the user's location on the map (can also set in storyboard instead)
        mapView.showsUserLocation = true
        // Center at Stanford
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(startingLocation, 10000, 10000), animated: true)
        
        // Set mapView delegate
        self.mapView.delegate = self
        
        //add in the gesture recognizer
        var longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        longPressRecognizer.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(longPressRecognizer)
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        println("textDidChange")
        
        // Show table view
        searchSuggestionsTableView.hidden = false
        mapView.hidden = true
        
        client.searchBuildingsFuzzyWithCompletion(searchText, completion: { (buildings, error) -> Void in
            
            if error != nil {
                println("error searching")
            } else {
                self.searchResults = buildings!
                self.searchSuggestionsTableView.reloadData()
            }
        })
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        mapView.hidden = false
        searchSuggestionsTableView.hidden = true
        removeAllPinsExceptUserLocation()
        searchBar.resignFirstResponder()
    }

    
    // Callbacks for tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:SearchResultCell = searchSuggestionsTableView.dequeueReusableCellWithIdentifier("SearchResultCell", forIndexPath: indexPath) as! SearchResultCell
        cell.searchResultName.text = searchResults[indexPath.row].name! + " - " + searchResults[indexPath.row].buildingId!
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get search result
        buildingChosen = searchResults[indexPath.row]
        
        // Show the map
        searchSuggestionsTableView.hidden = true
        mapView.hidden = false
        
        // Clear current annotations before adding new ones
        removeAllPinsExceptUserLocation()
       
        for building in searchResults {
            var annotation:MKPointAnnotation = MKPointAnnotation()
            annotation.coordinate = building.location!
            annotation.title = building.name
            annotation.subtitle = building.street
            mapView.addAnnotation(annotation)
        }

        // Zoom into map area of the chosen result
        let region = MKCoordinateRegionMakeWithDistance(buildingChosen!.location!, 1000, 1000)
        self.mapView.setRegion(region, animated: true)
    }
    
    func removeAllPinsExceptUserLocation() {
        var userLocation = mapView.userLocation
        var pins:NSMutableArray = NSMutableArray(array: mapView.annotations)
        if (userLocation != nil) {
            pins.removeObject(userLocation)
        }
        mapView.removeAnnotations(pins as [AnyObject])
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil;  //return nil to use default blue dot view
        }
        
        if let annotation = annotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                
                var calloutButton = UIButton.buttonWithType(.DetailDisclosure) as! UIView
                view.rightCalloutAccessoryView = calloutButton
            }
            // Make the current chosen building green
            if annotation.title == buildingChosen?.name {
                view.pinColor = MKPinAnnotationColor.Green
            }
            return view
        }
        return nil
    }
    
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        // Get the building information
        var building:Building = getBuildingFromResults(view.annotation.title!)!
        // Instantiate the new detail view controller
        var vc: DetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        vc.building = building
        button = view
        // Get the current navigation controller so we can push the new viewController onto the navigation controller
        self.navigationController!.pushViewController(vc, animated: true)
        
        
    }
    
    // This is an inefficient function, but we'll use it for simplicity
    func getBuildingFromResults(buildingName:String) -> Building? {
        for building in searchResults {
            if building.name == buildingName {
                return building
            }
        }
        return nil
    }
    
    @IBAction func mapPressed(sender: AnyObject) {
        searchBar.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // We want to listen to the LocationManager's "radio station"
        // and execute the following code whenever a new location is "broadcast" out
        LocationManager.sharedInstance.subscribeToLocationUpdatesWithBlock { (location:CLLocation) -> Void in
        }
        self.navigationController!.toolbarHidden = true;
    }
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer) {
        var touchPoint = gestureRecognizer.locationInView(self.mapView)
        var newCoordinate : CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        var annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinate
        annotation.title = "New Point"
        annotation.subtitle = "some subtitle here"
        mapView.addAnnotation(annotation)
    }
    
    override func viewDidDisappear(animated: Bool) {
        LocationManager.sharedInstance.removeObserverForLocationUpdates(self)
    }
}