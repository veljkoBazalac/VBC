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
    //TODO: NAMESTI DA SE MENJA ZASTAVICA
    // Buttons Outlets
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var socialButton: UIButton!
    // Save Button Outlet
    @IBOutlet weak var saveButton: UIButton!
    
    // Pop Up and Blur Effect
    @IBOutlet var blurEffect: UIVisualEffectView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var popUpTitle: UILabel!
    @IBOutlet weak var popUpTableView: UITableView!
    @IBOutlet weak var popUpBackButton: UIButton!
    
    
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
        
        // PopUp with Blur
        blurEffect.bounds = self.view.bounds
        popUpView.layer.cornerRadius = self.view.bounds.height / 50
        popUpTableView.rowHeight = 50
        popUpTableView.separatorColor = UIColor(named: "Color Dark Blue")
        popUpTableView.delegate = self
        popUpTableView.dataSource = self
        popUpTableView.register(UINib(nibName: Constants.Nib.popUpCell, bundle: nil), forCellReuseIdentifier: Constants.Cell.popUpCell)
        
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
        getCardData()
    }
    
    // MARK: - Email Button
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        emailPressed = true
        getCardData()
    }

    // MARK: - Map Button
    @IBAction func mapButtonPressed(_ sender: UIButton) {
        mapPressed = true
        getCardData()
    }
    
    // MARK: - Website Button
    @IBAction func websiteButtonPressed(_ sender: UIButton) {
        websitePressed = true
        getCardData()
    }
    
    // MARK: - Social Button Pressed
    @IBAction func socialButtonPressed(_ sender: UIButton) {
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

    @IBAction func popUpBackButtonPressed(_ sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        animateOut(view: popUpView)
        animateOut(view: blurEffect)
        callPressed = false
        emailPressed = false
        mapPressed = false
        websitePressed = false
        socialPressed = false
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
                    // Present PopUp with Blur and PopUp Height is depending on how many items is it in TableView
                    if self.socialMediaList.count == 1 {
                        self.popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: 170)
                    } else if self.socialMediaList.count == 2 {
                        self.popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: 220)
                    } else if self.socialMediaList.count == 3 {
                        self.popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: 270)
                    } else if self.socialMediaList.count == 4 {
                        self.popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: 320)
                    } else if self.socialMediaList.count == 5 {
                        self.popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: 370)
                    }
                    self.popUpTitle.text = "Social Media"
                    self.animateIn(view: self.blurEffect)
                    self.animateIn(view: self.popUpView)
                    self.navigationController?.setNavigationBarHidden(true, animated: true)
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
                                // Present PopUp with Blur
                                if self.phoneNumbersList.count == 1 {
                                    self.popUpTitle.text = "Phone Number"
                                    self.popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: 170)
                                } else if self.phoneNumbersList.count == 2 {
                                    self.popUpTitle.text = "Phone Numbers"
                                    self.popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: 220)
                                } else if self.phoneNumbersList.count == 3 {
                                    self.popUpTitle.text = "Phone Numbers"
                                    self.popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: 270)
                                }
                                self.animateIn(view: self.blurEffect)
                                self.animateIn(view: self.popUpView)
                                self.navigationController?.setNavigationBarHidden(true, animated: true)
                            }
                            // Email Button Pressed, Get Data and Show PopUp With Emails
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
                                // Present PopUp with Blur
                                if self.emailAddressList.count == 1 {
                                    self.popUpTitle.text = "Email Address"
                                    self.popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: 170)
                                } else {
                                    self.popUpTitle.text = "Email Addresses"
                                    self.popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: 220)
                                }
                                self.animateIn(view: self.blurEffect)
                                self.animateIn(view: self.popUpView)
                                self.navigationController?.setNavigationBarHidden(true, animated: true)
                            }
                            // Map Button Pressed, Get Data and Open Google Maps or Safari
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
                                self.mapPressed = false
                            }
                            // Website Button Pressed, Get Data and Show PopUp with Website Links
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
                                // Present PopUp with Blur
                                if self.websiteList.count == 1 {
                                    self.popUpTitle.text = "Website Link"
                                    self.popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: 170)
                                } else {
                                    self.popUpTitle.text = "Website Links"
                                    self.popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.7, height: 220)
                                }
                                self.animateIn(view: self.blurEffect)
                                self.animateIn(view: self.popUpView)
                                self.navigationController?.setNavigationBarHidden(true, animated: true)
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
        self.checkSocialData()
    }
}

extension CardVC: NewEditedLocation {
    
    func getNewEditedLocation(newLocation: String) {
        self.locationForEdit = newLocation
    }
}

