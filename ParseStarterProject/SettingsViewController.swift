//
//  SettingsViewController.swift
//  WhereIsTheCar
//
//  Created by mikel lizarralde cabrejas on 18/9/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import CoreData

class SettingsViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var logInSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        if applicationDelegate.userSettings.keepLogIn {
            logInSwitch.setOn(true, animated: true)
        } else {
            logInSwitch.setOn(false, animated: true)
        }
        
        self.logInSwitch.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stateChanged(switchState: UISwitch) {
        dispatch_async(dispatch_get_main_queue(), {
            
            let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        
            if switchState.on {
                applicationDelegate.userSettings.keepLogIn = true
                println("ON")
            } else {
                applicationDelegate.userSettings.keepLogIn = false
                println("OFF")
            }
            CoreDataStackManager.sharedInstance.saveContext()
            
        })
    }
}
