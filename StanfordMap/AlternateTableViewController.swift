//
//  AlternateTableViewController.swift
//  StanfordMap
//
//  Created by Anna Wang on 5/19/15.
//  Copyright (c) 2015 Silicon Valley Insight. All rights reserved.
//

import UIKit

class AlternateTableViewController: UITableViewController, UISearchResultsUpdating {
    
    let client:StanfordPlacesClient = StanfordPlacesClient()

    let viewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("NormalViewController") as! MapViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewController.searchArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LargeCell", forIndexPath: indexPath) as! AlternateTableViewCell
        cell.configureCell(countryName:viewController.searchArray[indexPath.row])
        return cell
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        viewController.searchArray.removeAll(keepCapacity: false)
        var searchString:String = searchController.searchBar.text
        client.searchBuildingsFuzzyWithCompletion(searchString, completion: { (buildings, error) -> Void in
            
            if error != nil {
                println("Error returning results")
            } else {
            
                var buildingNames:[String] = []
                for building in buildings! {
                    buildingNames.append(building.name!)
                }
                self.viewController.searchArray = buildingNames
                self.tableView.reloadData()
            }
        })
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
