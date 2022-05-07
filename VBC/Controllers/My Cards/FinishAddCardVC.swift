//
//  FinishedAddVBCViewController.swift
//  VBC
//
//  Created by VELJKO on 14.11.21..
//

import UIKit

class FinishAddCardVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    

    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    

}
