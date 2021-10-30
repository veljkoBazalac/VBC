//
//  CardViewController.swift
//  VBC
//
//  Created by VELJKO on 30.10.21..
//

import UIKit
import Firebase

class CardViewController: UIViewController {

    // Image and Text Outlets
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var workTwoLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    // Follow and Like Outlets
    @IBOutlet weak var followNumber: UILabel!
    @IBOutlet weak var likeNumber: UILabel!
    
    
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
    
    
    @IBAction func aboutButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func contactButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
    }
    
    
    
}
