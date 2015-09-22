//
//  Settings.swift first now is called User 19/9/15
//  WhereIsTheCar
//
//  Created by mikel lizarralde cabrejas on 18/9/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import CoreData
import UIKit


@objc(User)
class User: NSManagedObject {
    
    @NSManaged var keepLogIn: Bool
    @NSManaged var username: String
    @NSManaged var password: String

    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(switchState: Bool, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("User", inManagedObjectContext: context)!
        
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.keepLogIn = switchState
        self.username = ""
        self.password = ""

    }

}
