//
//  CardViewController.swift
//  VBC
//
//  Created by VELJKO on 30.10.21..
//

import UIKit
import Firebase
import FirebaseStorage
import MessageUI
import SafariServices
import FirebaseStorageUI

protocol EditedCardDelegate : AnyObject {
    func getEditedCardID(cardRow : Int, companyCard: Bool)
}

class CardViewController: UIViewController {
    
    // Logo and Text Outlets
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var personalNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var productTypeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    // Location StackView
    @IBOutlet weak var locationStack: UIStackView!
    @IBOutlet weak var selectLocation: UITextField!
    // Buttons Outlets
    @IBOutlet weak var callButton: UIImageView!
    @IBOutlet weak var mailButton: UIImageView!
    @IBOutlet weak var mapButton: UIImageView!
    @IBOutlet weak var websiteButton: UIImageView!
    @IBOutlet weak var socialButton: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Storage
    let storage = Storage.storage().reference()
    // Current Auth User ID
    let user = Auth.auth().currentUser?.uid
    // Card ID
    var cardID : String = ""
    // Single Place or Multiple Places
    var singlePlace : Bool = true
    // Company or Personal Card
    var companyCard : Bool = true
    // PickerView
    var pickerView = UIPickerView()
    // Locations Dictionary
    var locationsList : [Location] = []
    // User ID
    var userID : String = ""
    // Card Saved
    var cardSaved : Bool = false
    // Edit Card
    var cardEdited : Bool = false
    var cityNameForEdit : String = ""
    var streetNameForEdit : String = ""
    var mapForEdit : String = ""
    var locationForEdit : String = ""
    var cardIDForEdit : String = ""
    var cardRowForEdit : Int?
    var cardRowForRemove : Int?
    weak var delegate : EditedCardDelegate?
    
    var phoneNumbersList : [PhoneNumber] = []
    var emailAddressList : [String] = []
    var websiteList : [String] = []
    var mapLink : String = ""
    var socialMediaList : [SocialMedia] = []
    
    var companyHasPhone : Bool = false
    var companyHasEmail : Bool = false
    var companyHasMap : Bool = false
    var companyHasWebsite : Bool = false
    
    var personHasPhone : Bool = false
    var personHasEmail : Bool = false
    var personHasSocial : Bool = false
    var personHasWebsite : Bool = false
    
