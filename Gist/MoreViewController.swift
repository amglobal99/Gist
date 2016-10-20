//
//  MoreViewController.swift
//  Gist
//


import Foundation
import UIKit


class MoreViewController: UITableViewController {
    
 
    var moreItems: [String] = ["Locations  >","Flickr Photos  >","News  >", "Weather  >"]
    
    
    
    /*
    required init?  (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //navigationItem.leftBarButtonItem = editButtonItem()
        navigationItem.title = "My First"
    }
   */
    
    

    override func viewDidLoad() {
        //print("Morevc -1")
        self.navigationItem.title = "My First"
        //print("MOrevc -2")
    }  // end method
    
    
    
    func goBack (_ button: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print("tableView - Number of rows in section :  \(moreItems.count)")
            return moreItems.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            if((indexPath as NSIndexPath).row == 0)  {
                let locationVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationsVC") as? LocationsViewController
                self.navigationController?.pushViewController(locationVC!, animated: true)
            }  else if((indexPath as NSIndexPath).row == 1)         {
                let flickrVC = self.storyboard?.instantiateViewController(withIdentifier: "FlickrVC") as? FlickrViewController
                self.navigationController?.pushViewController(flickrVC!, animated: true)
            } else if((indexPath as NSIndexPath).row == 2) {
                let newsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsVC") as? NewsViewController
                self.navigationController?.pushViewController(newsVC!, animated: true)
            } else if((indexPath as NSIndexPath).row == 3) {
                let weatherVC = self.storyboard?.instantiateViewController(withIdentifier: "WeatherVC") as? WeatherViewController
                self.navigationController?.pushViewController(weatherVC!, animated: true)
            }  // end if
        
            
    }  // end method
    
    
    
    
    
    
    // ==== This returns a CUSTOM CELL for our Table View ==============================
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("tableView - cellForRow method")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreCell", for: indexPath)  as! MoreCell
        let more = moreItems[(indexPath as NSIndexPath).row]    // get current Menu Item from moreItems array
        cell.moreLabel.text = more
        // let cell = UITableViewCell(style: .Default, reuseIdentifier: "MoreCell")
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.brown.cgColor
        return cell
        
    }  // end function
    
    // *************************************
    
    
    
    
    
    
    
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
