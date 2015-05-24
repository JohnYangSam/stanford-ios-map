//
//  DetailViewController.swift
//  StanfordMap
//
//  Created by John YS on 5/23/15.
//  Copyright (c) 2015 Silicon Valley Insight. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var building:Building?
    var client:StanfordPlacesClient!

    @IBOutlet weak var buildingImageView: UIImageView!
    @IBOutlet weak var buildingNameLabel: UILabel!
    @IBOutlet weak var buildingIdLabel: UILabel!
    @IBOutlet weak var buildingStreetLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        client = StanfordPlacesClient()
        
        if let bldg = building {
            // Set the image
            client.getBuildingReportImageStringWithCompletion(building!.buildingId!, completion: { (imageString, error) -> Void in
                if let imgStr = imageString {
                    self.buildingImageView.setImageWithURL(NSURL(string: imgStr))
                } else {
                    // We reached an error here
                }
            })
            // Set the remainder of values
            buildingNameLabel.text = building?.name
            buildingIdLabel.text = building?.buildingId
            buildingStreetLabel.text = building?.street
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
