
//  GistsViewController.swift

/*===========================================================

 Starting point seems to be in viewDidAppear
 loadInitialData is called there
 This calls loadGists method
 
 
 
 ************************************************************/

import UIKit
import PINRemoteImage
import SafariServices
import BRYXBanner
import Alamofire


class GistsViewController: UITableViewController, LoginViewDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var gistSegmentedControl: UISegmentedControl!
    
    var notConnectedBanner: Banner?
    var errorBanner: Banner?
    var detailViewController: GistViewController? = nil
    var safariViewController: SFSafariViewController?
    var gists = [Gist]()
    var nextPageURLString: String?
    var isLoading = false
    var dateFormatter = DateFormatter()

    
    
    //MARK: - Segmented Control
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        // clear out the table view
        gists = []
        tableView.reloadData()
        
        // only show add & edit buttons for my gists
        if (gistSegmentedControl.selectedSegmentIndex == 2) {
            self.navigationItem.leftBarButtonItem = self.editButtonItem
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self,  action: #selector(insertNewObject(_:)))
            self.navigationItem.rightBarButtonItem = addButton
        } else {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
        }
        
        // then load the new list of gists
        loadGists(nil)
    }

    
    
    // MARK: - Gist Related
    func loadInitialData() {
        
        
        print("loadInitialData: Started ")
        
        isLoading = true
        GitHubAPIManager.sharedInstance.OAuthTokenCompletionHandler =
            { error in
                guard error == nil else {
                    print(error)
                    self.isLoading = false
                            if error?.domain == NSURLErrorDomain && error?.code == NSURLErrorNotConnectedToInternet {
                                self.showNotConnectedBanner()
                            } else {
                                // Something went wrong, try again
                                self.showOAuthLoginView()
                            }
                    return
                } // end guard
                
                if let _ = self.safariViewController {
                    self.dismiss(animated: false) {}
                }  // end if
                
                self.loadGists(nil)
           }  // end closure
        
        
        
            if (!GitHubAPIManager.sharedInstance.hasOAuthToken()) {
                showOAuthLoginView()
                return
            }
        
        
        
        
        // Start loading Gists here
        loadGists(nil)
        
    }  // end func
    
    
    
    
    

    func loadGists(_ urlToLoad: String?) {
        
        self.isLoading = true
        
        /* ========= This completion handler section is important ==============================
        *
        * This is passed around to other functions
        * ===================================================================*/
        
        let completionHandler: (Result<[Gist], NSError>, String?) -> Void =
            
            { (result, nextPage) in
                self.isLoading = false
                self.nextPageURLString = nextPage
                
                // tell refresh control it can stop showing up now
                if self.refreshControl != nil && self.refreshControl!.isRefreshing {
                    self.refreshControl?.endRefreshing()
                 }  // end if
            
            
                guard result.error == nil else {
                    self.handleLoadGistsError(result.error!)
                    return
                }
                
                guard let fetchedGists = result.value else {
                    print("no gists fetched")
                    return
                }
                
                if urlToLoad == nil {
                    // empty out the gists because we're not loading another page
                    self.gists = []
                }
                
                self.gists += fetchedGists
                
                // update "last updated" title for refresh control
                let now = Date()
                let updateString = "Last Updated at " + self.dateFormatter.string(from: now)
                self.refreshControl?.attributedTitle = NSAttributedString(string: updateString)
                
                self.tableView.reloadData()
                
            }  // end closure
        
        
           // ====================================================================
        
        
        
                switch gistSegmentedControl.selectedSegmentIndex {
                case 0:
                    GitHubAPIManager.sharedInstance.fetchPublicGists(urlToLoad, completionHandler:
                        completionHandler)
                case 1:
                    GitHubAPIManager.sharedInstance.fetchMyStarredGists(urlToLoad, completionHandler:
                        completionHandler)
                case 2:
                    GitHubAPIManager.sharedInstance.fetchMyGists(urlToLoad, completionHandler:
                        completionHandler)
                default:
                    print("got an index that I didn't expect for selectedSegmentIndex")
                }  // end switch
    
    
    }  // end func
    
    
    
    
    
    

    func handleLoadGistsError(_ error: NSError) {
        print(error)
        nextPageURLString = nil
        
        isLoading = false
        
        if error.domain != NSURLErrorDomain {
            return
        }
        
        if error.code == NSURLErrorUserAuthenticationRequired {
            showOAuthLoginView()
        } else if error.code == NSURLErrorNotConnectedToInternet {
            showNotConnectedBanner()
        }
    }
    
    func showOAuthLoginView() {
        
        print("showOAuthLoginView: Started...")
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        GitHubAPIManager.sharedInstance.isLoadingOAuthToken = true
        guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
                assert(false, "Misnamed view controller")
                return
        }
        loginVC.delegate = self
        self.present(loginVC, animated: true, completion: nil)
        
        print("showOAuthLogin: completed ")

    }
    
    func didTapLoginButton() {
        print("didTapLoginButton- Started")
        self.dismiss(animated: false) {
             print("didTapLoginButton: controler has beenn dismissed.")
            guard let authURL = GitHubAPIManager.sharedInstance.URLToStartOAuth2Login() else {
                GitHubAPIManager.sharedInstance.OAuthTokenCompletionHandler?(NSError(domain: GitHubAPIManager.ErrorDomain, code: -1,
                    userInfo: [NSLocalizedDescriptionKey:
                        "Could not create an OAuth authorization URL",
                        NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"]))
                return
            }
            self.safariViewController = SFSafariViewController(url: authURL as URL)
            self.safariViewController?.delegate = self
            guard let webViewController = self.safariViewController else {
                return
            }
            self.present(webViewController, animated: true, completion: nil)
            print("didTapLoginBUtton: Completed function processing.")

        }
    }
    
    
    
    
    
    // MARK: - Creation
    func insertNewObject(_ sender: AnyObject) {
        let createVC = CreateGistViewController (nibName: nil, bundle: nil)
        
        self.navigationController?.pushViewController(createVC, animated: true)
    }

    
    
    // MARK: - Pull to Refresh
    func refresh(_ sender:AnyObject) {
        GitHubAPIManager.sharedInstance.isLoadingOAuthToken = false
        nextPageURLString = nil // so it doesn't try to append the results
        GitHubAPIManager.sharedInstance.clearCache()
        loadInitialData()
    }

    
    
    // MARK: - Safari View Controller Delegate
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        // Detect not being able to load the OAuth URL
        if (!didLoadSuccessfully) {
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    //MARK: - Banner Related
    func showNotConnectedBanner() {
        // show not connected error & tell em to try again when they do have a connection
        // check for existing banner
        if let existingBanner = self.notConnectedBanner {
            existingBanner.dismiss()
        }
        self.notConnectedBanner = Banner(title: "No Internet Connection",
                                         subtitle: "Could not load gists." +
            " Try again when you're connected to the internet",
                                         image: nil,
                                         backgroundColor: UIColor.red)
        self.notConnectedBanner?.dismissesOnSwipe = true
        self.notConnectedBanner?.show(duration: nil)
    }

    func showOfflineSaveFailedBanner() {
        if let existingBanner = self.errorBanner {
            existingBanner.dismiss()
        }
        self.errorBanner = Banner(title: "Could not save gists to view offline",
                                  subtitle: "Your iOS device is almost out of free space.\n" +
            "You will only be able to see your gists when you have an internet connection.",
                                  image: nil,
                                  backgroundColor: UIColor.orange)
        self.errorBanner?.dismissesOnSwipe = true
        self.errorBanner?.show(duration: nil)
    }

    
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let gist = gists[(indexPath as NSIndexPath).row] as Gist
                if let detailViewController = (segue.destination as! UINavigationController).topViewController as?  GistViewController {
                    detailViewController.gist = gist
                    detailViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                    detailViewController.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }
    
    

    
    // MARK: - View Related Section
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        /*
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()    // Not neded
      //  let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        //self.navigationItem.rightBarButtonItem = addButton
        
        
        if let split = self.splitViewController {
            
            let controllers = split.viewControllers
            //self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            
            var detailVC: UIViewController?
            
            if controllers.count > 1 {
                self.detailViewController = controllers[1] as? GistViewController
            }
            
            
        } // end if
        
        
        */
        
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            //self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? GistViewController
            
            self.detailViewController = controllers[controllers.count-1] as? GistViewController
        }
        
        
    }  // end fucntion

    
    
    
    // ==============================================
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        // WHAT DOES THIS DO ????
        //self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        
        
        super.viewWillAppear(animated)
    
        
        
        // add refresh control  for pull to refresh
        if (self.refreshControl == nil ) {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
            self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged )
            self.dateFormatter.dateStyle = .short
            self.dateFormatter.timeStyle = .long
        }  // end if
        
    }  // end function
    
    
    // =================================================
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func  viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)

        
        /*
       // print("Starting print method ..")
        GitHubAPIManager.sharedInstance.printPublicGists()
        
        
        //loadGists(nil )
        
        loadInitialData()
        */
        
        
        super.viewDidAppear(animated)
        
        if (!GitHubAPIManager.sharedInstance.isLoadingOAuthToken) {
            loadInitialData()
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let existingBanner = self.notConnectedBanner{
            existingBanner.dismiss()
        }
        super.viewWillDisappear(animated)
    }
    
    
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gists.count
    }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GistCell", for: indexPath)  as! GistCell
        //let item = itemStore.allItems[indexPath.row]

            let gist = gists[(indexPath as NSIndexPath).row]    // get current Gist
        
            if gist.ownerLogin == nil {
                cell.ownerLabel.text = "Not Available"
            } else {
                cell.ownerLabel.text = gist.description
            }
        
            if gist.description != nil && gist.description != "" {
                cell.descriptionLabel.text   = gist.description
            } else {
                cell.descriptionLabel.text = "Blank Field"
            }
        
            cell.ownerImage?.image = nil
        
        /*
        if let urlString = gist.ownerAvatarURL{
            GitHubAPIManager.sharedInstance.imageFromURLString(urlString)   // get image
            {   (image,error) in
                    guard error == nil else {
                        print(error)
                        return
                    }

                    let cellToUpdate = self.tableView?.cellForRowAtIndexPath(indexPath) as! GistCell
                    cellToUpdate.ownerImage?.image = image // will work even if image is nil
                    cellToUpdate.setNeedsLayout()    //Need to relaod the view
                
            } //end closure
            
        } else {
                print("No Avatar for this one")
                //let cellToUpdate = self.tableView?.cellForRowAtIndexPath(indexPath) as! GistCell
                cell.ownerImage?.image = UIImage(named: "placeholder.gif")
        } // if let
        
         */
        
        
        // set cell.ownerImage to display image at gist.ownerAvatarURL
        if let urlString = gist.ownerAvatarURL, let url = URL(string: urlString){
            cell.ownerImage?.pin_setImage(from: url, placeholderImage: UIImage(named:"placeholder.gif"))
           // cell.ownerImage?.pin_setImageFromURL(url, placeholderImage: UIImage(named:"cardStar.png"))
        } else {
           cell.ownerImage?.image = UIImage(named:"placeholder.gif")
            // cell.ownerImage?.image = UIImage(named:"cardStar.png")
        }
        
        
        
        
        
        
        
        // see if we need to load more gists
        if !isLoading {
            let rowsLoaded = gists.count
            let rowsRemaining = rowsLoaded - (indexPath as NSIndexPath).row
            let rowsToLoadFromBottom = 5
            if rowsRemaining <= rowsToLoadFromBottom {
                if let nextPage = nextPageURLString {
                    self.loadGists(nextPage)
                }
            }
        
        }  // isLoading
        
        
    

            return cell
        
    }  // end function
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath:   IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return gistSegmentedControl.selectedSegmentIndex == 2
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle:   UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let gistToDelete = gists[(indexPath as NSIndexPath).row]
            guard let idToDelete = gistToDelete.id else {
                return
            }
            
            // remove from array of gists
            gists.remove(at: (indexPath as NSIndexPath).row)
            
            // remove table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // delete from API
            GitHubAPIManager.sharedInstance.deleteGist(idToDelete) {
                (error) in
                if let _ = error {
                    print(error)
                    // Put it back
                    self.gists.insert(gistToDelete, at: (indexPath as NSIndexPath).row)
                    tableView.insertRows(at: [indexPath], with: .right)
                    // tell them it didn't work
                    let alertController = UIAlertController(title: "Could not delete gist",
                                                            message: "Sorry, your gist couldn't be deleted. Maybe GitHub is "
                                                                + "down or you don't have an internet connection.",
                                                            preferredStyle: .alert)
                    // add ok button
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    // show the alert
                    self.present(alertController, animated:true, completion: nil)
                }
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array,
            // and add a new row to the table view.
        }
    }
    
    
    
}  // end class

