//
//  AddNewVBCViewController.swift
//  VBC
//
//  Created by VELJKO on 14.11.21..
//

import UIKit

class AddNewVBCViewController: UIViewController {
    
    var createCompanyCard : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func createCompanyVBCPressed(_ sender: UIButton) {
        createCompanyCard = true
        performSegue(withIdentifier: Constants.Segue.addNew1, sender: self)
    }
    
    
    @IBAction func CreatePersonalVBCPressed(_ sender: UIButton) {
        createCompanyCard = false
        performSegue(withIdentifier: Constants.Segue.addNew1, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.addNew1 {
            
            let destinationVC = segue.destination as! CAdd1ViewController
            destinationVC.companyCard = createCompanyCard
        }
    }
    
}
