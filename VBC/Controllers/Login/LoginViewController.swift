//
//  LoginViewController.swift
//  VBC
//
//  Created by VELJKO on 23.10.21..
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var autoLoginSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }
   
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        if let email = nameTextField.text, let password = passwordTextField.text {
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
                
            }
        }
        
    }
    
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "newRegSegue", sender: self)
        
    }
}
