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
    @IBOutlet weak var dislikeNumber: UILabel!
    
    // Follow and Like Stack Outlets
    @IBOutlet weak var followAndLikeStack: UIStackView!
    
    // Like and Dislike Image Outlets
    @IBOutlet weak var likeImageView: UIStackView!
    @IBOutlet weak var dislikeImageView: UIImageView!
    
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
    
    // Button Manipulation
    
    @IBAction func followAndLikeTapped(_ sender: UITapGestureRecognizer) {
        
        performSegue(withIdentifier: Constants.Segue.cardToLike, sender: self)
    }
    
    @IBAction func aboutButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: Constants.Segue.cardToAbout, sender: self)
    }
    
    @IBAction func contactButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: Constants.Segue.cardToContact, sender: self)
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
    }
    
    
    
}
