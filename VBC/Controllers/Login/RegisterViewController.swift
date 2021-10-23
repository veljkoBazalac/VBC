//
//  RegisterViewController.swift
//  VBC
//
//  Created by VELJKO on 23.10.21..
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        if self.repeatTextField.text != self.passwordTextField.text {
            
            
            
        }
        
        if let email = nameTextField.text, let password = passwordTextField.text, repeatTextField.text == passwordTextField.text {
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
              
                if let e = error {
                    print(e)
                } else {
                    self.performSegue(withIdentifier: "registerSegue", sender: self)
                }
            }
        }
    }
    
}
