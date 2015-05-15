//
//  ViewController.swift
//  StanfordMap
//
//  Created by John YS on 5/14/15.
//  Copyright (c) 2015 Silicon Valley Insight. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println("ViewController Loading")
        let client = StanfordPlacesClient()
        client.searchBuildingsWithCompletion("Volley", completion: { (buildings:[Building]?, error: NSError?) -> Void in
            println("\(buildings!)")
            for building in buildings! {
                building.print()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

