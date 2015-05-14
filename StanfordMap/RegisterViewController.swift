//
//  RegisterViewController.swift
//  StanfordMap
//
//  Created by Anna Wang on 5/14/15.
//  Copyright (c) 2015 Silicon Valley Insight. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet var username: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var confirmPassword: UITextField!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onRegisterClicked(sender: AnyObject) {
        var error = ""
        if username.text == "" || password.text == "" {
            error = "Please enter a username and password"
        } else if confirmPassword.text != password.text {
            error = "Passwords must match"
            password.text = ""
            confirmPassword.text = ""
        }
        if error != "" {
            displayAlert("Form Error", error: error)
        } else {
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            var user = PFUser()
            user.username = username.text!
            user.password = password.text!
            user.email = email.text!
            user.signUpInBackgroundWithBlock({ (succeeded, signUpError) -> Void in
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                if signUpError == nil {
                    self.performSegueWithIdentifier("postSignUp", sender: self)
                } else {
                    if let errorString = signUpError!.userInfo?["error"] as? NSString {
                        error = errorString as String
                    } else {
                        error = "Please try again."
                    }
                    self.displayAlert("Could not sign up", error: error)
                    println("error")
                }
            })
        }
    }
    
    func displayAlert (title:String, error:String){
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
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

