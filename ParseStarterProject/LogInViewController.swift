/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import CoreData
import Parse

class LogInViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var contrasena: UITextField!
    @IBOutlet weak var usuario: UITextField!
    @IBOutlet weak var botonSecuandarioEntrarRegistrar: UIButton!
    @IBOutlet weak var textoEntrarRegistrar: UILabel!
    @IBOutlet weak var botonEntrarRegistrar: UIButton!
    
    let userID: String = ""
    var driver: Driver!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.driver = Driver(userID: "", objectID: "")
        self.textoEntrarRegistrar.text = "Not registered yet?"
        self.botonSecuandarioEntrarRegistrar.setTitle("Signup", forState: UIControlState.Normal)
        self.botonEntrarRegistrar.setTitle("Login", forState: UIControlState.Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.usuario.text = ""
        self.contrasena.text = ""
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        println("Read from core data : \(applicationDelegate.userSettings.keepLogIn)")
        if applicationDelegate.userSettings.keepLogIn {
            self.usuario.text = applicationDelegate.userSettings.username
            self.contrasena.text = applicationDelegate.userSettings.password
        } else {
            self.usuario.text = ""
            self.contrasena.text = ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance.managedObjectContext!
    }
    
    // Step 1 - Add the lazy fetchedResultsController property. See the reference sheet in the lesson if you
    // want additional help creating this property.
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "keepLogIn", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    
    func displayAlert(title: String, message: String)
    {
        activityIndicator.stopAnimating()
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            applicationDelegate.userSettings.keepLogIn = false
            
            println(applicationDelegate.userSettings.keepLogIn)
            self.usuario.text = ""
            self.contrasena.text = ""
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func botonSecundarioEntrarRegistrar(sender: AnyObject) {
        if self.botonEntrarRegistrar.titleLabel?.text == "Login"
        {
            self.textoEntrarRegistrar.text = "Already registered?"
            self.botonSecuandarioEntrarRegistrar.setTitle("Login", forState: UIControlState.Normal)
            self.botonEntrarRegistrar.setTitle("Sign up", forState: UIControlState.Normal)
        } else {
            self.textoEntrarRegistrar.text = "Not registered yet?"
            self.botonSecuandarioEntrarRegistrar.setTitle("Sign up", forState: UIControlState.Normal)
            self.botonEntrarRegistrar.setTitle("Login", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func botonEntrarRegistrar(sender: AnyObject) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        if self.botonEntrarRegistrar.titleLabel?.text != "Login" {
            
            var user = PFUser()
            user.username = self.usuario.text
            user.password = self.contrasena.text
            
            println("Registrar *****")
            
            user.signUpInBackgroundWithBlock { (success, error) -> Void in
                if error == nil {
                    println("Creamos un driver para usuario \(user.username)")
                    let driver = PFObject(className: "Driver")
                    driver["username"] = self.usuario.text
                    driver["car"] = false
                    driver["driving"] = false
                    
                    driver.saveInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            //ir al registro de coche
                            println("Driver \(self.usuario.text) registrado correctamente")
                        } else {
                            println("Error al registrar usuario \(error)")
                            self.displayAlert("Failed Login", message: error!.description)
                        }
                    }
                    self.usuario.text = ""
                    self.contrasena.text = ""
                   // self.performSegueWithIdentifier("logIn", sender: self)
                    self.botonSecundarioEntrarRegistrar(self)
                    
                    self.activityIndicator.stopAnimating()
                    
                } else {
                    if let errorString = error!.userInfo?["error"] as? String {
                        println("Error login")
                        //Error
                        
                        self.displayAlert("Failed SignUp", message: errorString)
                    }
                }
            }
        } else {
            println("Entrar")
           
            ParseClient.sharedInstance().logInParse(self.usuario.text, password: self.contrasena.text, completionHandler: { (success, errorGetting) -> Void in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                    let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
                    applicationDelegate.userSettings.username = self.usuario.text
                    applicationDelegate.userSettings.password = self.contrasena.text
                        CoreDataStackManager.sharedInstance.saveContext()
                        })
                    if ParseClient.sharedInstance().user.car {
                        self.activityIndicator.stopAnimating()
                        dispatch_async(dispatch_get_main_queue()) {
                            let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MainMenuNavigation")! as! UINavigationController
                        
                            self.presentViewController(detailController, animated: true, completion: nil)
                        
                        }
                    } else {
                        println("No tiene coche. Tiene que registrar uno")
                        self.activityIndicator.stopAnimating()
                    dispatch_async(dispatch_get_main_queue()) {
                        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("CarRegistrationMenu")! as! UINavigationController
                    
                        self.presentViewController(detailController, animated: true, completion: nil)
                        }
                    }
                } else {
                    println(errorGetting!)
                    println("Error display alert")
                    self.displayAlert("Failed Login", message: errorGetting!)
                }
            })
        }
    }
    
}
