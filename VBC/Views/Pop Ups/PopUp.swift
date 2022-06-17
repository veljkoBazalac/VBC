//
//  PopUp.swift
//  VBC
//
//  Created by VELJKO on 3.4.22..
//

import UIKit

class PopUp: UIView {
    // Default Apple Pop Ups.
    
    // Pop Up with Ok Button
    func popUpWithOk(newTitle: String, newMessage: String, vc: UIViewController) {
        
        let alert = UIAlertController(title: newTitle, message: newMessage, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(actionOK)
        vc.present(alert, animated: true, completion: nil)
    }
    
    // Pop Up that dismiss after numberOfSeconds
    func quickPopUp(newTitle: String, newMessage: String, vc: UIViewController, numberOfSeconds: Double) {
        let alert = UIAlertController(title: newTitle,
                                      message: newMessage,
                                      preferredStyle: .alert)
        
        vc.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + numberOfSeconds) {
                vc.dismiss(animated: true, completion: nil)
            }
    }
    
}
