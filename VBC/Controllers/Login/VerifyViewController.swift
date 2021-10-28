//
//  VerifyViewController.swift
//  VBC
//
//  Created by VELJKO on 28.10.21..
//

import UIKit
import Firebase

class VerifyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
                    
                    // Email verification sent again
                    
                    let alert = UIAlertController(title: "Email Verification has been sent", message: "Please check your Email address.", preferredStyle: .alert)
            
                    self.present(alert, animated: true, completion: nil)
                    
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.dismiss(animated: true, completion: nil)
                        }
                }
            })
        }
    }
    
    
    
    

    @IBAction func sendAgainButtonPressed(_ sender: UIButton) {
        
        sendVerificationMail()
    }
    
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        
        let user = Auth.auth().currentUser
        
        user?.reload(completion: { error in
            
            if user?.isEmailVerified == false {
                
                // Error sending Email verification
                let alert = UIAlertController(title: "Email is NOT verified.", message: "Check your Email and then try again.", preferredStyle: .alert)
        
                self.present(alert, animated: true, completion: nil)
                
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.dismiss(animated: true, completion: nil)
                    }
            }
            else {
                self.performSegue(withIdentifier: Constants.Segue.verifyToHome, sender: self)
            }
        
        })
    }
}
