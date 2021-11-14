//
//  AddNewVBCViewController.swift
//  VBC
//
//  Created by VELJKO on 14.11.21..
//

import UIKit

class AddNewVBCViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func createCompanyVBCPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: Constants.Segue.cAdd1, sender: self)
        
    }
    
    
    @IBAction func CreatePersonalVBCPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: Constants.Segue.pAdd1, sender: self)
        
    }
    

}
