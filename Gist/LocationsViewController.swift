//
//  Locations.swift
//  Gist
//
//  Created by Dad on 9/3/16.
//  Copyright © 2016 Natsys. All rights reserved.
//

import UIKit


class LocationsViewController: UIViewController {
 
    
    override func viewWillAppear(animated: Bool) {
        
        
    }
    
    
    
    override func viewDidLoad() {
        
        /*
         print("More Vc will appear")
         // self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil )
         self.navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil )
         */
        
        
        
        let backButton = UIBarButtonItem(title: "< Home", style: UIBarButtonItemStyle.Plain, target: self, action: "goBack")
        navigationItem.leftBarButtonItem = backButton
        navigationItem.backBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 12)!], forState: UIControlState.Normal)
       
        
    }
    
    
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    
    
    
    
    
    
    
}