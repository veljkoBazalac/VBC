//
//  CAdd3ViewController.swift
//  VBC
//
//  Created by VELJKO on 14.11.21..
//

import UIKit

class CAdd3ViewController: UIViewController {

    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var companyWorkActivity: UILabel!
    @IBOutlet weak var companyProductType: UILabel!
    
    // Select Location Outlet
    @IBOutlet weak var selectLocation: UITextField!
    
    // Phone Number 1
    @IBOutlet weak var phone1Label: UILabel!
    @IBOutlet weak var phone1Code: UITextField!
    @IBOutlet weak var phone1Number: UITextField!
    @IBOutlet weak var addPhone2: UIButton!
    
    // Phone Number 2
    @IBOutlet weak var phone2Stack: UIStackView!
    @IBOutlet weak var phone2Code: UITextField!
    @IBOutlet weak var phone2Number: UITextField!
    @IBOutlet weak var addPhone3: UIButton!
    
    //Phone Number 3
    @IBOutlet weak var phone3Stack: UIStackView!
    @IBOutlet weak var phone3Code: UITextField!
    @IBOutlet weak var phone3Number: UITextField!
    
    // Email Address 1
    @IBOutlet weak var email1Label: UILabel!
    @IBOutlet weak var email1Address: UITextField!
    @IBOutlet weak var addEmail2: UIButton!
    
    // Email Address 2
    @IBOutlet weak var email2Stack: UIStackView!
    @IBOutlet weak var email2Address: UITextField!
    
    // Website 1
    @IBOutlet weak var website1Label: UILabel!
    @IBOutlet weak var website1Link: UITextField!
    @IBOutlet weak var addWebsite2: UIButton!
    
    // Website 2
    @IBOutlet weak var website2Stack: UIStackView!
    @IBOutlet weak var website2Link: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        phone2Stack.isHidden = true
        phone3Stack.isHidden = true
        email2Stack.isHidden = true
        website2Stack.isHidden = true
        
        
    }

    @IBAction func addPhone2ButtonPressed(_ sender: UIButton) {
        
        if phone1Number.text != "" {
            phone2Stack.isHidden = false
            phone1Label.text = "Phone 1 :"
            addPhone2.isHidden = true
        }
        
        
    }
    
    
    @IBAction func addPhone3ButtonPressed(_ sender: UIButton) {
        
        if phone2Number.text != "" {
            phone3Stack.isHidden = false
            addPhone3.isHidden = true
        }
        
    }
    
    
    @IBAction func addEmail2ButtonPressed(_ sender: UIButton) {
        
        if email1Address.text != "" {
            
            email2Stack.isHidden = false
            email1Label.text = "Email 1 :"
            addEmail2.isHidden = true
        }
        
    }
    
    
    @IBAction func addWebsite2ButtonPressed(_ sender: UIButton) {
        
        if website1Link.text != "" {
            
            website2Stack.isHidden = false
            website1Label.text = "Website 1 :"
            addWebsite2.isHidden = true
        }
    }
    
    @IBAction func finishButtonPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: Constants.Segue.cAddFinish, sender: self)
        
    }
}
