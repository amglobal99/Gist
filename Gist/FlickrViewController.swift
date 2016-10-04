//
//  FlickrViewController.swift
//  Gist
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
