//
//  WelcomeViewController.swift
//  VBC
//
//  Created by VELJKO on 28.10.21..
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {

    
    let user = Auth.auth().currentUser
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if user != nil && user!.isEmailVerified {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
                self.view.window!.rootViewController = initialViewController
            } else {
                print("User not logged In.")
            }
        }


}
