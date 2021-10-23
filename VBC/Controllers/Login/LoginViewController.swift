//
//  LoginViewController.swift
//  VBC
//
//  Created by VELJKO on 23.10.21..
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "loginSegue", sender: self)
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
    }
    
}
