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
    @IBOutlet weak var nameLabel: UILabel!
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
        
        callButton.isHidden = true
        mailButton.isHidden = true
        mapButton.isHidden = true
        websiteButton.isHidden = true
        socialButton.isHidden = true
        
        getLocationsList()
        
        selectLocation.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        saveOrEditButton()
        callPressed = false
        emailPressed = false
        mapPressed = false
        websitePressed = false
        socialPressed = false
    }
    
    func saveOrEditButton() {
        
        if user! != userID {
            saveButton.titleLabel?.text = "Save"
        } else if user! == userID {
            saveButton.titleLabel?.text = "Edit"
        }
        
        
    }
    
    // MARK: - Getting Single Place or Multiple Places Locations
    func getLocationsList() {
        
        if singlePlace == true && companyCard == true {
            getCompanyBasicInfo()
            getSinglePlaceList()
        } else if singlePlace == false && companyCard == true {
            getCompanyBasicInfo()
            getMultiplePlacesList()
        } else {
            getPersonalBasicInfo()
            getPersonalLocation()
        }
    }
    // MARK: - Show Buttons that have Data
    func showButtons() {
        
        if companyCard == true {
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
        } else {
            
            if personHasPhone == true {
                callButton.isHidden = false
            }
            if personHasEmail == true {
                mailButton.isHidden = false
            }
            if personHasWebsite == true {
                websiteButton.isHidden = false
            }
            if personHasSocial == true {
                socialButton.isHidden = false
            }
            
        }
        
    }
    
    // MARK: - Pop Up With Ok
        
        func popUpWithOk(newTitle: String, newMessage: String) {
            // Pop Up with OK button
            let alert = UIAlertController(title: newTitle, message: newMessage, preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "OK", style: .default) { action in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(actionOK)
            self.present(alert, animated: true, completion: nil)
        }
    
    
    // MARK: - Prepare for PopUp Segue
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
        
        if segue.identifier == Constants.Segue.editComCard {
            
            let destinationVC = segue.destination as! CAdd1ViewController
            
            destinationVC.editCard = true
            destinationVC.editCardID = cardID
            destinationVC.editUserID = userID
            
            
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
        
        if companyCard == true {
            if singlePlace == true {
                getCompanyCardSP()
            } else {
                getCompanyCardMP()
            }
        } else {
            getPersonalCard()
        }
    }
    
// MARK: - Email Button
    
    @IBAction func emailButtonPressed(_ sender: UITapGestureRecognizer) {
        emailPressed = true
        
        if companyCard == true {
            if singlePlace == true {
                getCompanyCardSP()
            } else {
                getCompanyCardMP()
            }
        } else {
            getPersonalCard()
        }
        
    }

// MARK: - Map Button
    
    @IBAction func mapButtonPressed(_ sender: UITapGestureRecognizer) {
        mapPressed = true
        
        if singlePlace == true {
            getCompanyCardSP()
        } else {
            getCompanyCardMP()
        }
        
        if let gMap = URL(string:"\(self.mapLink)"), UIApplication.shared.canOpenURL(gMap) {
            UIApplication.shared.open(gMap, options: [:], completionHandler: nil)
        }
        
    }
    
// MARK: - Website Button
    
    @IBAction func websiteButtonPressed(_ sender: UITapGestureRecognizer) {
        websitePressed = true
        
        if companyCard == true {
            if singlePlace == true {
                getCompanyCardSP()
            } else {
                getCompanyCardMP()
            }
        } else {
            getPersonalCard()
        }
    }
    
    // MARK: - Social Button Pressed
    
    @IBAction func socialButtonPressed(_ sender: UITapGestureRecognizer) {
        socialPressed = true
        
        getPersonalCard()
    }
    
    // MARK: - SHARE AND SAVE BUTTONS
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        // Action Sheet da kopira Card ID
        print("Share pressed")
    }
    
    // Save Button Pressed
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        if user! != userID && saveButton.titleLabel?.text == "Save" {
            saveVBC()
        } else {
            
            let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            // Basic Info Action
            let basicInfoAction: UIAlertAction = UIAlertAction(title: "Basic Info", style: .default) { action -> Void in

                print("Basic Info pressed")
            }
            // Location Info Action
            let locInfoAction: UIAlertAction = UIAlertAction(title: "Location Info", style: .default) { action -> Void in

                print("Location Info pressed")
            }
            // Contact Info Action
            let contactInfoAction: UIAlertAction = UIAlertAction(title: "Contact Info", style: .default) { action -> Void in

                print("Contact Info pressed")
            }
            // Cancel Action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }

            actionSheetController.addAction(basicInfoAction)
            actionSheetController.addAction(locInfoAction)
            actionSheetController.addAction(contactInfoAction)
            actionSheetController.addAction(cancelAction)

            present(actionSheetController, animated: true, completion: nil)   // doesn't work for iPad
            
            
            
            
//            if companyCard == true {
//                performSegue(withIdentifier: Constants.Segue.editComCard, sender: self)
//            } else {
//                performSegue(withIdentifier: Constants.Segue.editPersCard, sender: self)
//            }
            
        }
        
    }
    
}
// Probaj da uprostis dole kod posto je promenjeno mesto baze podataka
// MARK: - Save VBC

