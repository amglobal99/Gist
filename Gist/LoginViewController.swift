//
//  LoginViewController.swift
//  Gist
//
//  Created by Dad on 6/27/16.
//  Copyright © 2016 Natsys. All rights reserved.
//

import Foundation
import UIKit


protocol LoginViewDelegate: class  {
    func didTapLoginButton()
    
}



class LoginViewController: UIViewController {
    
    
    weak var delegate: LoginViewDelegate?
    
    
    @IBAction func TappedLoginButton() {
        delegate?.didTapLoginButton()
    }
    
    
}