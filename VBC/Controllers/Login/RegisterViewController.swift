//
//  RegisterViewController.swift
//  VBC
//
//  Created by VELJKO on 23.10.21..
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    //TextField Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    
    // Error Label Text
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        errorLabel.alpha = 0
    }
    
    // Check the fields and validate that data is correct. If everything is correct, this method returns nil. Otherwise, it returns error message.
    
    func validateFields() -> String? {
        
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || repeatTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill all the fields."
        }
        else if passwordTextField.text!.count < 6 || repeatTextField.text!.count < 6 {
            
            return "Password must contain at least 6 characters."
        }
        else if repeatTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            
            return "Passwords are not the same. Please enter same password."
        }
        return nil
    }
    
    
    // Email Verification
    
    func sendVerificationMail() {
        
        let user = Auth.auth().currentUser
        
        if user != nil && user!.isEmailVerified == false {
            user?.sendEmailVerification(completion: { (error) in
                // Notify the user that the mail has sent or couldn't because of an error.
                if error != nil {
                    // Error sending Email verification
                    let alert = UIAlertController(title: "Verification failed.", message: "Email verification error. Please try again.", preferredStyle: .alert)
            
                    self.present(alert, animated: true, completion: nil)
                    
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    
                } else {
                    
                    self.performSegue(withIdentifier: Constants.Segue.regToVerify, sender: self)
                }
            })
        }
    }
    
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        // Validate the fields
        
        let error = validateFields()
        
        if error != nil {
            // If fields are not correct, show error.
            showError(error!)
        } else {
            
            // Create a user
            if let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), repeatTextField.text == passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    // Check for errors
                    
                    if error != nil {
                        // There was an error
                        
                        self.showError(error!.localizedDescription)
                        print(error!)
                    } else {
                        // User created successfully
                        
                        self.sendVerificationMail()
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
