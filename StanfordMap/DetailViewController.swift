//
//  DetailViewController.swift
//  StanfordMap
//
//  Created by John YS on 5/23/15.
//  Copyright (c) 2015 Silicon Valley Insight. All rights reserved.
//

import UIKit
import MapKit
import MessageUI

class DetailViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
    var building:Building?
    var client:StanfordPlacesClient!
    var region:MKCoordinateRegion?

    @IBOutlet weak var buildingImageView: UIImageView!
    @IBOutlet weak var buildingNameLabel: UILabel!
    @IBOutlet weak var buildingIdLabel: UILabel!
    @IBOutlet weak var buildingStreetLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.toolbarHidden = false;
        
        view.layer.borderWidth = 10
        
        view.layer.borderColor = UIColor.grayColor().CGColor
        
        client = StanfordPlacesClient()
        if let bldg = building {
            // Set the image
            client.getBuildingReportImageStringWithCompletion(building!.buildingId!, completion: { (imageString, error) -> Void in
                if error == nil {
                    if imageString != "" {
                        self.buildingImageView.setImageWithURL(NSURL(string: imageString!))
                    }
                } else {
                   //There was an error
                }
            })
            // Set the remainder of values
            buildingNameLabel.text = building?.name
            buildingIdLabel.text = building?.buildingId
            buildingStreetLabel.text = building?.street
            region = MKCoordinateRegionMakeWithDistance(bldg.location!, 100, 100)
            //add an annotation for the selected location
            var annotation:MKPointAnnotation = MKPointAnnotation()
            annotation.coordinate = bldg.location!
            annotation.title = bldg.name
            annotation.subtitle = bldg.street
            mapView.addAnnotation(annotation)
            self.mapView.setRegion(region!, animated: true)
            println(building!.longitude)
            println(building!.latitude)
        }
        mapView.layer.cornerRadius = 10
        mapView.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sharedPressed(sender: AnyObject) {
        //make sure that the mapView is centered before screenshot
        self.mapView.setRegion(region!, animated: false)
        //take the screenshot
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        var imageData = UIImageJPEGRepresentation(image, 1.0)
        //set up the message send controller
        var messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        messageVC.body = "http://maps.apple.com?q=" + building!.latitude! + "," + building!.longitude!
         messageVC.addAttachmentData(imageData, typeIdentifier: "image/jpeg", filename: "My Image.jpeg")
        self.presentViewController(messageVC, animated: false, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        switch (result.value) {
        case MessageComposeResultCancelled.value:
            self.dismissViewControllerAnimated(true, completion: nil)
            SVProgressHUD.showInfoWithStatus("Message Canceled")
        case MessageComposeResultFailed.value:
            self.dismissViewControllerAnimated(true, completion: nil)
            SVProgressHUD.showErrorWithStatus("Message Failed")
        case MessageComposeResultSent.value:
            self.dismissViewControllerAnimated(true, completion: nil)
            SVProgressHUD.showSuccessWithStatus("Message Sent!")
        default:
            break;
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView()
        headerView.backgroundColor = UIColor.grayColor()
        return headerView
    }
}
