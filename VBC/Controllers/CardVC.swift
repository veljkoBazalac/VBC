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

class CardVC: UIViewController {
    
    // Logo and Text Outlets
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var personalNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var productTypeLabel: UILabel!
    
    // Location StackView
    @IBOutlet weak var locationStack: UIStackView!
    @IBOutlet weak var selectLocation: UITextField!
    @IBOutlet weak var countryFlag: UIImageView!
    
    // Buttons Outlets
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var socialButton: UIButton!
    // Save Button Outlet
    @IBOutlet weak var saveButton: UIButton!
    
    // PopUp with Table View
    var popUpTableView : PopUpTableView!
    
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
    // Card Country Name
    var countryName : String = ""
    // Edit Card
    var cardEdited : Bool = false
    var cityNameForEdit : String = ""
    var streetNameForEdit : String = ""
    var mapForEdit : String = ""
    var locationForEdit : String = ""
    var cardIDForEdit : String = ""
    var cardRowForEdit : Int?
    var cardRowForRemove : Int?
    // Card Data List
    var phoneNumbersList : [PhoneNumber] = []
    var emailAddressList : [String] = []
    var websiteList : [String] = []
    var mapLink : String = ""
    var socialMediaList : [SocialMedia] = []
    // Card Has Data
    var cardHasPhone : Bool = false
    var cardHasEmail : Bool = false
    var cardHasMap : Bool = false
    var cardHasWebsite : Bool = false
    var cardHasSocial : Bool = false
    // Which Button is Pressed
    var callPressed : Bool = false
    var emailPressed : Bool = false
    var mapPressed : Bool = false
    var websitePressed : Bool = false
    var socialPressed : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get Card Logo Image
        DispatchQueue.main.async {
            self.getImage()
        }
        // If it's Company Card, hide Personal Name
        if companyCard == true {
            personalNameLabel.isHidden = true
        }
        // Hide Buttons
        callButton.isHidden = true
        mailButton.isHidden = true
        mapButton.isHidden = true
        websiteButton.isHidden = true
        socialButton.isHidden = true
        // Prevent User From Touch 2 Buttons simultaneously
        callButton.isExclusiveTouch = true
        mailButton.isExclusiveTouch = true
        mapButton.isExclusiveTouch = true
        websiteButton.isExclusiveTouch = true
        socialButton.isExclusiveTouch = true
        
