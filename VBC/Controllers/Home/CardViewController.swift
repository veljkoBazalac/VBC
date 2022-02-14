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
    var locationsList : [MultiplePlaces] = []
    // User ID
    var userID : String = ""
    // Card Saved
    var cardSaved : Bool = false
    // Edit Card
    var cardEdited : Bool = false
    var cityNameForEdit : String = ""
    var streetNameForEdit : String = ""
    
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
        } else if user! == userID {
            DispatchQueue.main.async {
                self.saveButton.setTitle("Edit", for: .normal)
            }
        }
    }
    
    // MARK: - Getting Single Place or Multiple Places Locations
    func getLocationsList() {
        
        if singlePlace == true {
            getSinglePlaceList()
        } else if singlePlace == false {
            getMultiplePlacesList()
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
            
            callPressed = false
            emailPressed = false
            mapPressed = false
            websitePressed = false
            socialPressed = false
        }
        
        if segue.identifier == Constants.Segue.editStep1 {
            
            let destinationVC = segue.destination as! CAdd1ViewController
            
            destinationVC.editCard = true
            destinationVC.editCardID = cardID
            destinationVC.editUserID = userID
            destinationVC.companyCard = companyCard
            
        }
        
        if segue.identifier == Constants.Segue.editStep2 {
            
            let destinationVC = segue.destination as! CAdd2ViewController
            
            cardEdited = true
            
            destinationVC.editCard2 = true
            destinationVC.editCardID2 = cardID
            destinationVC.editUserID2 = userID
            destinationVC.editCardSaved2 = cardSaved
            destinationVC.editCardCountry2 = countryLabel.text!
            destinationVC.editSinglePlace2 = singlePlace
            
            if singlePlace == true {
                destinationVC.editCardCity2 = cityNameForEdit
                destinationVC.editCardStreet2 = streetNameForEdit
                destinationVC.editCardMap2 = mapLink
            }
            
            destinationVC.logoImage2 = logoImage.image!
            destinationVC.companyName2 = companyNameLabel.text!
            destinationVC.sector2 = sectorLabel.text!
            destinationVC.productType2 = productTypeLabel.text!
            
            if companyCard == false {
                destinationVC.personalName2 = personalNameLabel.text!
            }
        }
        
        if segue.identifier == Constants.Segue.editStep3 {
            
        }
        
        if segue.identifier == Constants.Segue.cardToAbout {
            
            let destinationVC = segue.destination as! AboutViewController
            
            if companyCard == false {
                destinationVC.personalName = personalNameLabel.text!
                destinationVC.aboutTitle = "About Me"
            }
            
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
        performSegue(withIdentifier: Constants.Segue.cardToAbout, sender: self)
    }
    
    // MARK: - CONTACT BUTTONS
    
// MARK: - Call Button
    
    @IBAction func callButtonPressed(_ sender: UITapGestureRecognizer) {
        callPressed = true
        
        if singlePlace == true {
            getCardSP()
        } else {
            getCardMP()
        }
    }
    
// MARK: - Email Button
    
    @IBAction func emailButtonPressed(_ sender: UITapGestureRecognizer) {
        emailPressed = true
        
        if singlePlace == true {
            getCardSP()
        } else {
            getCardMP()
        }
        
    }

// MARK: - Map Button
    
    @IBAction func mapButtonPressed(_ sender: UITapGestureRecognizer) {
        mapPressed = true
        
        if singlePlace == true {
            getCardSP()
        } else {
            getCardMP()
        }
        
        if let gMap = URL(string:"\(self.mapLink)"), UIApplication.shared.canOpenURL(gMap) {
            UIApplication.shared.open(gMap, options: [:], completionHandler: nil)
        }
        
    }
    
// MARK: - Website Button
    
    @IBAction func websiteButtonPressed(_ sender: UITapGestureRecognizer) {
        websitePressed = true
        
        if singlePlace == true {
            getCardSP()
        } else {
            getCardMP()
        }
    }
    
    // MARK: - Social Button Pressed
    
    @IBAction func socialButtonPressed(_ sender: UITapGestureRecognizer) {
        socialPressed = true
        
        if singlePlace == true {
            getCardSP()
        } else {
            getCardMP()
        }
    }
    
    // MARK: - SHARE AND SAVE BUTTONS
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        
        // Action Sheet da kopira Card ID
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Basic Info Action
        let copyCardIDAction: UIAlertAction = UIAlertAction(title: "Copy Card ID", style: .default) { action -> Void in

            UIPasteboard.general.string = self.cardID
            
            self.popUpWithOk(newTitle: "Card ID Copied", newMessage: "")
            
        }
        
        // Cancel Action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        
        actionSheetController.addAction(copyCardIDAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    // Save Button Pressed
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        if user! != userID && saveButton.titleLabel?.text == "Save" {
            saveVBC()
        } else  if user! != userID && saveButton.titleLabel?.text == "Remove" {
            deleteVBC()
        }
        else {
            // TODO: ZAVRSI EDITOVANJE 
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
            // Cancel Action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

            actionSheetController.addAction(basicInfoAction)
            actionSheetController.addAction(locInfoAction)
            actionSheetController.addAction(contactInfoAction)
            actionSheetController.addAction(cancelAction)

            present(actionSheetController, animated: true, completion: nil)
            
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

extension CardViewController {
    
    func getSaveStatus() {
        
        // Getting Save Status Info
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
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
    }
    
    // MARK: - Save Card to Saved Tab
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
                        .updateData(["\(Constants.Firestore.Key.cardSaved)": true])
                    
                    self.cardSaved = true
                    
                    DispatchQueue.main.async {
                        self.saveButton.setTitle("Remove", for: .normal)
                    }
                    
                    self.popUpWithOk(newTitle: "Saved Successfully", newMessage: "This VBC will be shown in your Saved Tab.")
                }
            }
        
    }
    
    // MARK: - Remove Card from Saved
    
    func deleteVBC() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.savedVBC)
            .document(cardID)
            .updateData(["CardID": FieldValue.delete(), "User ID": FieldValue.delete()]) { error in
                
                if let e = error {
                    print("Error Deleting VBC. \(e)")
                } else {
                    
                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.data)
                        .collection(Constants.Firestore.CollectionName.users)
                        .document(self.userID)
                        .collection(Constants.Firestore.CollectionName.cardID)
                        .document(self.cardID)
                        .updateData(["\(Constants.Firestore.Key.cardSaved)": false])
                    
                    self.cardSaved = false
                    
                    DispatchQueue.main.async {
                        self.saveButton.setTitle("Save", for: .normal)
                    }
                    
                    self.popUpWithOk(newTitle: "Deleted Successfully", newMessage: "This VBC has been removed from your Saved Tab.")
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
                                            
                                            if checkSinglePlace == false {
                                                self.selectLocation.isEnabled = true
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
                                            self.getLocationsList()
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

// MARK: - SINGLE PLACE CARDS

extension CardViewController {
    
    // MARK: - Get Single Place Location
    func getSinglePlaceList() {
        
        // Getting Single Place location
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .getDocument { document, error in
                
                if let e = error {
                    print("Error getting Singe Place location. \(e)")
                    
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let documentData = document!.data()
                        
                        if let cityName = documentData![Constants.Firestore.Key.city] as? String {
                            if let streetName = documentData![Constants.Firestore.Key.street] as? String {
                                
                                if cityName.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                                    self.selectLocation.text = "City not specified"
                                } else if cityName.trimmingCharacters(in: .whitespacesAndNewlines) != "" && streetName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                                    self.selectLocation.text = "\(cityName) - \(streetName)"
                                } else if streetName.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                                    self.selectLocation.text = "\(cityName)"
                                }
                                self.selectLocation.isEnabled = false
                                self.cityNameForEdit = cityName
                                self.streetNameForEdit = streetName
                            }
                        }
                    }
                    self.checkCardDataSP()
                }
            }
    }
    
    // MARK: - Check Card Data for Single Place Location
    
    func checkCardDataSP() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error Checking Single Place Data. \(e)")
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
                        
                        // Social Media Check
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
    
    
    // MARK: - Get Card Data for Single Place
    
    func getCardSP() {
        
        // Get Social Media for Single Place
        if socialPressed == true {
            
            socialMediaList = []
            
            db.collection(Constants.Firestore.CollectionName.VBC)
                .document(Constants.Firestore.CollectionName.data)
                .collection(Constants.Firestore.CollectionName.users)
                .document(userID)
                .collection(Constants.Firestore.CollectionName.cardID)
                .document(cardID)
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
                .getDocument { document, error in
                    
                    if let e = error {
                        print ("Error getting Multiple Places List. \(e)")
                    } else {
                        
                        if document != nil && document!.exists {
                            
                            let data = document!.data()
                            
                            if self.callPressed == true {
                                
                                self.phoneNumbersList = []
                                
                                // Add Phone Contact Info
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
                            // Add Email Info
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
                            // Add Map Info
                            if self.mapPressed == true {
                                
                                self.mapLink = ""
                                
                                // Map Contact Info
                                if let map = data![Constants.Firestore.Key.gMaps] as? String {
                                    if map != "" {
                                        self.mapLink = map
                                    }
                                }
                            }
                            // Add Website Info
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
    
    // MARK: - MULTIPLE PLACES CARDS
    
    func getMultiplePlacesList() {
        
        // Get Multiple Places locations list
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
                                        
                                        let places = MultiplePlaces(city: cityName, street: cityStreet, gMapsLink: cityMap)
                                        
                                        self.locationsList.append(places)
                                        
                                        if self.cardEdited == false {
                                        self.selectLocation.text = "\(self.locationsList.first!.city) - \(self.locationsList.first!.street)"
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.checkCardDataMP()
                }
            }
    }
    
    // MARK: - Check Card for Multiple Places Location
    
    func checkCardDataMP() {
        
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
    
    // MARK: - Get Card for selected Multiple Places location
    
    func getCardMP() {
        
        if socialPressed == true {
            
            socialMediaList = []
            
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
        
        callButton.isHidden = true
        mailButton.isHidden = true
        mapButton.isHidden = true
        websiteButton.isHidden = true
        socialButton.isHidden = true
        
        self.checkSocialData()
        self.checkCardDataMP()
    }
}
