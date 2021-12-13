//
//  CardViewController.swift
//  VBC
//
//  Created by VELJKO on 30.10.21..
//

import UIKit
import Firebase
import FirebaseStorage

class CardViewController: UIViewController {

    // Logo and Text Outlets
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var productTypeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Storage
    let storage = Storage.storage().reference()
    
    var cardID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        getCompanyCard()
        
        print(cardID)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func getCompanyCard() {
        
        let user = Auth.auth().currentUser?.uid
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(user!)
            .document(Constants.Firestore.CollectionName.singlePlace)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error getting Multiple Places List. \(e)")
                } else {
                    
                    print ("Ovdeeee")
                    if document != nil && document!.exists {
                        
                        let data = document!.data()
                        
                        print(data)
                        if let companyName = data![Constants.Firestore.Key.Name] as? String {
                            print(companyName)
                                if let companySector = data![Constants.Firestore.Key.sector] as? String {
                                    print(companySector)
                                    if let companyProductType = data![Constants.Firestore.Key.type] as? String {
                                        print(companyProductType)
                                        if let companyCountry = data![Constants.Firestore.Key.country] as? String {
                                            
                                            print(companyCountry)
                                            
                                                self.nameLabel.text = companyName
                                                self.sectorLabel.text = companySector
                                                self.productTypeLabel.text = companyProductType
                                                self.countryLabel.text = companyCountry
                                            
                                        }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    

    
// MARK: - Contact Buttons
    
    // Call Button
    @IBAction func callButtonPressed(_ sender: UITapGestureRecognizer) {
        
        print("Call Pressed")
        
        print(cardID)
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
