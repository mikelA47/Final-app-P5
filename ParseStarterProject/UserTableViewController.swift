//
//  UserTableViewController.swift
//  WhereIsTheCar
//
//  Created by mikel lizarralde cabrejas on 10/9/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadDrivers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cellReuseIdentifier = "UserCell"

        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)! as! UITableViewCell
        
        if ParseClient.sharedInstance().drivers[indexPath.row].carID == ParseClient.sharedInstance().user.carID {
            cell.textLabel!.text = ParseClient.sharedInstance().drivers[indexPath.row].userID
        }
        
        if ParseClient.sharedInstance().drivers[indexPath.row].driving {
            cell.detailTextLabel!.text = "driving"
        } else {
            cell.detailTextLabel!.text = ""
        }

        println(cell.textLabel!.text! + ":" + cell.detailTextLabel!.text!)

        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return ParseClient.sharedInstance().drivers.count
    }
    
    func reloadDrivers()
    {
        self.tableView.reloadData()
    }

}
