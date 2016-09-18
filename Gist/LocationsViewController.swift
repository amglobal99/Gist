//
//  Locations.swift
//  Gist
//
//  Created by Dad on 9/3/16.
//  Copyright © 2016 Natsys. All rights reserved.
//

import UIKit


class LocationsViewController: UIViewController {
 
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        print("Loc -viewDidLoad")
       
       // self.navigationController?.navigationBar.topItem?.title = "new"
        //self.navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "Big", style: .Plain, target: nil, action: nil )
        
        let nc = self.navigationController
        
        self.navigationItem.title = "Please"
        //self.navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "Sm", style: .Plain, target: nil, action: nil )
        
        
        
        
        
        print("Loc- end viewdidload")
        
        
        
    }  // end function
    
    
    
    

    
    
    func goBack(_ button: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
