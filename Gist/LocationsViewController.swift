//
//  Locations.swift
//  Gist
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
        
        _ = self.navigationController
        
        self.navigationItem.title = "Please"
        //self.navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "Sm", style: .Plain, target: nil, action: nil )
        
        
        
        
        
        print("Loc- end viewdidload")
        
        
        
    }  // end function
    
    
    
    

    
    
    func goBack(_ button: UIBarButtonItem) {
       _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
