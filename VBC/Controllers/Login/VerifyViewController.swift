//
//  VerifyViewController.swift
//  VBC
//
//  Created by VELJKO on 28.10.21..
//

import UIKit
import Firebase

class VerifyViewController: UIViewController {
    
    let user = Auth.auth().currentUser

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // Email Verification
    func sendVerificationMail() {
        
        if user != nil && user!.isEmailVerified == false {
            user?.sendEmailVerification(completion: { (error) in
                if error != nil {
                    // Error sending Email verification
                    PopUp().quickPopUp(newTitle: "Verification failed",
                                       newMessage: "Email verification error. Check your internet connection and try again.",
                                       vc: self,
                                       numberOfSeconds: 2)
                } else {
                    // Email verification sent again
                    PopUp().quickPopUp(newTitle: "Email Verification Sent",
                                       newMessage: "",
                                       vc: self,
                                       numberOfSeconds: 1.5)
                }
            })
        }
    }
    

    @IBAction func sendAgainButtonPressed(_ sender: UIButton) {
        sendVerificationMail()
    }
    
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        
        user?.reload(completion: { error in
            
            if self.user?.isEmailVerified == false {
                // Error sending Email verification
                PopUp().popUpWithOk(newTitle: "Email is NOT verified.",
                                    newMessage: "Check your Email and then try again.",
                                    vc: self)
            }
            else {
                self.performSegue(withIdentifier: Constants.Segue.verifyToHome, sender: self)
            }
        
        })
    }
}
