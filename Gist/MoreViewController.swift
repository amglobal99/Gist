//
//  MoreViewController.swift
//  Gist
//
//  Created by Dad on 6/30/16.
//  Copyright © 2016 Natsys. All rights reserved.
//

import Foundation
import UIKit


class MoreViewController: UITableViewController {
    
    
    //@IBOutlet var moreLabel: UILabel!
 
    
    var moreItems: [String] = ["Locations","Flickr Photos","News", "Weather"]
    
    

    override func viewDidLoad() {
        
        /*
        print("More Vc will appear")
       // self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil )
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil )
        */
        
        /*
        
        let backButton = UIBarButtonItem(title: "< Home", style: UIBarButtonItemStyle.Plain, target: self, action: "goBack")
        self.navigationItem.leftBarButtonItem = backButton
        navigationItem.backBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 12)!], forState: UIControlState.Normal)
        
        
        */
        
        
        
        
        
    }
    
    
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreItems.count
    }
    
    
    
    
    /*
        This gets called when user clicks any Row
 
    */
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if(indexPath.row == 0)  {
            
            print("Row 1 was selected")
            let locationVC = self.storyboard?.instantiateViewControllerWithIdentifier("LocationsVC") as? LocationsViewController
            
            self.navigationController?.pushViewController(locationVC!, animated: true)
            
            //self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil )
        

        }  else if(indexPath.row == 1)         {
        
            print("Row 2 was selected")
            let newsVC = self.storyboard?.instantiateViewControllerWithIdentifier("NewsVC") as? NewsViewController
            self.navigationController?.pushViewController(newsVC!, animated: true)
            
        
        } else if(indexPath.row == 2) {
            
            print("Row 3 was selected")
            let flickrVC = self.storyboard?.instantiateViewControllerWithIdentifier("FlickrVC") as? FlickrViewController
            self.navigationController?.pushViewController(flickrVC!, animated: true)
        
    
        } else if(indexPath.row == 3 ) {
            print("Row 4 was selected")
            let weatherVC = self.storyboard?.instantiateViewControllerWithIdentifier("WeatherVC") as? WeatherViewController
            self.navigationController?.pushViewController(weatherVC!, animated: true)


        }  // end if
        
            
    }  // end method
    
    
    
    
    
    
    
    
    /*
    
    // ==== This returns a custom Cell for our Table View ==============================
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MoreCell", forIndexPath: indexPath)  as! MoreCell
        
        let more = moreItems[indexPath.row]    // get current Menu Item from moreItems array
        
        cell.moLabel.text = more
            //cell.moLabel.text = "Jack"
        
        
        
        
        
    // let cell = UITableViewCell(style: .Default, reuseIdentifier: "MoreCell")
        
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.grayColor().CGColor
        
        
        return cell
        
    }  // end function
    
    // *************************************
    
    */
    
    
    
    
    
    /*
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath:   NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return gistSegmentedControl.selectedSegmentIndex == 2
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle:   UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let gistToDelete = gists[indexPath.row]
            guard let idToDelete = gistToDelete.id else {
                return
            }
            
            // remove from array of gists
            gists.removeAtIndex(indexPath.row)
            
            // remove table view row
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // delete from API
            GitHubAPIManager.sharedInstance.deleteGist(idToDelete) {
                (error) in
                if let _ = error {
                    print(error)
                    // Put it back
                    self.gists.insert(gistToDelete, atIndex: indexPath.row)
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
                    // tell them it didn't work
                    let alertController = UIAlertController(title: "Could not delete gist",
                                                            message: "Sorry, your gist couldn't be deleted. Maybe GitHub is "
                                                                + "down or you don't have an internet connection.",
                                                            preferredStyle: .Alert)
                    // add ok button
                    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(okAction)
                    // show the alert
                    self.presentViewController(alertController, animated:true, completion: nil)
                }
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array,
            // and add a new row to the table view.
        }
    }
    
    

    */
    
    
    

    
    
}  // end class