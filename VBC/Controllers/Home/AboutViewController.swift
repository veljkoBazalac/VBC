//
//  AboutViewController.swift
//  VBC
//
//  Created by VELJKO on 30.10.21..
//

import UIKit
import Firebase

class AboutViewController: UIViewController {

    // Text Outlets
    @IBOutlet weak var personalNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var productTypeLabel: UILabel!
    
    // About Us Outlet
    @IBOutlet weak var aboutTitleLabel: UILabel!
    @IBOutlet weak var aboutUsTextView: UITextView!
    @IBOutlet weak var editSaveButton: UIButton!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Current Auth User ID
    let user = Auth.auth().currentUser?.uid
    // Card ID
    var cardID : String = ""
    // Company or Personal Card
    var companyCard : Bool = true
    // User ID
    var userID : String = ""
    
    var personalName : String = ""
    var companyName : String = ""
    var sector : String = ""
    var productType : String = ""
    var aboutTitle : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if companyCard == true {
            personalNameLabel.isHidden = true
        } else {
            aboutTitleLabel.text = aboutTitle
            personalNameLabel.text = personalName
        }
        
        companyNameLabel.text = companyName
        sectorLabel.text = sector
        productTypeLabel.text = productType
        
        getAboutInfo()
        
        if user! != userID {
            editSaveButton.isHidden = true
        } else {
            editSaveButton.isHidden = false
        }
    
    }
    
    @IBAction func editSaveButtonPressed(_ sender: UIButton) {
        
        if editSaveButton.titleLabel?.text == "Edit" {
            
            aboutUsTextView.isEditable = true
            aboutUsTextView.becomeFirstResponder()
        
            editSaveButton.setTitle("Save", for: .normal)
            
        } else if editSaveButton.titleLabel?.text == "Save" {
            
            if aboutUsTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 {
                
                // Adding About Text to Firestore Database
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(user!)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(cardID)
                    .collection(Constants.Firestore.CollectionName.aboutSection)
                    .document(Constants.Firestore.CollectionName.about)
                    .setData(["About": aboutUsTextView.text!], merge: true) { error in
                        
                        if error != nil {
                            self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading data to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)")
                        } else {
        
                            self.aboutUsTextView.isEditable = false
                            self.aboutUsTextView.resignFirstResponder()
                            self.editSaveButton.setTitle("Edit", for: .normal)
                            
                            self.popUpWithOk(newTitle: "Successfully Saved", newMessage: "Your About Info has been successfully saved.")
                        }
                    }
            } else {
                popUpWithOk(newTitle: "About Info Empty", newMessage: "Your About Info is Empty. Please Enter your About Informations.")
            }
            
        }
        
        
    }
    
    
    // MARK: - Pop Up With Ok
        
        func popUpWithOk(newTitle: String, newMessage: String) {
            
            let alert = UIAlertController(title: newTitle, message: newMessage, preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "OK", style: .default) { action in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(actionOK)
            present(alert, animated: true, completion: nil)
        }

}

// MARK: - Get About Info from Firestore Database

extension AboutViewController {
    
    func getAboutInfo() {
        
        // Getting About Text from Firestore Database
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.aboutSection)
            .document(Constants.Firestore.CollectionName.about)
            .getDocument { document, error in
                
                if let e = error {
                    print("Error Getting About Info. \(e)")
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let data = document!.data()
                        
                        if let aboutText = data![Constants.Firestore.Key.about] as? String {
                            
                            if aboutText.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                                self.aboutUsTextView.text = aboutText
                            } else {
                                self.aboutUsTextView.text = "Press Edit Button to Enter your About Info"
                            }
                        }
                    }
                }
            }
    }
    
    
}
