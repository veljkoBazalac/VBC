//
//  RegisterViewController.swift
//  VBC
//
//  Created by VELJKO on 23.10.21..
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    
    //TextField Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Validate Fields Function
    
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
    
    // MARK: - Register Button Pressed
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        // Validate the fields
        
        let error = validateFields()
        
        if error != nil {
            // If fields are not correct, show error.
            PopUp().popUpWithOk(newTitle: "Error",
                                newMessage: "\(error!)",
                                vc: self)
        } else {
            // Create a user
            if let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), repeatTextField.text == passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                
                DispatchQueue.main.async {
                    Auth.auth().createUser(withEmail: email, password: password) { authResult , error in
                        if error != nil {
                            // There was an error
                            PopUp().popUpWithOk(newTitle: "Error",
                                                newMessage: "\(error!.localizedDescription)",
                                                vc: self)
                        } else {
                            
                            authResult?.user.sendEmailVerification(completion: { (error) in
                                if error != nil {
                                    // Error sending Email verification
                                    PopUp().popUpWithOk(newTitle: "Verification Error",
                                                        newMessage: "Error sending verification Email. Please try again.",
                                                        vc: self)
                                } else {
                                    self.performSegue(withIdentifier: Constants.Segue.regToVerify, sender: self)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
}