extension CardViewController {
    
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
                    self.saveButton.titleLabel?.text = "Delete"
                    self.popUpWithOk(newTitle: "Saved Successfully", newMessage: "This VBC will be shown in your Saved Tab.")
                }
            }
        
    }
    
}

// MARK: - COMPANY CARD

extension CardViewController {
    
    // MARK: - Getting Basic Info for Company Card
    func getCompanyBasicInfo() {
        
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
                        
                        if let companyName = data![Constants.Firestore.Key.Name] as? String {
                            if let companySector = data![Constants.Firestore.Key.sector] as? String {
                                if let companyProductType = data![Constants.Firestore.Key.type] as? String {
                                    if let companyCountry = data![Constants.Firestore.Key.country] as? String {
                                        
                                        // Basic Company Info
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
    
    
    // MARK: - Get Single Place
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
                                
                                self.selectLocation.text = "\(cityName) - \(streetName)"
                                self.selectLocation.isEnabled = false
                            }
                        }
                    }
                    self.checkCompanyCardDataSP()
                }
            }
    }
    
    
    // MARK: - Check Company Card Data with Single Place Location
    
    func checkCompanyCardDataSP() {
        
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
                        
                        // Company Phone Check
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
                        
                        // Company Email Check
                        if data![Constants.Firestore.Key.email1] != nil {
                            if (data![Constants.Firestore.Key.email1] as? String) != "" {
                                self.companyHasEmail = true
                                
                                if (data![Constants.Firestore.Key.email2] as? String) != "" {
                                    self.companyHasEmail = true
                                }
                            }
                        }
                        
                        // Company Map Check
                        if data![Constants.Firestore.Key.gMaps] != nil {
                            if (data![Constants.Firestore.Key.gMaps] as? String) != "" {
                                self.companyHasMap = true
                            }
                        }
                        
                        // Company Website Check
                        if data![Constants.Firestore.Key.web1] != nil {
                            if (data![Constants.Firestore.Key.web1] as? String) != "" {
                                self.companyHasWebsite = true
                                
                                if (data![Constants.Firestore.Key.web2] as? String) != "" {
                                    self.companyHasWebsite = true
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.showButtons()
                    }
                }
            }
    }
    
    
    // MARK: - Get Company Card for Single Place
    
    func getCompanyCardSP() {
        
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
    
    // MARK: - Get Multiple Places List
    
    func getMultiplePlacesList() {
        
        // Getting Multiple Places locations list
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
                    
                    if let snapshotDocuments = snapshot?.documents {
                        
                        for documents in snapshotDocuments {
                            
                            let data = documents.data()
                            
                            // Getting Location Data
                            if let cityName = data[Constants.Firestore.Key.city] as? String {
                                if let cityStreet = data[Constants.Firestore.Key.street] as? String {
                                    if let cityMap = data[Constants.Firestore.Key.gMaps] as? String {
                                        
                                        let places = MultiplePlaces(city: cityName, street: cityStreet, gMapsLink: cityMap)
                                        
                                        self.locationsList.append(places)
                                        
                                        self.selectLocation.text = "\(self.locationsList.first!.city) - \(self.locationsList.first!.street)"
                                        
                                    }
                                }
                            }
                        }
                    }
                    self.checkCompanyCardDataMP()
                }
            }
    }
    
    
    // MARK: - Check Company Card with Multiple Places Location
    
    func checkCompanyCardDataMP() {
        
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
                        
                        // Company Phone Check
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
                        
                        // Company Email Check
                        if data![Constants.Firestore.Key.email1] != nil {
                            if (data![Constants.Firestore.Key.email1] as? String) != "" {
                                self.companyHasEmail = true
                                
                                if (data![Constants.Firestore.Key.email2] as? String) != "" {
                                    self.companyHasEmail = true
                                }
                            }
                        }
                        
                        // Company Map Check
                        if data![Constants.Firestore.Key.gMaps] != nil {
                            if (data![Constants.Firestore.Key.gMaps] as? String) != "" {
                                self.companyHasMap = true
                            }
                        }
                        
                        // Company Website Check
                        if data![Constants.Firestore.Key.web1] != nil {
                            if (data![Constants.Firestore.Key.web1] as? String) != "" {
                                self.companyHasWebsite = true
                                
                                if (data![Constants.Firestore.Key.web2] as? String) != "" {
                                    self.companyHasWebsite = true
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.showButtons()
                    }
                }
            }
        
    }
    
    
    // MARK: - Get Company Card for selected Multiple Places location
    
    func getCompanyCardMP() {
        
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

// MARK: - PERSONAL CARD

extension CardViewController {
    
    // MARK: - Get Personal Basic Info
    
    func getPersonalBasicInfo() {
        
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
                        
                        if let personalName = data![Constants.Firestore.Key.Name] as? String {
                            if let personalSector = data![Constants.Firestore.Key.sector] as? String {
                                if let personalProductType = data![Constants.Firestore.Key.type] as? String {
                                    if let personalCountry = data![Constants.Firestore.Key.country] as? String {
                                        
                                        // Basic Company Info
                                        self.nameLabel.text = personalName
                                        self.sectorLabel.text = personalSector
                                        self.productTypeLabel.text = personalProductType
                                        self.countryLabel.text = personalCountry
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    
    
    // MARK: - Get Personal Card
    
    func getPersonalCard() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error getting Personal Card. \(e)")
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
    }
    
    
    // MARK: - Get Personal Card Location
    func getPersonalLocation() {
        
        // Getting Single Place location
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .getDocument { document, error in
                
                if let e = error {
                    print("Error getting Personal location. \(e)")
                    
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
                            }
                        }
                        self.selectLocation.isEnabled = false
                    }
                    self.checkPersonalCardData()
                }
            }
    }
    
    
    // MARK: - Check Personal Card Data
    
    func checkPersonalCardData() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(userID)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error Checking Personal Card Data. \(e)")
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let data = document!.data()
                        
                        self.personHasPhone = false
                        self.personHasEmail = false
                        self.personHasSocial = false
                        self.personHasWebsite = false
                        
                        // Company Phone Check
                        if data![Constants.Firestore.Key.phone1] != nil {
                            if (data![Constants.Firestore.Key.phone1] as? String) != "" {
                                self.personHasPhone = true
                                
                                if (data![Constants.Firestore.Key.phone2] as? String) != "" {
                                    self.personHasPhone = true
                                    
                                    if (data![Constants.Firestore.Key.phone3] as? String) != "" {
                                        self.personHasPhone = true
                                    }
                                }
                            }
                        }
                        
                        // Company Email Check
                        if data![Constants.Firestore.Key.email1] != nil {
                            if (data![Constants.Firestore.Key.email1] as? String) != "" {
                                self.personHasEmail = true
                                
                                if (data![Constants.Firestore.Key.email2] as? String) != "" {
                                    self.personHasEmail = true
                                }
                            }
                        }
                        
                        // Company Website Check
                        if data![Constants.Firestore.Key.web1] != nil {
                            if (data![Constants.Firestore.Key.web1] as? String) != "" {
                                self.personHasWebsite = true
                                
                                if (data![Constants.Firestore.Key.web2] as? String) != "" {
                                    self.personHasWebsite = true
                                }
                            }
                        }
                        
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
        
        self.checkCompanyCardDataMP()
    }
}