        // Select Location PickerView
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
        DispatchQueue.main.async {
            self.getCardBasicInfo()
            self.getLocationList()
        }
        getSaveStatus()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoImage.layer.cornerRadius = logoImage.frame.size.height / 30
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
            // If user is NOT owner of the Card and Card is NOT saved to Wallet, user CAN save Card to Wallet.
            DispatchQueue.main.async {
                self.saveButton.setTitle("Save", for: .normal)
            }
        } else if user! != userID && cardSaved == true {
            // If user is NOT owner of the Card and Card IS saved to Wallet, user CAN remove Card from Wallet.
            DispatchQueue.main.async {
                self.saveButton.setTitle("Remove", for: .normal)
            }
        } else if userID == user! {
            // If user is owner of the Card, user CAN edit Card.
            DispatchQueue.main.async {
                self.saveButton.setTitle("Edit", for: .normal)
            }
        }
    }
    
    // MARK: - Prepare for Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.editStep1 {
            
            let destinationVC = segue.destination as! AddStep1VC
            
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
            
            let destinationVC = segue.destination as! AddStep2VC
            
            cardEdited = true
            self.selectLocation.text = self.locationForEdit
            
            // Card Edit Notification
            let notName = Notification.Name(rawValue: Constants.NotificationKey.cardEdited)
            NotificationCenter.default.post(name: notName, object: self.cardID)
            
            destinationVC.editCard2 = true
            destinationVC.editCardID2 = cardID
            destinationVC.editUserID2 = userID
            destinationVC.editCardSaved2 = cardSaved
            destinationVC.editCardCountry2 = self.countryName
            destinationVC.editSinglePlace2 = singlePlace
            destinationVC.numberOfPlaces = locationsList.count
            destinationVC.delegate = self
            
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
            
            let destinationVC = segue.destination as! AddStep3VC
            
            cardEdited = true
            self.selectLocation.text = self.locationForEdit
            
            // Card Edit Notification
            let notName = Notification.Name(rawValue: Constants.NotificationKey.cardEdited)
            NotificationCenter.default.post(name: notName, object: self.cardID)
            
            destinationVC.editCard3 = true
            destinationVC.cardID = cardID
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
            destinationVC.selectedNewCountry = self.countryName
            destinationVC.NavBarTitle3 = "Edit VBC - Step 3/3"
            
        }
        
        if segue.identifier == Constants.Segue.cardToAbout {
            
            let destinationVC = segue.destination as! AboutVC
            
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
    @IBAction func callButtonPressed(_ sender: UIButton) {
        callPressed = true
        callButton.isUserInteractionEnabled = false
        mailButton.isUserInteractionEnabled = false
        mapButton.isUserInteractionEnabled = false
        websiteButton.isUserInteractionEnabled = false
        socialButton.isUserInteractionEnabled = false
        
        if callPressed == true && emailPressed == false && mapPressed == false && websitePressed == false && socialPressed == false {
            DispatchQueue.main.async {
                self.getCardData()
            }
        }
    }
    
    // MARK: - Email Button
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        emailPressed = true
        callButton.isUserInteractionEnabled = false
        mailButton.isUserInteractionEnabled = false
        mapButton.isUserInteractionEnabled = false
        websiteButton.isUserInteractionEnabled = false
        socialButton.isUserInteractionEnabled = false
        
        if callPressed == false && emailPressed == true && mapPressed == false && websitePressed == false && socialPressed == false {
            DispatchQueue.main.async {
                self.getCardData()
            }
        }
    }
    
    // MARK: - Map Button
    @IBAction func mapButtonPressed(_ sender: UIButton) {
        mapPressed = true
        callButton.isUserInteractionEnabled = false
        mailButton.isUserInteractionEnabled = false
        mapButton.isUserInteractionEnabled = false
        websiteButton.isUserInteractionEnabled = false
        socialButton.isUserInteractionEnabled = false
        
        if callPressed == false && emailPressed == false && mapPressed == true && websitePressed == false && socialPressed == false {
            DispatchQueue.main.async {
                self.getCardData()
            }
        }
    }
    
    // MARK: - Website Button
    @IBAction func websiteButtonPressed(_ sender: UIButton) {
        websitePressed = true
        callButton.isUserInteractionEnabled = false
        mailButton.isUserInteractionEnabled = false
        mapButton.isUserInteractionEnabled = false
        websiteButton.isUserInteractionEnabled = false
        socialButton.isUserInteractionEnabled = false
        
        if callPressed == false && emailPressed == false && mapPressed == false && websitePressed == true && socialPressed == false {
            DispatchQueue.main.async {
                self.getCardData()
            }
        }
    }
    
    // MARK: - Social Button Pressed
    @IBAction func socialButtonPressed(_ sender: UIButton) {
        socialPressed = true
        callButton.isUserInteractionEnabled = false
        mailButton.isUserInteractionEnabled = false
        mapButton.isUserInteractionEnabled = false
        websiteButton.isUserInteractionEnabled = false
        socialButton.isUserInteractionEnabled = false
        
        if callPressed == false && emailPressed == false && mapPressed == false && websitePressed == false && socialPressed == true {
            DispatchQueue.main.async {
                self.getCardData()
            }
        }
    }
    
    // MARK: - Share Button Pressed
    @IBAction func shareButtonPressed(_ sender: UIButton) {
       
        // Action Sheet for Share Button
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Copy Card ID Action
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
    
    // MARK: - Save Button Pressed
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        // If user is NOT owner of the Card, user can Save or Remove from Wallet.
        if user! != userID && saveButton.titleLabel?.text == "Save" {
            saveVBC()
        } else  if user! != userID && saveButton.titleLabel?.text == "Remove" {
            DispatchQueue.main.async {
                self.removeVBC()
            }
        } else if user! == userID && saveButton.titleLabel?.text == "Edit" {
            // If User IS owner of the Card, user can Edit Card.
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
    
    // MARK: - Pop Up with TableView Back Button Pressed
    @objc func popUpBackButtonPressed() {
        
        popUpTableView.animateOut(forView: popUpTableView.popUpView, mainView: popUpTableView)
        popUpTableView.animateOut(forView: popUpTableView.blurEffectView, mainView: popUpTableView)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        callPressed = false
        emailPressed = false
        mapPressed = false
        websitePressed = false
        socialPressed = false
        
        callButton.isUserInteractionEnabled = true
        mailButton.isUserInteractionEnabled = true
        mapButton.isUserInteractionEnabled = true
        websiteButton.isUserInteractionEnabled = true
        socialButton.isUserInteractionEnabled = true
    }
    
}

// MARK: - Delete Card Data
extension CardVC {
    
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
extension CardVC {
    
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
extension CardVC {
    // MARK: - Get locations list
    func getLocationList() {
        
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
                    self.selectLocation.text?.removeAll()
                    
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
                        
                        // Phone Check
                        if data![Constants.Firestore.Key.phone1] != nil {
                            if (data![Constants.Firestore.Key.phone1] as? String) != "" {
                                DispatchQueue.main.async {
                                    self.callButton.isHidden = false
                                }
                            }
                        }
                        if data![Constants.Firestore.Key.phone2] != nil {
                            if (data![Constants.Firestore.Key.phone2] as? String) != "" {
                                DispatchQueue.main.async {
                                    self.callButton.isHidden = false
                                }
                            }
                        }
                        if data![Constants.Firestore.Key.phone3] != nil {
                            if (data![Constants.Firestore.Key.phone3] as? String) != "" {
                                DispatchQueue.main.async {
                                    self.callButton.isHidden = false
                                }
                            }
                        }
                        
                        // Email Check
                        if data![Constants.Firestore.Key.email1] != nil {
                            if (data![Constants.Firestore.Key.email1] as? String) != "" {
                                DispatchQueue.main.async {
                                    self.mailButton.isHidden = false
                                }
                            }
                        }
                        if data![Constants.Firestore.Key.email2] != nil {
                            if (data![Constants.Firestore.Key.email2] as? String) != "" {
                                DispatchQueue.main.async {
                                    self.mailButton.isHidden = false
                                }
                            }
                        }
                        
                        // Map Check
                        if data![Constants.Firestore.Key.gMaps] != nil {
                            if (data![Constants.Firestore.Key.gMaps] as? String) != "" {
                                DispatchQueue.main.async {
                                    self.mapButton.isHidden = false
                                }
                            }
                        }
                        // Website Check
                        if data![Constants.Firestore.Key.web1] != nil {
                            if (data![Constants.Firestore.Key.web1] as? String) != "" {
                                DispatchQueue.main.async {
                                    self.websiteButton.isHidden = false
                                }
                            }
                        }
                        if data![Constants.Firestore.Key.web2] != nil {
                            if (data![Constants.Firestore.Key.web2] as? String) != "" {
                                DispatchQueue.main.async {
                                    self.websiteButton.isHidden = false
                                }
                            }
                        }
                        // Social Check
                        if data![Constants.Firestore.Key.socialAdded] != nil {
                            if (data![Constants.Firestore.Key.socialAdded] as? Bool) != false {
                                DispatchQueue.main.async {
                                    self.socialButton.isHidden = false
                                }
                            }
                        }
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
                    // Present PopUp with Blur and PopUp Height is depending on how many items is it in TableView
                    DispatchQueue.main.async {
                        self.popUpWithTableView(rows: self.socialMediaList.count, type: "Social")
                    }
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
                            // Call Button Pressed, Get Data and Show PopUp With Phone Numbers
                            if self.callPressed == true {
                                
                                self.phoneNumbersList.removeAll()
                                
                                // Phone Contact Info
                                if let phoneCode1 = data![Constants.Firestore.Key.phone1code] as? String {
                                    if let phone1Number = data![Constants.Firestore.Key.phone1] as? String {
                                        
                                        if phone1Number != "" {
                                            let number = PhoneNumber(code: phoneCode1, number: phone1Number)
                                            self.phoneNumbersList.append(number)
                                        }
                                    }
                                }
                                
                                if let phoneCode2 = data![Constants.Firestore.Key.phone2code] as? String {
                                    if let phone2Number = data![Constants.Firestore.Key.phone2] as? String {
                                        
                                        if phone2Number != "" {
                                            let number = PhoneNumber(code: phoneCode2, number: phone2Number)
                                            self.phoneNumbersList.append(number)
                                        }
                                    }
                                }
                                
                                if let phoneCode3 = data![Constants.Firestore.Key.phone3code] as? String {
                                    if let phone3Number = data![Constants.Firestore.Key.phone3] as? String {
                                        
                                        if phone3Number != "" {
                                            let number = PhoneNumber(code: phoneCode3, number: phone3Number)
                                            self.phoneNumbersList.append(number)
                                        }
                                    }
                                }
                                // Present PopUp with Blur
                                DispatchQueue.main.async {
                                    self.popUpWithTableView(rows: self.phoneNumbersList.count, type: "Phone")
                                }
                            }
                            // Email Button Pressed, Get Data and Show PopUp With Emails
                            if self.emailPressed == true {
                                
                                self.emailAddressList.removeAll()
                                
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
                                // Present PopUp with Blur
                                DispatchQueue.main.async {
                                    self.popUpWithTableView(rows: self.emailAddressList.count, type: "Email")
                                }
                            }
                            // Map Button Pressed, Get Data and Open Google Maps or Safari
                            if self.mapPressed == true {
                                
                                self.mapLink.removeAll()
                                
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
                                self.mapPressed = false
                                self.callButton.isUserInteractionEnabled = true
                                self.mailButton.isUserInteractionEnabled = true
                                self.mapButton.isUserInteractionEnabled = true
                                self.websiteButton.isUserInteractionEnabled = true
                                self.socialButton.isUserInteractionEnabled = true
                            }
                            // Website Button Pressed, Get Data and Show PopUp with Website Links
                            if self.websitePressed == true {
                                
                                self.websiteList.removeAll()
                                
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
                                // Present PopUp with Blur
                                DispatchQueue.main.async {
                                    self.popUpWithTableView(rows: self.websiteList.count, type: "Website")
                                }
                            }
                            
                        }
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
                            if let sector = data![Constants.Firestore.Key.sector] as? String {
                                if let productType = data![Constants.Firestore.Key.type] as? String {
                                    if let country = data![Constants.Firestore.Key.country] as? String {
                                        if let checkSinglePlace = data![Constants.Firestore.Key.singlePlace] as? Bool {
                                            
                                            self.singlePlace = checkSinglePlace
                                            
                                            if self.singlePlace == true {
                                                self.selectLocation.isEnabled = false
                                            }
                                            
                                            // Basic Card Info
                                            self.companyNameLabel.text = companyName
                                            self.sectorLabel.text = sector
                                            self.productTypeLabel.text = productType
                                            self.countryName = country
                                            self.countryFlag.image = UIImage(named: country)
                                            
                                            if self.companyCard == false {
                                                if let personalName = data![Constants.Firestore.Key.personalName] as? String {
                                                    self.personalNameLabel.text = personalName
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

// MARK: - Picker View Delegate and DataSource
extension CardVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        
        self.checkCardData()
    }
}

extension CardVC: NewEditedLocation {
    
    func getNewEditedLocation(newLocation: String) {
        self.locationForEdit = newLocation
    }
}

// MARK: - Pop Up Extension
extension CardVC: UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    // MARK: - PopUp With TableView
    func popUpWithTableView(rows: Int, type: String) {
        
        self.popUpTableView = PopUpTableView(frame: self.view.frame)
        self.popUpTableView.popUpWithTableView(vc: self,
                                               rows: rows,
                                               type: type,
                                               nibName: Constants.Nib.popUpCell,
                                               cellIdentifier: Constants.Cell.popUpCell)
        self.popUpTableView.backButton.addTarget(self,
                                                 action: #selector(self.popUpBackButtonPressed),
                                                 for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.popUpTableView)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func dismissPopUpWithTableView() {
        popUpTableView.animateOut(forView: popUpTableView.popUpView, mainView: popUpTableView)
        popUpTableView.animateOut(forView: popUpTableView.blurEffectView, mainView: popUpTableView)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if callPressed == true {
            return phoneNumbersList.count
        } else if emailPressed == true {
            return emailAddressList.count
        } else if websitePressed == true {
            return websiteList.count
        } else {
            return socialMediaList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.popUpCell, for: indexPath) as! CardPopUpCell
        
        if callPressed == true {
            cell.cellTextLabel.text = "\(phoneNumbersList[indexPath.row].code) \(phoneNumbersList[indexPath.row].number)"
        } else if emailPressed == true {
            cell.cellTextLabel.text = emailAddressList[indexPath.row]
        } else if websitePressed == true {
            cell.cellTextLabel.text = websiteList[indexPath.row]
        } else {
            cell.cellTextLabel.text = socialMediaList[indexPath.row].name
            cell.copyButton.setImage(UIImage(named: socialMediaList[indexPath.row].name), for: .normal)
            cell.copyButton.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // MARK: - Selected Phone Number
        if callPressed == true {
            if let phoneNumber = URL(string:"tel://\(phoneNumbersList[indexPath.row].code)\(phoneNumbersList[indexPath.row].number)"), UIApplication.shared.canOpenURL(phoneNumber) {
                UIApplication.shared.open(phoneNumber, options: [:], completionHandler: nil)
            }
            
            // MARK: - Selected Email Address
        } else if emailPressed == true {
            
            dismissPopUpWithTableView()
            
            var companyOrPersonalName = ""
            
            if companyCard == true {
                companyOrPersonalName = companyNameLabel.text!
            } else {
                companyOrPersonalName = personalNameLabel.text!
            }
            
            let recipientEmail = emailAddressList[indexPath.row]
            let subject = "VBC - ".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let body = "Dear \(companyOrPersonalName), \n \n".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            // Action Sheet for Mail App Select
            let actionSheetController: UIAlertController = UIAlertController(title: "Select Mail App", message: nil, preferredStyle: .actionSheet)
            
            // MARK: - Outlook App
            let outlook: UIAlertAction = UIAlertAction(title: "Outlook", style: .default) { action -> Void in
                
                guard let outlookUrl = URL(string: "ms-outlook://compose?to=\(recipientEmail)&subject=\(subject)") else {
                    PopUp().popUpWithOk(newTitle: "Email Address Error",
                                        newMessage: "Email Address does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(outlookUrl) {
                    UIApplication.shared.open(outlookUrl)
                } else {
                    //Go To App Store or Dismiss
                    let alert = UIAlertController(title: "Outlook App Error", message: "Outlook app NOT installed or can NOT be opened. \nYou can download it on App Store.", preferredStyle: .alert)
                    let actionOK = UIAlertAction(title: "OK", style: .cancel) { action in
                        alert.dismiss(animated: true, completion: nil)
                    }
                    
                    let actionAppStore = UIAlertAction(title: "Go to App Store", style: .default) { action in
                        
                        guard let outlookAppStore = URL(string: "itms-apps://apple.com/app/id951937596") else {
                            PopUp().popUpWithOk(newTitle: "Error",
                                                newMessage: "Link Error. Please check your internet connection and try again.",
                                                vc: self)
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(outlookAppStore) {
                            UIApplication.shared.open(outlookAppStore)
                        } else {
                            PopUp().popUpWithOk(newTitle: "Error",
                                                newMessage: "Please check your internet connection and try again.",
                                                vc: self)
                        }
                        
                    }
                    
                    alert.addAction(actionOK)
                    alert.addAction(actionAppStore)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            // MARK: - Yahoo App
            let yahoo: UIAlertAction = UIAlertAction(title: "Yahoo!", style: .default) { action -> Void in
                
                guard let yahooUrl = URL(string: "ymail://mail/compose?to=\(recipientEmail)&subject=\(subject)&body=\(body)") else {
                    PopUp().popUpWithOk(newTitle: "Email Address Error",
                                        newMessage: "Email Address does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(yahooUrl) {
                    UIApplication.shared.open(yahooUrl)
                } else {
                    //Go To App Store or Dismiss
                    let alert = UIAlertController(title: "Yahoo App Error", message: "Yahoo app NOT installed or can NOT be opened. \nYou can download it on App Store.", preferredStyle: .alert)
                    let actionOK = UIAlertAction(title: "OK", style: .cancel) { action in
                        alert.dismiss(animated: true, completion: nil)
                    }
                    
                    let actionAppStore = UIAlertAction(title: "Go to App Store", style: .default) { action in
                        
                        guard let yahooAppStore = URL(string: "itms-apps://apple.com/app/id577586159") else {
                            PopUp().popUpWithOk(newTitle: "Error",
                                                newMessage: "Link Error. Please check your internet connection and try again.",
                                                vc: self)
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(yahooAppStore) {
                            UIApplication.shared.open(yahooAppStore)
                        } else {
                            PopUp().popUpWithOk(newTitle: "Error",
                                                newMessage: "Please check your internet connection and try again.",
                                                vc: self)
                        }
                        
                    }
                    
                    alert.addAction(actionOK)
                    alert.addAction(actionAppStore)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            // MARK: - Gmail App
            let Gmail: UIAlertAction = UIAlertAction(title: "Gmail", style: .default) { action -> Void in
                
                guard let gmailUrl = URL(string: "googlegmail://co?to=\(recipientEmail)&subject=\(subject)&body=\(body)") else {
                    PopUp().popUpWithOk(newTitle: "Email Address Error",
                                        newMessage: "Email Address does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(gmailUrl) {
                    UIApplication.shared.open(gmailUrl, options: [:], completionHandler: nil)
                } else {
                    //Go To App Store or Dismiss
                    let alert = UIAlertController(title: "Gmail App Error", message: "Gmail app NOT installed or can NOT be opened. \nYou can download it on App Store.", preferredStyle: .alert)
                    let actionOK = UIAlertAction(title: "OK", style: .cancel) { action in
                        alert.dismiss(animated: true, completion: nil)
                    }
                    
                    let actionAppStore = UIAlertAction(title: "Go to App Store", style: .default) { action in
                        
                        guard let gmailAppStore = URL(string: "itms-apps://apple.com/app/id422689480") else {
                            PopUp().popUpWithOk(newTitle: "Error",
                                                newMessage: "Link Error. Please check your internet connection and try again.",
                                                vc: self)
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(gmailAppStore) {
                            UIApplication.shared.open(gmailAppStore)
                        } else {
                            PopUp().popUpWithOk(newTitle: "Error",
                                                newMessage: "Please check your internet connection and try again.",
                                                vc: self)
                        }
                        
                    }
                    
                    alert.addAction(actionOK)
                    alert.addAction(actionAppStore)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            // MARK: - Spark App
            let spark: UIAlertAction = UIAlertAction(title: "Spark", style: .default) { action -> Void in
                
                guard let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(recipientEmail)&subject=\(subject)&body=\(body)") else {
                    PopUp().popUpWithOk(newTitle: "Email Address Error",
                                        newMessage: "Email Address does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(sparkUrl) {
                    UIApplication.shared.open(sparkUrl)
                } else {
                    //Go To App Store or Dismiss
                    let alert = UIAlertController(title: "Spark App Error", message: "Spark app NOT installed or can NOT be opened. \nYou can download it on App Store.", preferredStyle: .alert)
                    let actionOK = UIAlertAction(title: "OK", style: .cancel) { action in
                        alert.dismiss(animated: true, completion: nil)
                    }
                    
                    let actionAppStore = UIAlertAction(title: "Go to App Store", style: .default) { action in
                        
                        guard let sparkAppStore = URL(string: "itms-apps://apple.com/app/id997102246") else {
                            PopUp().popUpWithOk(newTitle: "Error",
                                                newMessage: "Link Error. Please check your internet connection and try again.",
                                                vc: self)
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(sparkAppStore) {
                            UIApplication.shared.open(sparkAppStore)
                        } else {
                            PopUp().popUpWithOk(newTitle: "Error",
                                                newMessage: "Please check your internet connection and try again.",
                                                vc: self)
                        }
                        
                    }
                    
                    alert.addAction(actionOK)
                    alert.addAction(actionAppStore)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            // MARK: - Mail App
            let mailApp: UIAlertAction = UIAlertAction(title: "Mail", style: .default) { action -> Void in
                
                let mailRecipientEmail = self.emailAddressList[indexPath.row]
                let mailSubject = "VBC - "
                let mailBody = "Dear \(companyOrPersonalName), \n \n"
                
                // Open Email Composer with template
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients([mailRecipientEmail])
                    mail.setSubject(mailSubject)
                    mail.setMessageBody(mailBody, isHTML: false)
                    
                    self.present(mail, animated: true)
                } else {
                    
                    //Go To App Store or Dismiss
                    let alert = UIAlertController(title: "Mail App Error", message: "Mail app NOT installed or can NOT be opened. \nYou can download it on App Store.", preferredStyle: .alert)
                    let actionOK = UIAlertAction(title: "OK", style: .cancel) { action in
                        alert.dismiss(animated: true, completion: nil)
                    }
                    
                    let actionAppStore = UIAlertAction(title: "Go to App Store", style: .default) { action in
                        
                        guard let mailAppStore = URL(string: "itms-apps://apple.com/app/id1108187098") else {
                            PopUp().popUpWithOk(newTitle: "Error",
                                                newMessage: "Link Error. Please check your internet connection and try again.",
                                                vc: self)
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(mailAppStore) {
                            UIApplication.shared.open(mailAppStore)
                        } else {
                            PopUp().popUpWithOk(newTitle: "Error",
                                                newMessage: "Please check your internet connection and try again.",
                                                vc: self)
                        }
                        
                    }
                    
                    alert.addAction(actionOK)
                    alert.addAction(actionAppStore)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
            
            // Cancel Action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
            
            actionSheetController.addAction(outlook)
            actionSheetController.addAction(yahoo)
            actionSheetController.addAction(spark)
            actionSheetController.addAction(Gmail)
            actionSheetController.addAction(mailApp)
            actionSheetController.addAction(cancelAction)
            
            present(actionSheetController, animated: true, completion: nil)
            self.emailPressed = false
            self.callButton.isUserInteractionEnabled = true
            self.mailButton.isUserInteractionEnabled = true
            self.mapButton.isUserInteractionEnabled = true
            self.websiteButton.isUserInteractionEnabled = true
            self.socialButton.isUserInteractionEnabled = true
            
            // MARK: - Selected Website Link
        } else if websitePressed == true {
            // Open Safari and Go to Website.
            guard let url = URL(string: "https://\(websiteList[indexPath.row])") else { return }
            let svc = SFSafariViewController(url: url)
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            present(svc, animated: true, completion: nil)
            
            // MARK: - Selected Social Media
        } else if socialPressed == true {
            
            let link = socialMediaList[indexPath.row].link.replacingOccurrences(of: " ", with: "")
            // Instagram Selected
            if socialMediaList[indexPath.row].name == "Instagram" {
                
                let appInsta = URL(string: "instagram://user?username=\(link)")!
                guard let webInsta = URL(string: "https://www.instagram.com/\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "Instagram Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(appInsta) {
                    UIApplication.shared.open(appInsta)
                } else {
                    UIApplication.shared.open(webInsta)
                }
                // TikTok Selected
            } else if socialMediaList[indexPath.row].name == "TikTok" {
                
                guard let tikTok = URL(string: "https://www.tiktok.com/@\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "TikTok Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(tikTok) {
                    UIApplication.shared.open(tikTok)
                } else {
                    print("TikTok not installed")
                }
                // Viber Selected
            } else if socialMediaList[indexPath.row].name == "Viber" {
                
                guard let viber = URL(string: "viber://contact?number=\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "Viber Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(viber) {
                    UIApplication.shared.open(viber)
                } else {
                    print("Viber not working")
                }
                // WhatsApp Selected
            } else if socialMediaList[indexPath.row].name == "WhatsApp" {
                
                guard let wa = URL(string: "whatsapp://send?phone=\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "WhatsApp Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(wa) {
                    UIApplication.shared.open(wa)
                } else {
                    print("WhatsApp not working")
                }
                // Facebook Selected
            } else if socialMediaList[indexPath.row].name == "Facebook" {
                
                let appFb = URL(string: "fb://profile/\(link)")!
                guard let webFb = URL(string: "https://www.facebook.com/\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "Facebook Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(appFb) {
                    UIApplication.shared.open(appFb)
                } else {
                    UIApplication.shared.open(webFb)
                }
                // Twitter Selected
            } else if socialMediaList[indexPath.row].name == "Twitter" {
                
                let appTwt = URL(string: "twitter://user?screen_name=\(link)")!
                let webTwt = URL(string: "https://twitter.com/\(link)")!
                
                if UIApplication.shared.canOpenURL(appTwt) {
                    UIApplication.shared.open(appTwt)
                } else {
                    UIApplication.shared.open(webTwt)
                }
                // Linked In Selected
            } else if socialMediaList[indexPath.row].name == "LinkedIn" {
                
                guard let li = URL(string: "https://www.linkedin.com/in/\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "LinkedIn Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(li) {
                    UIApplication.shared.open(li)
                } else {
                    PopUp().popUpWithOk(newTitle: "Can NOT open Link",
                                        newMessage: "LinkedIn Link does NOT work or that user does NOT exist.",
                                        vc: self)
                }
                // Pinterest Selected
            } else if socialMediaList[indexPath.row].name == "Pinterest" {
                
                guard let pint = URL(string: "https://www.pinterest.com/\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "Pinterest Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(pint) {
                    UIApplication.shared.open(pint)
                } else {
                    print("Pinterest not installed")
                }
                // GitHub Selected
            } else if socialMediaList[indexPath.row].name == "GitHub" {
                
                guard let gh = URL(string: "https://www.github.com/\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "GitHub Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(gh) {
                    UIApplication.shared.open(gh)
                } else {
                    print("GitHub not installed")
                }
                // YouTube Selected
            } else if socialMediaList[indexPath.row].name == "YouTube" {
                
                guard let yt = URL(string: "https://www.youtube.com/channel/\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "YouTube Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(yt) {
                    UIApplication.shared.open(yt)
                } else {
                    print("YouTube not installed")
                }
                // Telegram Selected
            } else if socialMediaList[indexPath.row].name == "Telegram" {
                
                guard let appTg = URL(string: "tg://resolve?domain=\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "Telegram Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                guard let webTg = URL(string: "https://t.me/\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "Telegram Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                if UIApplication.shared.canOpenURL(appTg) {
                    UIApplication.shared.open(appTg)
                }
                else {
                    UIApplication.shared.open(webTg)
                }
                
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let e = error {
            print("Error Finish with. \(e)")
            return
        }
        controller.dismiss(animated: true)
    }
    
}