// MARK: - Pop Up Extension
extension CardVC: UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    // Animate In function for PopUp
    func animateIn(view: UIView) {
        let backgroundView = self.view!
        
        backgroundView.addSubview(view)
        
        view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        view.alpha = 0
        view.center = backgroundView.center
        
        UIView.animate(withDuration: 0.3) {
            view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            view.alpha = 1
            self.popUpTableView.reloadData()
        }
    }
    
    // Animate Out function for PopUp
    func animateOut(view: UIView) {
        UIView.animate(withDuration: 0.3) {
            view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            view.alpha = 0
        } completion: { _ in
            view.removeFromSuperview()
        }

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
            cell.cellTextLabel.text = "\(phoneNumbersList[indexPath.row].code)\(phoneNumbersList[indexPath.row].number)"
            cell.copyButton.isHidden = false
        } else if emailPressed == true {
            cell.cellTextLabel.text = emailAddressList[indexPath.row]
            cell.copyButton.isHidden = false
        } else if websitePressed == true {
            cell.cellTextLabel.text = websiteList[indexPath.row]
            cell.copyButton.isHidden = false
        } else {
            cell.cellTextLabel.text = socialMediaList[indexPath.row].name
            cell.copyButton.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if callPressed == true {
            if let phoneNumber = URL(string:"tel://\(phoneNumbersList[indexPath.row].code)\(phoneNumbersList[indexPath.row].number)"), UIApplication.shared.canOpenURL(phoneNumber) {
                        UIApplication.shared.open(phoneNumber, options: [:], completionHandler: nil)
                    }
        } else if emailPressed == true {
            var companyOrPersonalName = ""
            
            if companyCard == true {
                companyOrPersonalName = companyNameLabel.text!
            } else {
                companyOrPersonalName = personalNameLabel.text!
            }
            // Open Email Composer with template
            EmailComposer().showEmailComposer(recipient: emailAddressList[indexPath.row],
                                              subject: "VBC - ",
                                              body: "Dear \(companyOrPersonalName), \n \n",
                                              delegate: self,
                                              vc: self)

        } else if websitePressed == true {
            // Open Safari and Go to Website.
            guard let url = URL(string: "https://\(websiteList[indexPath.row])") else { return }
            let svc = SFSafariViewController(url: url)
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            present(svc, animated: true, completion: nil)
        
        } else {
            
            let link = socialMediaList[indexPath.row].link.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if socialMediaList[indexPath.row].name == "Instagram" {
                
                    let appInsta = URL(string: "instagram://user?username=\(link)")!
                guard let webInsta = URL(string: "https://www.instagram.com/\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "Instagram Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }

                    if UIApplication.shared.canOpenURL(appInsta) {
                            UIApplication.shared.open(appInsta, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.open(webInsta, options: [:], completionHandler: nil)
                    }
                
            } else if socialMediaList[indexPath.row].name == "TikTok" {
                
                guard let tikTok = URL(string: "https://www.tiktok.com/@\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "TikTok Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(tikTok) {
                    UIApplication.shared.open(tikTok, options: [:], completionHandler: nil)
                } else {
                    print("TikTok not installed")
                }
                
            } else if socialMediaList[indexPath.row].name == "Viber" {
                
                guard let viber = URL(string: "viber://contact?number=\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "Viber Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(viber) {
                    UIApplication.shared.open(viber, options: [:], completionHandler: nil)
                } else {
                    print("Viber not working")
                }
                
            } else if socialMediaList[indexPath.row].name == "WhatsApp" {
                
                guard let wa = URL(string: "whatsapp://send?phone=\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "WhatsApp Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(wa) {
                    UIApplication.shared.open(wa, options: [:], completionHandler: nil)
                } else {
                    print("WhatsApp not working")
                }
                
            } else if socialMediaList[indexPath.row].name == "Facebook" {
                
                let appFb = URL(string: "fb://profile/\(link)")!
                guard let webFb = URL(string: "https://www.facebook.com/\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "Facebook Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(appFb) {
                    UIApplication.shared.open(appFb, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.open(webFb, options: [:], completionHandler: nil)
                }
                
            } else if socialMediaList[indexPath.row].name == "Twitter" {
                
                let appTwt = URL(string: "twitter://user?screen_name=\(link)")!
                let webTwt = URL(string: "https://twitter.com/\(link)")!
                
                if UIApplication.shared.canOpenURL(appTwt) {
                    UIApplication.shared.open(appTwt, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.open(webTwt, options: [:], completionHandler: nil)
                }
                
            } else if socialMediaList[indexPath.row].name == "LinkedIn" {
                
                guard let li = URL(string: "https://www.linkedin.com/in/\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "LinkedIn Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(li) {
                    UIApplication.shared.open(li, options: [:], completionHandler: nil)
                } else {
                    PopUp().popUpWithOk(newTitle: "Can NOT open Link",
                                        newMessage: "LinkedIn Link does NOT work or that user does NOT exist.",
                                        vc: self)
                }
            } else if socialMediaList[indexPath.row].name == "Pinterest" {
                
                guard let pint = URL(string: "https://www.pinterest.com/\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "Pinterest Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(pint) {
                    UIApplication.shared.open(pint, options: [:], completionHandler: nil)
                } else {
                    print("Pinterest not installed")
                }
                
            } else if socialMediaList[indexPath.row].name == "GitHub" {
                
                guard let gh = URL(string: "https://www.github.com/\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "GitHub Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(gh) {
                    UIApplication.shared.open(gh, options: [:], completionHandler: nil)
                } else {
                    print("GitHub not installed")
                }
                
            } else if socialMediaList[indexPath.row].name == "YouTube" {
                
                guard let yt = URL(string: "https://www.youtube.com/channel/\(link)") else {
                    PopUp().popUpWithOk(newTitle: "Link does NOT work",
                                        newMessage: "YouTube Link does NOT work or that user does NOT exist.",
                                        vc: self)
                    return
                }
                
                if UIApplication.shared.canOpenURL(yt) {
                    UIApplication.shared.open(yt, options: [:], completionHandler: nil)
                } else {
                    print("YouTube not installed")
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
