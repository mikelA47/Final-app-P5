//
//  Driver.swift
//  ParseStarterProject-Swift
//
//  Created by mikel lizarralde cabrejas on 2/9/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import Parse

class Driver {
    
    var userID: String = ""
    var objectID: String = ""
    var carID: String = ""
    var car: Bool = false
    var driving: Bool = false
    
    init(userID: String, objectID: String)
    {
        self.userID = userID
        self.objectID = objectID
    }
    
    init(dictionary: [String: AnyObject]) {
        
        if let userID_ = dictionary["username"] as? String {
            self.userID = userID_
        }
        if let carID_ = dictionary["carID"] as? String {
            self.carID = carID_
        }
        
        if let objectID_ = dictionary["objectId"] as? String {
            self.objectID = objectID_
        }
 
        if let car_ = dictionary["car"] as? Bool {
            self.car = car_
        }
        
        if let driving_ = dictionary["driving"] as? Bool {
            self.driving = driving_
        }
        
    }
    
}
