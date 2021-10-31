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
    
    // Follow and Like Outlets
    @IBOutlet weak var followNumber: UILabel!
    @IBOutlet weak var likeNumber: UILabel!
    @IBOutlet weak var dislikeNumber: UILabel!
    
    // Like and Dislike Image Outlets
    @IBOutlet weak var likeImageView: UIStackView!
    @IBOutlet weak var dislikeImageView: UIImageView!
    
    // Images Outlets
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var imageThree: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        nameLabel.text = "Metalac AD"
        workLabel.text = "Bela Tehnika"
        workTwoLabel.text = "Bojleri"
        cityLabel.text = "Gornji Milanovac"
        
        // Image Corners Change
        imageCorners(image: imageOne)
        imageCorners(image: imageTwo)
        imageCorners(image: imageThree)
          
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func imageCorners(image: UIImageView) {
        image.layer.cornerRadius = image.frame.size.height / 10
    }
    
    
    // Button Manipulation
    
    // Like and Comment Pressed
    @IBAction func followAndLikeTapped(_ sender: UITapGestureRecognizer) {
        
        performSegue(withIdentifier: Constants.Segue.cardToLike, sender: self)
    }
    
    // Images Pressed
    @IBAction func imagesTapped(_ sender: UITapGestureRecognizer) {
        
        performSegue(withIdentifier: Constants.Segue.cardToImages, sender: self)
    }
    
    // About Button Pressed
    @IBAction func aboutButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: Constants.Segue.cardToAbout, sender: self)
    }
    
    // Contact Button Pressed
    @IBAction func contactButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: Constants.Segue.cardToContact, sender: self)
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
    }
    
    
    
}
