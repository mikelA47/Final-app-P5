//
//  MainMenuViewController.swift
//  ParseStarterProject-Swift
//
//  Created by mikel lizarralde cabrejas on 31/8/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class MainMenuViewController: UIViewController {

    var locationManager: CLLocationManager!
    var driver: Driver = Driver(userID: "", objectID: "")
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadDrivers()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadDrivers() {
        //call get method -> students info
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        ParseClient.sharedInstance().gettingDrivers() { (success, errorString) in
            if !success {
                println(errorString!)
            }
            else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("TableDrivers")! as! UserTableViewController
                    detailController.reloadDrivers()
                    self.activityIndicator.stopAnimating()
                })
            }
        }
        
    }
    
    @IBAction func parkPressed(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("CarView")! as! CarViewController
            
            self.navigationController!.pushViewController(detailController, animated: true)
        }
    }

    @IBAction func logOutPressed(sender: AnyObject) {
        PFUser.logOut()
        var currentUser = PFUser.currentUser()
        println(currentUser)
        dispatch_async(dispatch_get_main_queue()) {
            let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("LogIn")! as! LogInViewController
            self.presentViewController(detailController, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tableDriversSegue"
        {
            self.reloadDrivers()
        }
    }

}
