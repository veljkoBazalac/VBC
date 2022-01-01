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
    
    var phoneNumbersList : [PhoneNumber] = []
    var emailAddressList : [String] = []
    var websiteList : [String] = []
    var mapLink : String = ""
    
    var companyHasPhone : Bool = false
    var companyHasEmail : Bool = false
    var companyHasMap : Bool = false
    var companyHasWebsite : Bool = false
    
    var callPressed : Bool = false
    var emailPressed : Bool = false
    var mapPressed : Bool = false
    var websitePressed : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callButton.isHidden = true
        mailButton.isHidden = true
        mapButton.isHidden = true
        websiteButton.isHidden = true
        
        getLocationsList()
        
        selectLocation.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        callPressed = false
        emailPressed = false
        mapPressed = false
        websitePressed = false
    }
    
    // MARK: - Getting Single Place or Multiple Places Locations
    func getLocationsList() {
        
        if singlePlace == true {
            getBasicInfo()
            getSinglePlaceList()
        } else {
            getBasicInfo()
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
    }
    
    // MARK: - Function that return Single Or Multiple Places
    func singleOrMultiple() -> String {
        if singlePlace == true {
            return Constants.Firestore.CollectionName.singlePlace
        } else {
            return Constants.Firestore.CollectionName.multiplePlaces
        }
    }
    
    // MARK: - Function that return Company or Personal Cards
    func companyOrPersonal() -> String {
        
        if companyCard == true {
            return Constants.Firestore.CollectionName.companyCards
        } else {
            return Constants.Firestore.CollectionName.companyCards
        }
    }
    
    // MARK: - Getting Basic Info
    func getBasicInfo() {
        
        // Getting Basic Info
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(companyOrPersonal())
            .collection(user!)
            .document(singleOrMultiple())
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
    
    
    // MARK: - Check Card Data with Single Place Location
    func checkCardDataSP() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(companyOrPersonal())
            .collection(user!)
            .document(Constants.Firestore.CollectionName.singlePlace)
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
                        if (data![Constants.Firestore.Key.phone1] as? String) != "" {
                            self.companyHasPhone = true
                            
                            if (data![Constants.Firestore.Key.phone2] as? String) != "" {
                                self.companyHasPhone = true
                                
                                if (data![Constants.Firestore.Key.phone3] as? String) != "" {
                                    self.companyHasPhone = true
                                }
                            }
                        }
                        
                        // Company Email Check
                        if (data![Constants.Firestore.Key.email1] as? String) != "" {
                            self.companyHasEmail = true
                            
                            if (data![Constants.Firestore.Key.email2] as? String) != "" {
                                self.companyHasEmail = true
                            }
                        }
                        
                        
                        // Company Map Check
                        if (data![Constants.Firestore.Key.gMaps] as? String) != "" {
                            self.companyHasMap = true
                        }
                        
                        // Company Website Check
                        if (data![Constants.Firestore.Key.web1] as? String) != "" {
                            self.companyHasWebsite = true
                            
                            if (data![Constants.Firestore.Key.web2] as? String) != "" {
                                self.companyHasWebsite = true
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.showButtons()
                    }
                }
            }
    }
    // MARK: - Getting Card with Multiple Places Location
    
    func checkCardDataMP() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(companyOrPersonal())
            .collection(user!)
            .document(Constants.Firestore.CollectionName.multiplePlaces)
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
                        if (data![Constants.Firestore.Key.phone1] as? String) != "" {
                            self.companyHasPhone = true
                            
                            if (data![Constants.Firestore.Key.phone2] as? String) != "" {
                                self.companyHasPhone = true
                                
                                if (data![Constants.Firestore.Key.phone3] as? String) != "" {
                                    self.companyHasPhone = true
                                }
                            }
                        }
                        // Company Email Check
                        if (data![Constants.Firestore.Key.email1] as? String) != "" {
                            self.companyHasEmail = true
                            
                            if (data![Constants.Firestore.Key.email2] as? String) != "" {
                                self.companyHasEmail = true
                            }
                        }
                        // Company Map Check
                        if (data![Constants.Firestore.Key.gMaps] as? String) != "" {
                            self.companyHasMap = true
                        }
                        
                        // Company Website Check
                        if (data![Constants.Firestore.Key.web1] as? String) != "" {
                            self.companyHasWebsite = true
                            
                            if (data![Constants.Firestore.Key.web2] as? String) != "" {
                                self.companyHasWebsite = true
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.showButtons()
                    }
                }
            }
        
    }
    
    // MARK: - Get Phone Numbers for Single Place
    func getCardSP() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(companyOrPersonal())
            .collection(user!)
            .document(Constants.Firestore.CollectionName.singlePlace)
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
    
    // MARK: - Get Contact Info for selected Multiple Places location
    func getCardMP() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(user!)
            .document(Constants.Firestore.CollectionName.multiplePlaces)
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
    
    
    
    // MARK: - Prepare for PopUp Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.cardToPopUp {
            
            let destinationVC = segue.destination as! PopUpCardViewController
            
            destinationVC.popUpTitle = selectLocation.text
            destinationVC.phoneNumbersList = phoneNumbersList
            destinationVC.emailAddressList = emailAddressList
            destinationVC.websiteList = websiteList
            
            destinationVC.callPressed = callPressed
            destinationVC.emailPressed = emailPressed
            destinationVC.websitePressed = websitePressed
            
            callPressed = false
            emailPressed = false
            websitePressed = false
        }
    }
    
    // MARK: - Contact Buttons
    
    // Call Button
    @IBAction func callButtonPressed(_ sender: UITapGestureRecognizer) {
        callPressed = true
        
        if singlePlace == true {
            getCardSP()
        } else {
            getCardMP()
        }
    }
    
    // Email Button
    @IBAction func emailButtonPressed(_ sender: UITapGestureRecognizer) {
        emailPressed = true
        
        if singlePlace == true {
            getCardSP()
        } else {
            getCardMP()
        }
        
    }
    
    // Map Button
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
    
    // Website Button
    @IBAction func websiteButtonPressed(_ sender: UITapGestureRecognizer) {
        websitePressed = true
        
        if singlePlace == true {
            getCardSP()
        } else {
            getCardMP()
        }
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

// MARK: - Get Single and Multiple Location list
extension CardViewController {
    
    // MARK: - Get Single Place
    func getSinglePlaceList() {
        
        // Getting Single Place location
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(user!)
            .document(Constants.Firestore.CollectionName.singlePlace)
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
                    self.checkCardDataSP()
                }
            }
    }
    
    // MARK: - Get Multiple Places List
    
    func getMultiplePlacesList() {
        
        // Getting Multiple Places locations list
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(user!)
            .document(Constants.Firestore.CollectionName.multiplePlaces)
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
                    self.checkCardDataMP()
                }
            }
    }
    
}

extension CardViewController: MFMailComposeViewControllerDelegate {
    
    func showMailComposer() {
        
        guard MFMailComposeViewController.canSendMail() else {
            print("Error MF Cant send email.")
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["Test@g2.com"])
        present(composer, animated: true, completion: nil)
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let e = error {
            print("Error Finsihing Email with results.\(e)")
            controller.dismiss(animated: true, completion: nil)
            return
        }
        
        switch result {
        case .cancelled:
            print("Canceled")
        case .failed:
            print("Failed")
        case .saved:
            print("Saved")
        case .sent:
            print("Email Sent")
        default:
            print("Try Again")
        }
        
        controller.dismiss(animated: true, completion: nil)
        
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

        self.checkCardDataMP()
    }
}
