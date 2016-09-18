//
//  GlobalSplitViewController.swift
//  Gist
//
//  Created by Dad on 9/2/16.
//  Copyright © 2016 Natsys. All rights reserved.
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
