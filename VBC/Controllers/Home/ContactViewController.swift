//
//  ContactViewController.swift
//  VBC
//
//  Created by VELJKO on 30.10.21..
//

import UIKit

class ContactViewController: UIViewController {
    
    // Image and Text Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var workTwoLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    // Address Outlets
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var postNumberLabel: UILabel!
    @IBOutlet weak var streetNameLabel: UILabel!
    @IBOutlet weak var placeNumberLabel: UILabel!
    
    // Phone Numbers Outlets
    
    @IBOutlet weak var phoneOneLabel: UILabel!
    @IBOutlet weak var phoneTwoLabel: UILabel!
    @IBOutlet weak var phoneThreeLabel: UILabel!
    
    // Email Address Outlets
    
    @IBOutlet weak var emailOneLabel: UILabel!
    @IBOutlet weak var emailTwoLabel: UILabel!
    
    // Website Outlets
    
    @IBOutlet weak var websiteOneLabel: UILabel!
    @IBOutlet weak var websiteTwoLabel: UILabel!
    
    // - - - - - STACK OUTLETS - - - - -
    
    // Phone Stack Outlets
    @IBOutlet weak var phoneTwoStack: UIStackView!
    @IBOutlet weak var phoneThreeStack: UIStackView!
    
    // Email Stack Outlets
    @IBOutlet weak var emailTwoStack: UIStackView!
    
    // Website Stack Outlets
    @IBOutlet weak var websiteTwoStack: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = "Metalac AD"
        workLabel.text = "Bela Tehnika"
        workTwoLabel.text = "Bojleri"
        cityLabel.text = "Gornji Milanovac"

    }
    


}
