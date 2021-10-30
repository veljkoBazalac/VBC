//
//  LoginViewController.swift
//  VBC
//
//  Created by VELJKO on 23.10.21..
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // Text Fields Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Remember Me Outlet
    @IBOutlet weak var rememberMeSegment: UISegmentedControl!
    
    // Error Label Outlet
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        errorLabel.alpha = 0
    }
    
    // Check the fields and validate that data is correct. If everything is correct, this method returns nil. Otherwise, it returns error message.
    
    func validateFields() -> String? {
        
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill all the fields."
        }
        else if passwordTextField.text!.count < 6 {
            return "Password must contain at least 6 characters."
        }
        return nil
    }
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        // Validate the fields
        
        let error = validateFields()
        
        if error != nil {
            // If fields are not correct, show error.
            
            showError(error!)
        } else {
            
            let user = Auth.auth().currentUser
            
            // Login a user
            if let email = self.emailTextField.text, let password = self.passwordTextField.text {
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    // Check for errors
                    
                    if error != nil {
                        // There was an error
                        
                        self.showError("User do not exist.")
                        print(error!)
                    } else if user != nil {
                        // Login successfully
                        
                        user?.reload(completion: { error in
                            
                            if error != nil {
                                // Error reloading user login data and email verification
                                print("Error reloading...")
                            } else {
                                
                                // Data reloaded
                                
                                if user!.isEmailVerified != true {
                                    
                                    // User is NOT verified
                                    
                                    self.emailTextField.text = ""
                                    self.passwordTextField.text = ""
                                    self.errorLabel.alpha = 0
                                    
                                    self.performSegue(withIdentifier: Constants.Segue.loginToVerify, sender: self)
                                    
                                } else {
                                    
                                    // User is Email verified
                                    
                                    self.emailTextField.text = ""
                                    self.passwordTextField.text = ""
                                    self.errorLabel.alpha = 0
                                    
                                    self.performSegue(withIdentifier: Constants.Segue.loginSegue, sender: self)
                                    
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
}
