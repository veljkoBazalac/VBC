//
//  CardViewController.swift
//  VBC
//
//  Created by VELJKO on 30.10.21..
//

import UIKit
import Firebase

class CardViewController: UIViewController {

    // Logo and Text Outlets
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var workTwoLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        nameLabel.text = "Metalac AD"
        workLabel.text = "Bela Tehnika"
        workTwoLabel.text = "Bojleri"
        cityLabel.text = "Gornji Milanovac"
        
        
          
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    
// MARK: - Contact Buttons
    
    // Call Button
    @IBAction func callButtonPressed(_ sender: UITapGestureRecognizer) {
        print("Call Pressed")
    }
    
    // Email Button
    @IBAction func emailButtonPressed(_ sender: UITapGestureRecognizer) {
        print("Email Pressed")
    }
    
    // Map Button
    @IBAction func mapButtonPressed(_ sender: UITapGestureRecognizer) {
        print("Map Pressed")
    }
    
    // Website Button
    @IBAction func websiteButtonPressed(_ sender: UITapGestureRecognizer) {
        print("Website Pressed")
    }
   
    
// MARK: - Buttons
    
    // About Button Pressed
    @IBAction func aboutButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segue.cardToAbout, sender: self)
    }
    // Save Button Pressed
    @IBAction func saveButtonPressed(_ sender: UIButton) {
    }

}
