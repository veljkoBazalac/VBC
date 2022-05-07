//
//  AboutViewController.swift
//  VBC
//
//  Created by VELJKO on 30.10.21..
//

import UIKit
import Firebase

class AboutVC: UIViewController {

    // Text Outlets
    @IBOutlet weak var logoImage: UIImageView!
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
    
    var image : UIImage?
    var personalName : String = ""
    var companyName : String = ""
    var sector : String = ""
    var productType : String = ""
    var aboutTitle : String = ""
    
    var editMode : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if companyCard == true {
            personalNameLabel.isHidden = true
        } else {
            aboutTitleLabel.text = aboutTitle
            personalNameLabel.text = personalName
        }
        
        logoImage.image = image
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
       
        if editMode == false {
            
            aboutUsTextView.isEditable = true
            aboutUsTextView.becomeFirstResponder()
        
            editSaveButton.setImage(UIImage(named: "SaveIcon"), for: .normal)
            editMode = true
            
        } else if editMode == true {
            
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
                            PopUp().popUpWithOk(newTitle: "Error!",
                                                newMessage: "Error Uploading data to Database. Please Check your Internet connection and try again.",
                                                vc: self)
                        } else {
        
                            self.aboutUsTextView.isEditable = false
                            self.aboutUsTextView.resignFirstResponder()
                            self.editSaveButton.setImage(UIImage(named: "Edit2Icon"), for: .normal)
                            self.editMode = false
                            
                            PopUp().quickPopUp(newTitle: "Successfully Saved",
                                               newMessage: "Your About Info has been successfully saved.",
                                               vc: self,
                                               numberOfSeconds: 2)
                        }
                    }
            } else {
                PopUp().popUpWithOk(newTitle: "About Info Empty",
                                    newMessage: "Your About Info is Empty. Please Enter your About Informations.",
                                    vc: self)
            }
            
        }
        
        
    }

}

// MARK: - Get About Info from Firestore Database

extension AboutVC {
    
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
