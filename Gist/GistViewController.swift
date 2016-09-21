
//  GistViewController.swift
// by JAck PAtil

import UIKit
import SafariServices
import UIKit
import BRYXBanner

class GistViewController: UIViewController {

    
    
    //@IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var isStarred: Bool?
    var alertController: UIAlertController?
    var notConnectedBanner: Banner?


    var gist: Gist? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    
    
    //MARK: - Supporting Functions
    
    func configureView() {
        fetchStarredStatus()
        if let detailsView = self.tableView {
            detailsView.reloadData()
        }
    }
    
    func fetchStarredStatus() {
        guard let gistId = gist?.id else {
            return
        }
        GitHubAPIManager.sharedInstance.isGistStarred(gistId) {
            result in
            guard result.error == nil else {
                print(result.error)
                if result.error?.domain != NSURLErrorDomain {return}
                
                if result.error?.code == NSURLErrorUserAuthenticationRequired {
                    self.alertController = UIAlertController(title:
                        "Could not get starred status", message: result.error?.description,
                                                        preferredStyle: .alert)
                    // add ok button
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    self.alertController?.addAction(okAction)
                    self.present(self.alertController!, animated:true,
                                               completion: nil)
                } else if result.error?.code == NSURLErrorNotConnectedToInternet {
                    self.showOrangeNotConnectedBanner("No Internet Connection",
                                                      message: "Can not display starred status. " +
                        "Try again when you're connected to the internet")
                    
                }
                return
            }
            if let status = result.value , self.isStarred == nil { // just got it
                self.isStarred = status
                self.tableView?.insertRows(
                    at: [IndexPath(row: 2, section: 0)],
                    with: .automatic)
            }
        }
    }
    
    func showOrangeNotConnectedBanner(_ title: String, message: String) {
        // show not connected error & tell em to try again when they do have a connection
        // check for existing banner
        if let existingBanner = self.notConnectedBanner {
            existingBanner.dismiss()
        }
        self.notConnectedBanner = Banner(title: title,
                                         subtitle: message,
                                         image: nil,
                                         backgroundColor: UIColor.orange)
        self.notConnectedBanner?.dismissesOnSwipe = true
        self.notConnectedBanner?.show(duration: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let existingBanner = self.notConnectedBanner{
            existingBanner.dismiss()
        }
        super.viewWillDisappear(animated)
    }
    
    
    
    
    //MARK: - Stat/Unstar
    
    func starThisGist() {
        guard let gistId = gist?.id else {
            return
        }
        GitHubAPIManager.sharedInstance.starGist(gistId) {
            (error) in
            guard error == nil else {
                print(error)
                if error?.domain == NSURLErrorDomain &&
                    error?.code == NSURLErrorUserAuthenticationRequired {
                    self.alertController = UIAlertController(title: "Could not star gist",
                                                             message: error?.description,
                                                             preferredStyle: .alert)
                } else {
                    self.alertController = UIAlertController(title: "Could not star gist",
                                                             message: "Sorry, your gist couldn't be starred. " +
                        "Maybe GitHub is down or you don't have an internet connection.",
                                                             preferredStyle: .alert)
                }
                // add ok button
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                self.alertController?.addAction(okAction)
                self.present(self.alertController!, animated:true, completion: nil)
                return
            }
            self.isStarred = true
            self.tableView.reloadRows(
                at: [IndexPath(row: 2, section: 0)],
                with: .automatic)
        }
    }
    
    func unstarThisGist() {
        guard let gistId = gist?.id else {
            return
        }
        GitHubAPIManager.sharedInstance.unstarGist(gistId) {
            (error) in
            guard error == nil else {
                print(error)
                if error?.domain == NSURLErrorDomain &&
                    error?.code == NSURLErrorUserAuthenticationRequired {
                    self.alertController = UIAlertController(title: "Could not unstar gist",
                                                             message: error?.description,
                                                             preferredStyle: .alert)
                } else {
                    self.alertController = UIAlertController(title: "Could not unstar gist",
                                                             message: "Sorry, your gist couldn't be unstarred. " +
                        "Maybe GitHub is down or you don't have an internet connection.",
                                                             preferredStyle: .alert)
                }
                // add ok button
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                self.alertController?.addAction(okAction)
                self.present(self.alertController!, animated:true, completion: nil)
                return
            }
            self.isStarred = false
            self.tableView.reloadRows(
                at: [IndexPath(row: 2, section: 0)],
                with: .automatic)
        }
    }
    
    

    
    //MARK: - Table View
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let _ = isStarred {
                return 3
            }
            return 2
        } else {
            return gist?.files?.count ?? 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "About"
        } else {
            return "Files"
        }
    }
    

    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row, isStarred) {
                case (0, 0, _):
                    cell.textLabel?.text = gist?.description
                case (0, 1, _):
                    cell.textLabel?.text = gist?.ownerLogin
                case (0, 2, .none):
                    cell.textLabel?.text = ""
                case (0, 2, .some(true)):
                    cell.textLabel?.text = "Unstar"
                case (0, 2, .some(false)):
                    cell.textLabel?.text = "Star"
                default: // section 1
                    cell.textLabel?.text = gist?.files?[(indexPath as NSIndexPath).row].filename
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row, isStarred){
        case (0, 2, .some(true)):
            unstarThisGist()
        case (0, 2, .some(false)):
            starThisGist()
        case (1, _, _):
            guard let file = gist?.files?[(indexPath as NSIndexPath).row],
                let urlString = file.raw_url,
                let url = URL(string: urlString) else {
                    return
            }
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.title = file.filename
            self.navigationController?.pushViewController(safariViewController, animated: true)
        default:
            print("No-op")
        }
    }
    

}  // end class