    var callPressed : Bool = false
    var emailPressed : Bool = false
    var mapPressed : Bool = false
    var websitePressed : Bool = false
    var socialPressed : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.getImage()
        }
        
        if companyCard == true {
            personalNameLabel.isHidden = true
        }
        
        callButton.isHidden = true
        mailButton.isHidden = true
        mapButton.isHidden = true
        websiteButton.isHidden = true
        socialButton.isHidden = true
        
        
        selectLocation.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        if cardEdited == true {
            DispatchQueue.main.async {
                self.getImage()
                self.cardEdited = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
        
        getCardBasicInfo()

        callPressed = false
        emailPressed = false
        mapPressed = false
        websitePressed = false
        socialPressed = false
        getSaveStatus()
    }
    
    // MARK: - Get Image from Storage
    
    func getImage() {
        
        let imagePath = db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(self.userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(self.cardID)
        
        imagePath.getDocument { document, error in
            
            if let e = error {
                print("Error Geting URL from Firestore Database. \(e)")
            } else {
                
                if document != nil && document!.exists {
                    
                    let data = document!.data()
                    
                    if let imageURL = data![Constants.Firestore.Key.imageURL] as? String {
                        
                        if imageURL != "" {
                           
                            if let url = URL(string: imageURL) {
                               
                                DispatchQueue.main.async {
                                    self.logoImage.sd_setImage(with: url, completed: nil)
                                }
                                    
                            } else {
                                DispatchQueue.main.async {
                                    self.logoImage.image = UIImage(named: "LogoImage")
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.logoImage.image = UIImage(named: "LogoImage")
                            }
                        }
                    } else {
                        
                        DispatchQueue.main.async {
                            self.logoImage.image = UIImage(named: "LogoImage")
                        }
                    }
                }
            }
        }
    }
   
    // MARK: - Change Button Title Based on userID and Save Status
    func saveOrEditButton() {
        
        if user! != userID && cardSaved == false {
            DispatchQueue.main.async {
                self.saveButton.setTitle("Save", for: .normal)
            }
        } else if user! != userID && cardSaved == true {
            DispatchQueue.main.async {
                self.saveButton.setTitle("Remove", for: .normal)
            }
        } else if userID == user! {
            DispatchQueue.main.async {
                self.saveButton.setTitle("Edit", for: .normal)
            }
        }
    }
    
    // MARK: - Show Buttons that have Data
    func showButtons() {
        
        if companyHasPhone == true {
            callButton.isHidden = false
        }
        if companyHasEmail == true {
            mailButton.isHidden = false
        }
        if companyHasMap == true {
            mapButton.isHidden = false
        }
        if companyHasWebsite == true {
            websiteButton.isHidden = false
        }
        if personHasSocial == true {
            socialButton.isHidden = false
        }
        
    }
    
    // MARK: - Prepare for Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.cardToPopUp {
            
            let destinationVC = segue.destination as! PopUpCardViewController
            
            if callPressed == true {
                destinationVC.popUpTitle = "Phone Numbers"
            } else if emailPressed == true {
                destinationVC.popUpTitle = "Email Addresses"
            } else if websitePressed == true {
                destinationVC.popUpTitle = "Website Links"
            } else if socialPressed == true {
                destinationVC.popUpTitle = "Social Media"
            }
            
            destinationVC.phoneNumbersList = phoneNumbersList
            destinationVC.emailAddressList = emailAddressList
            destinationVC.websiteList = websiteList
            destinationVC.socialMediaList = socialMediaList
            
            destinationVC.callPressed = callPressed
            destinationVC.emailPressed = emailPressed
            destinationVC.websitePressed = websitePressed
            destinationVC.socialPressed = socialPressed
            
            if companyCard == true {
                destinationVC.companyOrPersonalName = companyNameLabel.text!
            } else {
                destinationVC.companyOrPersonalName = personalNameLabel.text!
            }
            
            callPressed = false
            emailPressed = false
            mapPressed = false
            websitePressed = false
            socialPressed = false
        }
        
        if segue.identifier == Constants.Segue.editStep1 {
            
            let destinationVC = segue.destination as! CAdd1ViewController
            
            cardEdited = true
            self.selectLocation.text = self.locationForEdit
            
            // Card Edit Notification
            let notName = Notification.Name(rawValue: Constants.NotificationKey.cardEdited)
            NotificationCenter.default.post(name: notName, object: self.cardID)
            
            destinationVC.editCard = true
            destinationVC.editCardID = cardID
            destinationVC.editUserID = userID
            destinationVC.companyCard = companyCard
            destinationVC.editImage = logoImage.image
            destinationVC.NavBarTitle1 = "Edit VBC - Step 1/3"
        }
        
        if segue.identifier == Constants.Segue.editStep2 {
            
            let destinationVC = segue.destination as! CAdd2ViewController
            
            cardEdited = true
            self.selectLocation.text = self.locationForEdit
            
            // Card Edit Notification
            let notName = Notification.Name(rawValue: Constants.NotificationKey.cardEdited)
            NotificationCenter.default.post(name: notName, object: self.cardID)
            
            destinationVC.editCard2 = true
            destinationVC.editCardID2 = cardID
            destinationVC.editUserID2 = userID
            destinationVC.editCardSaved2 = cardSaved
            destinationVC.editCardCountry2 = countryLabel.text!
            destinationVC.editSinglePlace2 = singlePlace
            destinationVC.numberOfPlaces = locationsList.count
            
            if singlePlace == true {
                destinationVC.editCardCity2 = cityNameForEdit
                destinationVC.editCardStreet2 = streetNameForEdit
                destinationVC.editCardMap2 = mapForEdit
            }
            
            destinationVC.logoImage2 = logoImage.image!
            destinationVC.companyName2 = companyNameLabel.text!
            destinationVC.sector2 = sectorLabel.text!
            destinationVC.productType2 = productTypeLabel.text!
            destinationVC.NavBarTitle2 = "Edit VBC - Step 2/3"
            
            if companyCard == false {
                destinationVC.personalName2 = personalNameLabel.text!
            }
        }
        
        if segue.identifier == Constants.Segue.editStep3 {
            
            let destinationVC = segue.destination as! CAdd3ViewController
            
            cardEdited = true
            self.selectLocation.text = self.locationForEdit
            
            // Card Edit Notification
            let notName = Notification.Name(rawValue: Constants.NotificationKey.cardEdited)
            NotificationCenter.default.post(name: notName, object: self.cardID)
            
            destinationVC.editCard3 = true
            destinationVC.currentCardID = cardID
            destinationVC.editUserID3 = userID
            destinationVC.editCardSaved3 = cardSaved
            destinationVC.singlePlace = singlePlace
            destinationVC.companyCard3 = companyCard
            destinationVC.editCardLocation = self.selectLocation.text!
            
            if companyCard == false {
                destinationVC.personalName3 = personalNameLabel.text!
            }
            
            destinationVC.logoImage3 = logoImage.image!
            destinationVC.companyName3 = companyNameLabel.text!
            destinationVC.sector3 = sectorLabel.text!
            destinationVC.productType3 = productTypeLabel.text!
            destinationVC.selectedNewCountry = countryLabel.text!
            destinationVC.NavBarTitle3 = "Edit VBC - Step 3/3"
            
            
        }
        
        if segue.identifier == Constants.Segue.cardToAbout {
            
            let destinationVC = segue.destination as! AboutViewController
            
            if companyCard == false {
                destinationVC.personalName = personalNameLabel.text!
                destinationVC.aboutTitle = "About Me"
            }
            
            destinationVC.image = logoImage.image
            destinationVC.companyName = companyNameLabel.text!
            destinationVC.sector = sectorLabel.text!
            destinationVC.productType = productTypeLabel.text!
            destinationVC.companyCard = companyCard
            destinationVC.cardID = cardID
            destinationVC.userID = userID
        }
    }
    
    // MARK: - Logo Image Pressed - Present About
    
    @IBAction func logoPressed(_ sender: UITapGestureRecognizer) {
        // Show Card About
        performSegue(withIdentifier: Constants.Segue.cardToAbout, sender: self)
    }
    
    // MARK: - Call Button
    
    @IBAction func callButtonPressed(_ sender: UITapGestureRecognizer) {
        callPressed = true
        getCardData()
    }
    
    // MARK: - Email Button
    
    @IBAction func emailButtonPressed(_ sender: UITapGestureRecognizer) {
        emailPressed = true
        getCardData()
    }

    // MARK: - Map Button
    
    @IBAction func mapButtonPressed(_ sender: UITapGestureRecognizer) {
        mapPressed = true
        getCardData()
    }
    
    // MARK: - Website Button
    
    @IBAction func websiteButtonPressed(_ sender: UITapGestureRecognizer) {
        websitePressed = true
        getCardData()
    }
    
    // MARK: - Social Button Pressed
    
    @IBAction func socialButtonPressed(_ sender: UITapGestureRecognizer) {
        socialPressed = true
        getCardData()
    }
    
    // MARK: - SHARE AND SAVE BUTTONS

    // Share button Pressed
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        
        // Action Sheet da kopira Card ID
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Basic Info Action
        let copyCardIDAction: UIAlertAction = UIAlertAction(title: "Copy Card ID: \(self.cardID)", style: .default) { action -> Void in

            UIPasteboard.general.string = self.cardID

            PopUp().quickPopUp(newTitle: "Card ID Copied",
                               newMessage: "",
                               vc: self,
                               numberOfSeconds: 1)
        }
        
        // Cancel Action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        
        actionSheetController.addAction(copyCardIDAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    // Save, Remove or Edit Button Pressed
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        if user! != userID && saveButton.titleLabel?.text == "Save" {
            saveVBC()
        } else  if user! != userID && saveButton.titleLabel?.text == "Remove" {
            DispatchQueue.main.async {
                self.removeVBC()
            }
            
        }
        else if user! == userID && saveButton.titleLabel?.text == "Edit" {
            
            let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            // Basic Info Action
            let basicInfoAction: UIAlertAction = UIAlertAction(title: "Basic Info", style: .default) { action -> Void in

                self.performSegue(withIdentifier: Constants.Segue.editStep1, sender: self)
            }
            // Location Info Action
            let locInfoAction: UIAlertAction = UIAlertAction(title: "Location Info", style: .default) { action -> Void in

                self.performSegue(withIdentifier: Constants.Segue.editStep2, sender: self)
            }
            // Contact Info Action
            let contactInfoAction: UIAlertAction = UIAlertAction(title: "Contact Info", style: .default) { action -> Void in

                self.performSegue(withIdentifier: Constants.Segue.editStep3, sender: self)
            }
            
            // Delete VBC
            let deleteCard: UIAlertAction = UIAlertAction(title: "Delete Card", style: .destructive) { action -> Void in

                let alert = UIAlertController(title: "Delete this Card?", message: "If you Delete this Card, all data will be lost for ever.", preferredStyle: .alert)
                
                let actionDelete = UIAlertAction(title: "Delete", style: .destructive) { action in
                    
                    // Delete Locations Subcollection
                    self.deleteLocations()
                    // Delete SavedForUser Subcollection
                    self.deleteSavedForUser()
                    // Delete About Subcollection
                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.data)
                        .collection(Constants.Firestore.CollectionName.users)
                        .document(self.userID)
                        .collection(Constants.Firestore.CollectionName.cardID)
                        .document(self.cardID)
                        .collection(Constants.Firestore.CollectionName.aboutSection)
                        .document(Constants.Firestore.CollectionName.about)
                        .delete()
                    // Delete Card Document and Image from Storage
                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.data)
                        .collection(Constants.Firestore.CollectionName.users)
                        .document(self.userID)
                        .collection(Constants.Firestore.CollectionName.cardID)
                        .document(self.cardID)
                        .delete { error in
                            
                            if let e = error {
                                print("Error Deleting VBC. \(e)")
                            } else {
                                
                                self.storage
                                    .child(Constants.Firestore.Storage.logoImage)
                                    .child(self.userID)
                                    .child("Img.\(self.cardID)")
                                    .delete()
                                
                                // Notification name
                                let NotNameDeletedCard = Notification.Name(rawValue: Constants.NotificationKey.cardDeleted)
                                
                                NotificationCenter.default.post(name: NotNameDeletedCard, object: self.cardID)
                                
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                }
                
                let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
                    alert.dismiss(animated: true, completion: nil)
                }
                
                alert.addAction(actionDelete)
                alert.addAction(actionCancel)
                self.present(alert, animated: true, completion: nil)
                
            }
            
            // Cancel Action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

            actionSheetController.addAction(basicInfoAction)
            actionSheetController.addAction(locInfoAction)
            actionSheetController.addAction(contactInfoAction)
            actionSheetController.addAction(deleteCard)
            actionSheetController.addAction(cancelAction)

            present(actionSheetController, animated: true, completion: nil)
            
        } 
    }

}

