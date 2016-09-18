//
//  FlickrViewController.swift
//  Gist
//
//  Created by Dad on 9/3/16.
//  Copyright © 2016 Natsys. All rights reserved.
//

import UIKit

class FlickrViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "RR",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector( cancelPressed(_:) )
        )
        
        
        
        
        
    }  // end function
    
    
    
    func cancelPressed(_ button: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    



    
    
}
