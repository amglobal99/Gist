//
//  LoginViewController.swift
//  Gist
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
