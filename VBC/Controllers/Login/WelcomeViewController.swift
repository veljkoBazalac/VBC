//
//  WelcomeViewController.swift
//  VBC
//
//  Created by VELJKO on 28.10.21..
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
            if Auth.auth().currentUser != nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
                self.view.window!.rootViewController = initialViewController
            } else {
                
                print("User not logged In.")
            }
        }


}
