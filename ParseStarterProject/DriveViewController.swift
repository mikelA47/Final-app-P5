//
//  DriveViewController.swift
//  WhereIsTheCar
//
//  Created by mikel lizarralde cabrejas on 8/9/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class DriveViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var driveButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var carStatus: UILabel!
    @IBOutlet weak var carLabel: UILabel!
    
    var driver: Driver = Driver(userID: "", objectID: "")
    
    var locationManager: CLLocationManager!
    
    var requestLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0
    
    var latitudeCar: CLLocationDegrees = 0
    var longitudeCar: CLLocationDegrees = 0
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.carStatus.text = ""
        self.carLabel.text = ""

        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
       /* self.getDriverInfo()
        println(driver.carID)
        self.carLabel.text = self.driver.carID
        self.isAvailable()*/
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.stopAnimating()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        self.getDriverInfo()
        println(driver.carID)
        self.carLabel.text = self.driver.carID
        //self.isAvailable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDriverInfo() {
        var query = PFQuery(className:"Driver")
        query.whereKey("username", equalTo:PFUser.currentUser()!.username!)
        query.getFirstObjectInBackgroundWithBlock {
            (driver: PFObject?, error: NSError?) -> Void in
            
            if error == nil && driver != nil {
                println("1.- Existe driver ")
                self.driver.objectID = driver!.objectId!
                self.driver.userID = PFUser.currentUser()!.username!
                if let carID = driver!.objectForKey("carID") as? String {
                    self.driver.carID = carID
                    println("2.- \(self.driver.carID)")
                    self.carLabel.text = self.driver.carID
                    
                    //**********
                    
                    //**********
                }
                self.isAvailable()
                println("Fin recuperar información \(self.driver.carID) : \(self.driver.userID)")
            } else {
                println("Error al recuperar ObjectID")
            }
        }
        
    }
    
    func isAvailable() {
        println("3.- Buscamos coche matricula \(self.driver.carID)")
        var query = PFQuery(className:"Car")
        query.whereKey("carID", equalTo:self.driver.carID)
        query.getFirstObjectInBackgroundWithBlock {
            (car_: PFObject?, error: NSError?) -> Void in
            
            if error == nil && car_ != nil {
                println("4.- Existe coche")
                if let free = car_!.objectForKey("available") as? Bool
                {
                    if free {
                        self.carStatus.text = "Available"
                        self.carStatus.textColor = UIColor.greenColor()
                        self.driveButton.enabled = true
                    } else {
                        let status = car_!.objectForKey("driving") as? String
                        self.carStatus.text = "Car in use by " + status!
                        self.carStatus.textColor = UIColor.redColor()
                        self.driveButton.enabled = false
                    }
                }
            } else {
                println(error)
                println("5.- Mal")
            }
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        var location:CLLocationCoordinate2D = manager.location!.coordinate
        
        self.latitude = location.latitude
        self.longitude = location.longitude
        
        var query = PFQuery(className:"Car")
        query.whereKey("carID", equalTo:self.driver.carID)
        query.getFirstObjectInBackgroundWithBlock {
            (car: PFObject?, error: NSError?) -> Void in
            
            if error == nil && car != nil {
                if let carLocation = car!.objectForKey("location") as? PFGeoPoint {
                    let driverCLLocation = CLLocation(latitude: carLocation.latitude, longitude: carLocation.longitude)
                    let userCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    
                    let distanceMeters = userCLLocation.distanceFromLocation(driverCLLocation)
                    let distanceKM = distanceMeters / 1000
                    let roundedTwoDigitDistance = Double(round(distanceKM * 10) / 10)
                    
                    //     self.callUberButton.setTitle("Driver is \(roundedTwoDigitDistance)km away!", forState: UIControlState.Normal)
                    
                    //   self.driverOnTheWay = true
                    
                    let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    
                    let latDelta = abs(carLocation.latitude - location.latitude) * 2 + 0.005
                    let lonDelta = abs(carLocation.longitude - location.longitude) * 2 + 0.005
                    
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
                    
                    self.mapView.setRegion(region, animated: true)
                    
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    
                    var pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                    var objectAnnotation = MKPointAnnotation()
                    objectAnnotation.coordinate = pinLocation
                    objectAnnotation.title = "Your location"
                    self.mapView.addAnnotation(objectAnnotation)
                    
                    pinLocation = CLLocationCoordinate2DMake(carLocation.latitude, carLocation.longitude)
                    objectAnnotation = MKPointAnnotation()
                    objectAnnotation.coordinate = pinLocation
                    objectAnnotation.title = "Car location"
                    self.mapView.addAnnotation(objectAnnotation)
                    
                    
                    
                }
            }
        }
    }

    @IBAction func drivePressed(sender: AnyObject) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        println("1.- Buscamos coche matricula \(self.driver.carID)")
        var query = PFQuery(className:"Car")
        query.whereKey("carID", equalTo:self.driver.carID)
        query.getFirstObjectInBackgroundWithBlock {
            (car: PFObject?, error: NSError?) -> Void in
            
            if error == nil && car != nil {
                println("Existe coche")
                var query_ = PFQuery(className:"Car")
                println("Car : \(self.driver.carID) - Car ID : \(car!.objectId!)")
                query_.getObjectInBackgroundWithId(car!.objectId!) {(car_: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        println(error)
                    } else if let car_ = car_ {
                        println("Coche \(self.driver.carID) recuperado por ID")
                        println(car_.objectForKey("carID")!)
                        
                        car_["available"] = false
                        car_["driving"] = self.driver.userID
                        car_.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                            if success {
                                println("Coche recogido")
                                var queryDriver = PFQuery(className: "Driver")
                                queryDriver.getObjectInBackgroundWithId(self.driver.objectID, block: { (driver_: PFObject?, error: NSError?) -> Void in
                                    if error != nil {
                                        println(error)
                                    } else if let driver_ = driver_ {
                                        driver_["driving"] = true
                                        ParseClient.sharedInstance().user.driving = true
                                        driver_.saveInBackground()
                                        println("Ponemos driving a true")
                                        ParseClient.sharedInstance().gettingDrivers { (success, errorGetting) -> Void in
                                            if success {
                                                println("Drivers recovered")
                                            } else {
                                                println(errorGetting!)
                                            }
                                        }
                                        
                                    }

                                })
                                
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                self.activityIndicator.stopAnimating()
                                    let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MainMenuNavigation")! as! UINavigationController
                                ParseClient.sharedInstance().updateCurrentUser({ (success, errorGetting) -> Void in
                                    if success {
                                        println("User recovered")
                                    } else {
                                        println(errorGetting!)
                                    }
                                })
                                    self.presentViewController(detailController, animated: true, completion: nil)
                                }
                            } else {
                                println("Coche no guardado, algo pasa")
                                self.activityIndicator.stopAnimating()
                            }
                        }
                    }
                }
            } else {
                println("No hay coche!!!!!")
                self.activityIndicator.stopAnimating()
            }
        }
    }

}