// MARK: - Delete Card Data

extension CardViewController {
    
    
    // MARK: - Delete Saved For User Subcollection
    
    func deleteSavedForUser() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.savedForUsers)
            .getDocuments { snapshot, error in
                
                if let e = error {
                    print("Error Deleting Saved For User. \(e)")
                } else {
                    
                    if let snapshotDocuments = snapshot?.documents {
                        
                        for documents in snapshotDocuments {
                            
                            let data = documents.data()
                            
                            if let saverUserID = data[Constants.Firestore.Key.userID] as? String {
                                if let saverCardID = data[Constants.Firestore.Key.cardID] as? String {
                                
                                self.db.collection(Constants.Firestore.CollectionName.VBC)
                                    .document(Constants.Firestore.CollectionName.data)
                                    .collection(Constants.Firestore.CollectionName.users)
                                    .document(saverUserID)
                                    .collection(Constants.Firestore.CollectionName.savedVBC)
                                    .document(saverCardID)
                                    .delete()
                                
                                
                                self.db.collection(Constants.Firestore.CollectionName.VBC)
                                    .document(Constants.Firestore.CollectionName.data)
                                    .collection(Constants.Firestore.CollectionName.users)
                                    .document(self.userID)
                                    .collection(Constants.Firestore.CollectionName.cardID)
                                    .document(self.cardID)
                                    .collection(Constants.Firestore.CollectionName.savedForUsers)
                                    .document(saverUserID)
                                    .delete()
                                }
                            }
                        }
                    }
                }
            }
    }
    
    // MARK: - Delete Locations Subcollection
    
    func deleteLocations() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.locations)
            .getDocuments { snapshot, error in
                
                if let e = error {
                    print("Error Getting Locations for Delete. \(e)")
                } else {
                    
                    if let snapshotDocuments = snapshot?.documents {
                        
                        for documents in snapshotDocuments {
                            
                            let data = documents.data()
                            
                            if let cityName = data[Constants.Firestore.Key.city] as? String {
                                if let streetName = data[Constants.Firestore.Key.street] as? String {
                                    
                                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                                        .document(Constants.Firestore.CollectionName.data)
                                        .collection(Constants.Firestore.CollectionName.users)
                                        .document(self.userID)
                                        .collection(Constants.Firestore.CollectionName.cardID)
                                        .document(self.cardID)
                                        .collection(Constants.Firestore.CollectionName.locations)
                                        .document("\(cityName) - \(streetName)")
                                        .delete { error in
                                            
                                            if let e = error {
                                                print("Error Deleting Location. \(e)")
                                            } else {
                                                
                                                self.db.collection(Constants.Firestore.CollectionName.VBC)
                                                    .document(Constants.Firestore.CollectionName.data)
                                                    .collection(Constants.Firestore.CollectionName.users)
                                                    .document(self.userID)
                                                    .collection(Constants.Firestore.CollectionName.cardID)
                                                    .document(self.cardID)
                                                    .collection(Constants.Firestore.CollectionName.locations)
                                                    .document("\(cityName) - \(streetName)")
                                                    .collection(Constants.Firestore.CollectionName.social)
                                                    .getDocuments { snapshot, error in
                                                        
                                                        if let e = error {
                                                            print("Error Deleting Social Media. \(e)")
                                                        } else {
                                                            
                                                            if let snapshotDocuments = snapshot?.documents {
                                                                
                                                                for documents in snapshotDocuments {
                                                                    
                                                                    let data = documents.data()
                                                                    
                                                                    if let socialName = data[Constants.Firestore.Key.name] as? String {
                                                                        
                                                                        self.db.collection(Constants.Firestore.CollectionName.VBC)
                                                                            .document(Constants.Firestore.CollectionName.data)
                                                                            .collection(Constants.Firestore.CollectionName.users)
                                                                            .document(self.userID)
                                                                            .collection(Constants.Firestore.CollectionName.cardID)
                                                                            .document(self.cardID)
                                                                            .collection(Constants.Firestore.CollectionName.locations)
                                                                            .document("\(cityName) - \(streetName)")
                                                                            .collection(Constants.Firestore.CollectionName.social)
                                                                            .document(socialName)
                                                                            .delete()
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
    }
}

// MARK: - Save or Remove from Wallet

extension CardViewController {
    
    // MARK: - Get Save Status for Card
    
    func getSaveStatus() {
        
        if user! != userID {
        // Getting Save Status Info
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.savedForUsers)
            .document(user!)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error getting Save Status Info. \(e)")
                } else {
                    
                    if document != nil && document!.exists {
                       
                        let data = document!.data()
                        
                        if let savedCard = data![Constants.Firestore.Key.cardSaved] as? Bool {
                           
                            self.cardSaved = savedCard
                            self.saveOrEditButton()
                        }
                    }
                }
            }
        } else {
            self.saveOrEditButton()
        }
    }
    
    // MARK: - Save Card to Wallet
    
    func saveVBC() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.savedVBC)
            .document(cardID)
            .setData(["CardID": cardID, "User ID": userID], merge: true) { error in
                
                if let e = error {
                    print("Error Saving VBC. \(e)")
                } else {
                    
                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.data)
                        .collection(Constants.Firestore.CollectionName.users)
                        .document(self.userID)
                        .collection(Constants.Firestore.CollectionName.cardID)
                        .document(self.cardID)
                        .collection(Constants.Firestore.CollectionName.savedForUsers)
                        .document(self.user!)
                        .setData([Constants.Firestore.Key.cardSaved : true,
                                  Constants.Firestore.Key.userID : self.user!,
                                  Constants.Firestore.Key.cardID : self.cardID])
                    
                    self.cardSaved = true
                    
                    DispatchQueue.main.async {
                        self.saveButton.setTitle("Remove", for: .normal)
                    }
            
                    PopUp().quickPopUp(newTitle: "Saved Successfully",
                                       newMessage: "This VBC will be shown in your Wallet Tab.",
                                       vc: self,
                                       numberOfSeconds: 1.5)
                }
            }
        
    }
    
    // MARK: - Remove Card from Wallet
    
    func removeVBC() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.savedVBC)
            .document(cardID)
            .delete (completion: { error in
                
                if let e = error {
                    print("Error Removing VBC from Wallet. \(e)")
                } else {
                    
                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.data)
                        .collection(Constants.Firestore.CollectionName.users)
                        .document(self.userID)
                        .collection(Constants.Firestore.CollectionName.cardID)
                        .document(self.cardID)
                        .collection(Constants.Firestore.CollectionName.savedForUsers)
                        .document(self.user!)
                        .delete()
                    
                    let notName = Notification.Name(rawValue: Constants.NotificationKey.cardRemoved)
                    
                    NotificationCenter.default.post(name: notName, object: self.cardID)
                    
                    self.cardSaved = false
                    
                    DispatchQueue.main.async {
                        self.saveButton.setTitle("Save", for: .normal)
                    }
                    
                    PopUp().quickPopUp(newTitle: "Removed Successfully",
                                       newMessage: "This VBC has been removed from your Wallet Tab.",
                                       vc: self,
                                       numberOfSeconds: 1.5)
                }
            })
        
    }
}

// MARK: - GET CARD DATA

extension CardViewController {
    
    func getLocationList() {
        
        // Get locations list
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.locations)
            .getDocuments { snapshot, error in
                
                if let e = error {
                    print ("Error getting Multiple Places List. \(e)")
                } else {
                    
                    self.locationsList.removeAll()
                
                    if let snapshotDocuments = snapshot?.documents {
                        
                        for documents in snapshotDocuments {
                            
                            let data = documents.data()
                            
                            // Get Location Data
                            if let cityName = data[Constants.Firestore.Key.city] as? String {
                                if let cityStreet = data[Constants.Firestore.Key.street] as? String {
                                    if let cityMap = data[Constants.Firestore.Key.gMaps] as? String {
                                        
                                        let places = Location(city: cityName, street: cityStreet, gMapsLink: cityMap)
                                        
                                        self.locationsList.append(places)
                                        
                                        self.cityNameForEdit = cityName
                                        self.streetNameForEdit = cityStreet
                                        self.mapForEdit = cityMap
                                        
                                        if self.cardEdited == false {
                                            self.selectLocation.text = "\(self.locationsList.first!.city) - \(self.locationsList.first!.street)"
                                            self.locationForEdit = self.selectLocation.text!
                                        } else {
                                            self.selectLocation.text = self.locationForEdit
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                        if self.locationsList.count <= 1 {
                            self.selectLocation.isEnabled = false
                        } else {
                            self.selectLocation.isEnabled = true
                        }
                    }
                    self.checkCardData()
                }
            }
    }
    
    // MARK: - Check Card Data
    
    func checkCardData() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.locations)
            .document(selectLocation.text!)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error Checking Multiple Places Data. \(e)")
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let data = document!.data()
                        
                        self.companyHasPhone = false
                        self.companyHasEmail = false
                        self.companyHasMap = false
                        self.companyHasWebsite = false
                        
                        // Phone Check
                        if data![Constants.Firestore.Key.phone1] != nil {
                            if (data![Constants.Firestore.Key.phone1] as? String) != "" {
                                self.companyHasPhone = true
                                
                                if (data![Constants.Firestore.Key.phone2] as? String) != "" {
                                    self.companyHasPhone = true
                                    
                                    if (data![Constants.Firestore.Key.phone3] as? String) != "" {
                                        self.companyHasPhone = true
                                    }
                                }
                            }
                        }
                        
                        // Email Check
                        if data![Constants.Firestore.Key.email1] != nil {
                            if (data![Constants.Firestore.Key.email1] as? String) != "" {
                                self.companyHasEmail = true
                                
                                if (data![Constants.Firestore.Key.email2] as? String) != "" {
                                    self.companyHasEmail = true
                                }
                            }
                        }
                        
                        // Map Check
                        if data![Constants.Firestore.Key.gMaps] != nil {
                            if (data![Constants.Firestore.Key.gMaps] as? String) != "" {
                                self.companyHasMap = true
                            }
                        }
                        
                        // Website Check
                        if data![Constants.Firestore.Key.web1] != nil {
                            if (data![Constants.Firestore.Key.web1] as? String) != "" {
                                self.companyHasWebsite = true
                                
                                if (data![Constants.Firestore.Key.web2] as? String) != "" {
                                    self.companyHasWebsite = true
                                }
                            }
                        }
                        // Social Check
                        self.checkSocialData()
                    }
                    DispatchQueue.main.async {
                        self.showButtons()
                    }
                }
            }
    }
    
    // MARK: - Get Card Data
    
    func getCardData() {
        
        if socialPressed == true {
            
            socialMediaList.removeAll()
            
            db.collection(Constants.Firestore.CollectionName.VBC)
                .document(Constants.Firestore.CollectionName.data)
                .collection(Constants.Firestore.CollectionName.users)
                .document(userID)
                .collection(Constants.Firestore.CollectionName.cardID)
                .document(cardID)
                .collection(Constants.Firestore.CollectionName.locations)
                .document(selectLocation.text!)
                .collection(Constants.Firestore.CollectionName.social)
                .getDocuments { snapshot, error in
                
                if let e = error {
                    print ("Error getting Social Media List. \(e)")
                } else {
                    
                    if let snapshotDocuments = snapshot?.documents {
                        
                        for documents in snapshotDocuments {
                           
                            let data = documents.data()
                            
                            if let socialName = data[Constants.Firestore.Key.name] as? String {
                                if let socialLink = data[Constants.Firestore.Key.link] as? String {
                                    
                                        let social = SocialMedia(name: socialName, link: socialLink)
                                     
                                        self.socialMediaList.append(social)
                                }
                            }
                        }
                    }
                }
                    self.performSegue(withIdentifier: Constants.Segue.cardToPopUp, sender: self)
            }
        }
        else {
            // Get Data for Phone Number, Email, Map and Website
            db.collection(Constants.Firestore.CollectionName.VBC)
                .document(Constants.Firestore.CollectionName.data)
                .collection(Constants.Firestore.CollectionName.users)
                .document(userID)
                .collection(Constants.Firestore.CollectionName.cardID)
                .document(cardID)
                .collection(Constants.Firestore.CollectionName.locations)
                .document(selectLocation.text!)
                .getDocument { document, error in
                    
                    if let e = error {
                        print ("Error getting Multiple Places Info. \(e)")
                    } else {
                        
                        if document != nil && document!.exists {
                            
                            let data = document!.data()
                            
                            
                            if self.callPressed == true {
                                
                                self.phoneNumbersList = []
                                
                                // Phone Contact Info
                                if let phoneCode1 = data![Constants.Firestore.Key.phone1code] as? String {
                                    if let phone1 = data![Constants.Firestore.Key.phone1] as? String {
                                        
                                        if phone1 != "" {
                                            let number = PhoneNumber(code: phoneCode1, number: phone1)
                                            self.phoneNumbersList.append(number)
                                        }
                                    }
                                }
                                
                                if let phoneCode2 = data![Constants.Firestore.Key.phone2code] as? String {
                                    if let phone2 = data![Constants.Firestore.Key.phone2] as? String {
                                        
                                        if phone2 != "" {
                                            let number = PhoneNumber(code: phoneCode2, number: phone2)
                                            self.phoneNumbersList.append(number)
                                        }
                                    }
                                }
                                
                                if let phoneCode3 = data![Constants.Firestore.Key.phone3code] as? String {
                                    if let phone3 = data![Constants.Firestore.Key.phone3] as? String {
                                        
                                        if phone3 != "" {
                                            let number = PhoneNumber(code: phoneCode3, number: phone3)
                                            self.phoneNumbersList.append(number)
                                        }
                                    }
                                }
                                self.performSegue(withIdentifier: Constants.Segue.cardToPopUp, sender: self)
                            }
                            
                            if self.emailPressed == true {
                                
                                self.emailAddressList = []
                                
                                // Email Contact Info
                                if let email1 = data![Constants.Firestore.Key.email1] as? String {
                                    if email1 != "" {
                                        self.emailAddressList.append(email1)
                                    }
                                }
                                if let email2 = data![Constants.Firestore.Key.email2] as? String {
                                    if email2 != "" {
                                        self.emailAddressList.append(email2)
                                    }
                                }
                                self.performSegue(withIdentifier: Constants.Segue.cardToPopUp, sender: self)
                            }
                            
                            if self.mapPressed == true {
                                
                                self.mapLink = ""
                                
                                // Map Contact Info
                                if let map = data![Constants.Firestore.Key.gMaps] as? String {
                                    if map != "" {
                                        self.mapLink = map
                                        
                                        if let index = (self.mapLink.range(of: "http")?.lowerBound) {
                                            
                                            let newCleanLink = String(self.mapLink.suffix(from: index))
                                            
                                            DispatchQueue.main.async {
                                                if let gMap = URL(string: newCleanLink), UIApplication.shared.canOpenURL(gMap) {
                                                    UIApplication.shared.open(gMap, options: [:], completionHandler: nil)
                                                } else {
                                                    PopUp().popUpWithOk(newTitle: "Invalid Map Link",
                                                                        newMessage: "Map Link for this location is invalid.",
                                                                        vc: self)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if self.websitePressed == true {
                                
                                self.websiteList = []
                                
                                // Website Contact Info
                                if let web1 = data![Constants.Firestore.Key.web1] as? String {
                                    if web1 != "" {
                                        self.websiteList.append(web1)
                                    }
                                }
                                if let web2 = data![Constants.Firestore.Key.web2] as? String {
                                    if web2 != "" {
                                        self.websiteList.append(web2)
                                    }
                                }
                                self.performSegue(withIdentifier: Constants.Segue.cardToPopUp, sender: self)
                            }
                            
                        }
                    }
                }
        }
    }
    
    // MARK: - Check Social Media Data for Card
    
    func checkSocialData() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.locations)
            .document(selectLocation.text!)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error Checking Personal Card Data. \(e)")
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let data = document!.data()
                        
                        self.personHasSocial = false
                        
                        if data![Constants.Firestore.Key.socialAdded] != nil {
                            if (data![Constants.Firestore.Key.socialAdded] as? Bool) != false {
                                self.personHasSocial = true
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.showButtons()
                    }
                }
            }
    }
    
    // MARK: - Get Card Basic Info
    
    func getCardBasicInfo() {
        
        // Getting Basic Info
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error getting Basic Info. \(e)")
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let data = document!.data()
                        if let companyName = data![Constants.Firestore.Key.companyName] as? String {
                            if let companySector = data![Constants.Firestore.Key.sector] as? String {
                                if let companyProductType = data![Constants.Firestore.Key.type] as? String {
                                    if let companyCountry = data![Constants.Firestore.Key.country] as? String {
                                        if let checkSinglePlace = data![Constants.Firestore.Key.singlePlace] as? Bool {
                                            
                                            self.singlePlace = checkSinglePlace
                                            
                                            if self.singlePlace == true {
                                                self.selectLocation.isEnabled = false
                                            }
                                            
                                            // Basic Card Info
                                            self.companyNameLabel.text = companyName
                                            self.sectorLabel.text = companySector
                                            self.productTypeLabel.text = companyProductType
                                            self.countryLabel.text = companyCountry
                                            
                                            if self.companyCard == false {
                                                if let personalName = data![Constants.Firestore.Key.personalName] as? String {
                                                    self.personalNameLabel.text = personalName
                                                }
                                            }
                                            self.getLocationList()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
}

// MARK: - Picker View Delegate and DataSource
extension CardViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locationsList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(locationsList[row].city) - \(locationsList[row].street)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.selectLocation.text = "\(self.locationsList[row].city) - \(self.locationsList[row].street)"
        
        self.locationForEdit = "\(self.locationsList[row].city) - \(self.locationsList[row].street)"
        
        callButton.isHidden = true
        mailButton.isHidden = true
        mapButton.isHidden = true
        websiteButton.isHidden = true
        socialButton.isHidden = true
        
        self.checkSocialData()
        self.checkCardData()
    }
}
