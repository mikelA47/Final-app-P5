//
//  ParseClient.swift
//  WhereIsTheCar
//
//  Created by mikel lizarralde cabrejas on 15/9/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import Parse
import MapKit
import CoreData

class ParseClient: NSObject {

    let ApiKey : String = "z1Iip2wkWrja9GNbdcpDj69N9kiEZgxxNCsZzSma"
    let ApplicationID : String = "4YepP5fyOqRYGQaaZB5gY1wL3xQQrwZJ6AVNsKDC"
    
    //where to store the students info from Parse
    var drivers = [Driver]()
    
    var user = Driver(userID: "",objectID: "")
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func updateCurrentUser(completionHandler: (success: Bool,errorGetting:String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/Driver?where=%7B%22username%22%3A%22"+PFUser.currentUser()!.username!+"%22%7D")!)
        request.addValue(self.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(self.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        println("1.- Sesion Creada")
        let task = session.dataTaskWithRequest(request) { data, response, error in
        if error != nil { // Handle error...
            println("MAL. error: \(error)")
            completionHandler(success: false, errorGetting: error?.description)
        }
        
        var parsingError: NSError? = nil
        
        let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
        if let error = parsingError {
            completionHandler(success: false, errorGetting: error.description)
        } else {
            if let results = parsedResult["results"] as? [[String: AnyObject]] {
                for result in results {
                    println("BIEN. Driver user actual found")
                    self.user = Driver(dictionary: result)
                }
                completionHandler(success: true, errorGetting: nil)
            } else {
                //send error
                completionHandler(success: false, errorGetting: "Could not find any results")
                }
            }
        }
        
        task.resume()
    }

    func gettingDrivers(completionHandler: (success: Bool,errorGetting:String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/Driver?where=%7B%22carID%22%3A%22"+self.user.carID+"%22%7D")!)
        request.addValue(self.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(self.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        println("1.- Sesion Creada")
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                println("MAL. error: \(error)")
                completionHandler(success: false, errorGetting: error?.description)
            }
            
            var parsingError: NSError? = nil
            
            let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            if let error = parsingError {
                completionHandler(success: false, errorGetting: error.description)
            } else {
                if let results = parsedResult["results"] as? [[String: AnyObject]] {
                    self.drivers.removeAll(keepCapacity: true)
                    for result in results {
                        self.drivers.append(Driver(dictionary: result))
                    }
                    for driver_ in self.drivers {
                        println("\(driver_.userID):\(driver_.driving)")
                    }
                    completionHandler(success: true, errorGetting: nil)
                } else {
                    //send error
                    completionHandler(success: false, errorGetting: "Could not find any results")
                }
            }
        }
        
        task.resume()
    }
    
    func logInParse(username: String, password: String, completionHandler: (success: Bool,errorGetting:String?) -> Void) {
        PFUser.logInWithUsernameInBackground(username, password: password, block: { (userDriver: PFUser?, error: NSError?) -> Void in
            if error == nil && userDriver != nil {
                self.updateCurrentUser({ (success, errorGetting) -> Void in
                    if success {
                        println("current user \(self.user.userID)")
                        completionHandler(success: true, errorGetting: nil)
                    } else {
                        println(errorGetting!)
                        completionHandler(success: false, errorGetting: "Could not find any results")
                    }
                })
            } else {
                println(error!)
                completionHandler(success: false, errorGetting: "Username or password could be wrong")
            }
        })

    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
}
