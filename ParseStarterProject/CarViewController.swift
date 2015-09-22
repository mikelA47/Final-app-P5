//
//  CarViewController.swift
//  ParseStarterProject-Swift
//
//  Created by mikel lizarralde cabrejas on 1/9/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class CarViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var parkButton: UIButton!
    
    @IBOutlet weak var carParkLabel: UILabel!
    
    var locationManager: CLLocationManager!
    
    var latitude: CLLocationDegrees = 0
    var longitude: CLLocationDegrees = 0

    var driver: Driver = Driver(userID: "",objectID: "")
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = false
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
        ParseClient.sharedInstance().updateCurrentUser { (success, errorGetting) -> Void in
            if !success {
                println(errorGetting!)
            } else {
                self.driver = ParseClient.sharedInstance().user
            }
        }
        if ParseClient.sharedInstance().user.driving {
            self.parkButton.enabled = true
            self.carParkLabel.text = "Car: \(ParseClient.sharedInstance().user.carID)"
        } else {
            self.parkButton.enabled = false
            self.carParkLabel.text = "You are not driving"
        }
        
        activityIndicator.stopAnimating()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.stopAnimating()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        var location: CLLocationCoordinate2D = manager.location.coordinate
        
        var pin:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        var pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = pin
        //pinAnnotation.title = "coche"
        
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.latitude = location.latitude
        self.longitude = location.longitude
        //self.mapView.camera.altitude = 100
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(pinAnnotation)
        self.mapView.setRegion(region, animated: true)
        
        
    }


    @IBAction func parkPressed(sender: AnyObject) {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        ParseClient.sharedInstance().updateCurrentUser { (success, errorGetting) -> Void in
            if !success {
                println(errorGetting!)
            } else {
                self.driver = ParseClient.sharedInstance().user
            }
        }
        var query = PFQuery(className:"Car")
        println("1.- Inicio aparcar \(self.driver.carID)")
        query.whereKey("carID", equalTo:self.driver.carID)
        query.getFirstObjectInBackgroundWithBlock {
            (car: PFObject?, error: NSError?) -> Void in
            
            if error == nil && car != nil {
                println("2.- Existe coche")
                var query_  = PFQuery(className: "Car")
                query_.getObjectInBackgroundWithId(car!.objectId!) {
                    (car_: PFObject?, error: NSError?) -> Void in
                    if error != nil {
                        println(error)
                        println("5.- Mal")
                    } else if let car_ = car_ {
                        println("3.- Car object ID recuperado")
                        car_["location"] = PFGeoPoint(latitude: self.latitude, longitude: self.longitude)
                        car_["available"] = true
                        car_["driving"] = ""
                        car_.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                            if success {
                                println("4.- Coche aparcado correctamente")
                                var queryDriver = PFQuery(className: "Driver")
                                queryDriver.getObjectInBackgroundWithId(self.driver.objectID, block: { (driver_: PFObject?, error: NSError?) -> Void in
                                    if error != nil {
                                        println(error)
                                    } else if let driver_ = driver_ {
                                        driver_["driving"] = false
                                        ParseClient.sharedInstance().user.driving = false
                                        driver_.saveInBackground()
                                        println("Driver ya no conduce")
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
                                    
                                    self.presentViewController(detailController, animated: true, completion: nil)
                                }
                            } else {
                                println("5.- Error al aparcar. Mal")
                                self.activityIndicator.stopAnimating()
                            }
                        })
                    }
                }
            }
        }
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
