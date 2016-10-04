//
//  GlobalSplitViewController.swift
//  Gist
//


import UIKit


class GlobalSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController!,
        onto primaryViewController: UIViewController!) -> Bool {
        
        return true
    }
    
}
