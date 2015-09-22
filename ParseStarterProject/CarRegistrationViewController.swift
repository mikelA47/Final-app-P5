//
//  CarRegistrationViewController.swift
//  ParseStarterProject-Swift
//
//  Created by mikel lizarralde cabrejas on 2/9/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class CarRegistrationViewController: UIViewController {

    var driver: Driver = Driver(userID: "", objectID: "")
    
    @IBOutlet weak var contineButton: UIButton!
    @IBOutlet var blurBackground: UIVisualEffectView!
    @IBOutlet weak var carGood: UILabel!
    @IBOutlet weak var driverGood: UILabel!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var licenseTextField: UITextField!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        self.blurBackground.hidden = true
        self.carGood.hidden = true
        self.driverGood.hidden = true
        self.contineButton.hidden = true
        self.licenseTextField.text = ""
        self.driverName.text = PFUser.currentUser()!.username!
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        self.getDriverObjectID()
        
        activityIndicator.stopAnimating()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDriverObjectID() {
        var query = PFQuery(className:"Driver")
        query.whereKey("username", equalTo:PFUser.currentUser()!.username!)
        query.getFirstObjectInBackgroundWithBlock {
            (driver: PFObject?, error: NSError?) -> Void in
            
            if error == nil && driver != nil {
                println("Existe driver para usuario")
                self.driver.objectID = driver!.objectId!
                self.driver.userID = PFUser.currentUser()!.username!
            } else {
                println("Error al recuperar ObjectID")
            }
        }

    }
    
    @IBAction func registerCar(sender: AnyObject) {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        if self.licenseTextField != "" {
            println("*** Registrar coche ***")
            var query = PFQuery(className:"Car")
            query.whereKey("carID", equalTo:self.licenseTextField.text)
            query.getFirstObjectInBackgroundWithBlock {
                (car: PFObject?, error: NSError?) -> Void in
                
                if error == nil && car != nil {
                    println("a.- Existe coche")
                    
                    
                    var query_ = PFQuery(className:"Driver")
                    println("a.1.- Driver : \(self.driver.userID)")
                    query_.getObjectInBackgroundWithId(self.driver.objectID) {(driverOld: PFObject?, error: NSError?) -> Void in
                        if error != nil {
                            println(error)
                        } else if let driverOld = driverOld {
                            driverOld["carID"] = car?.objectForKey("carID")
                            driverOld["car"] = true
                            driverOld.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                                if (success) {
                                    println("a.2.- Bien")
                                    self.showAssignatedScreen(self.licenseTextField.text, driver: self.driver.userID)
                                } else {
                                    println(error)
                                }
                            })
                            
                        }
                    }
                } else {
                    println("b.- Coche no existe")
                    self.driver.carID = self.licenseTextField.text
                    var latitude: CLLocationDegrees = 0
                    var longitude: CLLocationDegrees = 0
                    let carToCreate = PFObject(className: "Car")
                    carToCreate["carID"] = self.driver.carID
                    carToCreate["fuel"] = true
                    carToCreate["available"] = true
                    carToCreate["distance"] = 0
                    carToCreate["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
                    let acl = PFACL()
                    acl.setPublicReadAccess(true)
                    acl.setPublicWriteAccess(true)
                    carToCreate["ACL"] = acl
                    carToCreate.saveInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            //ir al menu
                            var query_ = PFQuery(className:"Driver")
                            println("b.1.- Driver : \(self.driver.userID)")
                            query_.getObjectInBackgroundWithId(self.driver.objectID) {(driverOld: PFObject?, error: NSError?) -> Void in
                                if error != nil {
                                    println(error)
                                } else if let driverOld = driverOld {
                                    driverOld["carID"] = self.driver.carID
                                    driverOld["car"] = true
                                    driverOld.saveInBackground()
                                    println("b.2.- Coche creado \(self.driver.carID) y conductor añadido \(self.driver.userID)")
                                    self.activityIndicator.stopAnimating()
                                    self.showAssignatedScreen(self.driver.carID, driver: self.driver.userID)
                                }
                            }
                            
                            
                        } else {
                            println(error)
                        }
                    }
                }
            }
        } else {
            println("License empty")
        }
        activityIndicator.stopAnimating()
    }
    
    func showAssignatedScreen(car: String, driver: String)
    {
        self.blurBackground.hidden = false
        self.carGood.hidden = false
        self.driverGood.hidden = false
        self.contineButton.hidden = false
        
        self.carGood.text = car
        self.driverGood.text = driver
    }

    @IBAction func registrationGoodPressed(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MainMenuNavigation")! as! UINavigationController
            self.presentViewController(detailController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        PFUser.logOut()
        var currentUser = PFUser.currentUser()
        println(currentUser)
        self.dismissViewControllerAnimated(true, completion: nil)
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
