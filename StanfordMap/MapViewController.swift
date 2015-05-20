//
//  MapViewController.swift
//  StanfordMap
//
//  Created by John YS on 5/14/15.
//  Copyright (c) 2015 Silicon Valley Insight. All rights reserved.
//


import UIKit
import MapKit

class MapViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchSuggestionsTableView: UITableView!
    
    var searchResults:[Building] = []
    
    var searchBar:UISearchBar = UISearchBar()
    
    var client:StanfordPlacesClient = StanfordPlacesClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Search Suggestion Code
        
        // Start with the table view hidden
        self.searchSuggestionsTableView.hidden = true
        
        // Set up the tableview
        self.searchSuggestionsTableView.delegate = self
        self.searchSuggestionsTableView.dataSource = self
        
        // Setup search bar
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        // Location code
        // Show the user's location on the map (can also set in storyboard instead)
        mapView.showsUserLocation = true
        
        //add in the gesture recognizer
        var longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        longPressRecognizer.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(longPressRecognizer)
        
        /*
        // Configure countrySearchController
        self.countrySearchController = ({
            //This presents the results in a sepearate tableView
            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let alternateController:AlternateTableViewController = storyBoard.instantiateViewControllerWithIdentifier("aTV") as! AlternateTableViewController
            let controller = UISearchController(searchResultsController: alternateController)
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            controller.searchResultsUpdater = alternateController
            controller.definesPresentationContext = false
            controller.searchBar.sizeToFit()
            self.navigationItem.titleView = controller.searchBar
            return controller
        })()
*/
        
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
    }

    
    // Callbacks for tableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:SearchResultCell = searchSuggestionsTableView.dequeueReusableCellWithIdentifier("SearchResultCell", forIndexPath: indexPath) as! SearchResultCell
        cell.searchResultName.text = searchResults[indexPath.row].name
        return cell
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