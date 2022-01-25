//
//  CAdd3ViewController.swift
//  VBC
//
//  Created by VELJKO on 14.11.21..
//

import UIKit
import Firebase

class CAdd3ViewController: UIViewController {
    
    // Basic Company Info and Logo image Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var companySector: UILabel!
    @IBOutlet weak var companyProductType: UILabel!
    
    // Select Location Outlet
    @IBOutlet weak var selectLocation: UITextField!
    
    // Phone Number 1
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneCode: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var phoneListButton: UIButton!
    
    // Email Address 1
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var emailListButton: UIButton!
    
    // Website 1
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var websiteLink: UITextField!
    @IBOutlet weak var websiteListButton: UIButton!
    
    // Finish Nav Button
    @IBOutlet weak var finishButton: UIBarButtonItem!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Auth Current user ID
    let user = Auth.auth().currentUser?.uid
    // Picker View
    var pickerView = UIPickerView()
    // Locations Dict
    var locationsList : [MultiplePlaces] = []
    // Info successfully added
    var infoForPlace = [String:Bool]()
    // Show Pop Up or No
    var showPopUp : Bool = true
    // Number of Contact Data Added
    var numberOfPhones : Int = 0
    var numberOfEmails : Int = 0
    var numberOfWebsite : Int = 0
    
    // Basic Info from 1st Step
    var selectedNewLogo : UIImage?
    var selectedNewCompanyName : String = ""
    var selectedNewSector : String = ""
    var selectedNewProductType : String = ""
    
    // Location Info from 2nd Step
    var selectedNewCountry : String = ""
    var currentCardID : String = ""
    var numberOfPlaces : Int = 0
    
    // Contact Info from 3rd Step
    var phone1 : String = ""
    var phone2 : String = ""
    var phone3 : String = ""
    
    var email1 : String = ""
    var email2 : String = ""
    
    var web1 : String = ""
    var web2 : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        finishButton.isEnabled = false
        
        getCountryCode()
        
        getData()
        
        selectLocation.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        
        logoImageView.image = selectedNewLogo
        companyName.text = selectedNewCompanyName
        companySector.text = selectedNewSector
        companyProductType.text = selectedNewProductType
    }
    
    // MARK: - Get Data from Firestore Function
    
    func getData() {
        if numberOfPlaces <= 1 {
            getSinglePlace()
        } else {
            getMultiplePlaces()
        }
    }
    
    // MARK: - Get Country Code and Show it in Text Field
    
    func getCountryCode() {
        let countryCode = Country().getCountryCode(country: selectedNewCountry)
        phoneCode.text = "+\(countryCode)"
    }
    
    // MARK: - Get Single Place
    
    func getSinglePlace() {
        // Getting Single Place location
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.singlePlace)
            .document(currentCardID)
            .getDocument { document, error in
                
                if let e = error {
                    print("Error getting Singe Place. \(e)")
                    
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let documentData = document!.data()
                        
                        if let cityName = documentData![Constants.Firestore.Key.city] as? String {
                            if let streetName = documentData![Constants.Firestore.Key.street] as? String {
                                
                                self.selectLocation.text = "\(cityName) - \(streetName)"
                                self.selectLocation.isEnabled = false
                                self.infoForPlace.updateValue(false, forKey: "\(cityName) - \(streetName)")
                            }
                        }
                    }
                }
            }
    }
    
    // MARK: - Get Multiple Places List
    
    func getMultiplePlaces() {
        // Getting Multiple Places locations list
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.multiplePlaces)
            .document(currentCardID)
            .collection(Constants.Firestore.CollectionName.locations)
            .getDocuments { snapshot, error in
                
                if let e = error {
                    print ("Error getting Multiple Places List. \(e)")
                } else {
                    
                    if let snapshotDocuments = snapshot?.documents {
                        
                        for documents in snapshotDocuments {
                            
                            let data = documents.data()
                            
                            if let cityName = data[Constants.Firestore.Key.city] as? String {
                                if let cityStreet = data[Constants.Firestore.Key.street] as? String {
                                    if let cityMap = data[Constants.Firestore.Key.gMaps] as? String {
                                        
                                        let places = MultiplePlaces(city: cityName, street: cityStreet, gMapsLink: cityMap)
                                        
                                        self.locationsList.append(places)
                                        self.infoForPlace.updateValue(false, forKey: "\(places.city) - \(places.street)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    // MARK: - Finish Creating Company VBC
    
    @IBAction func finishButtonPressed(_ sender: UIBarButtonItem) {
        
        if infoForPlace.values.contains(false) {
            
            if numberOfPlaces <= 1 {
                self.popUpWithOk(newTitle: "Contact Info Missing", newMessage: "Press + button to add Contact Info. You must add at least one Contact Info.")
                
            } else if numberOfPlaces > 1 {
                self.popUpWithOk(newTitle: "Contact Info Missing", newMessage: "Press + button to add Contact Info. You must add at least one Contact Info for every Location.")
            }
        } else {
            performSegue(withIdentifier: Constants.Segue.cAddFinish, sender: self)
        }
    }
    
    // MARK: - Phone Number Actions
    
    @IBAction func addPhonePressed(_ sender: UIButton) {
        // Adding Phone Numbers to Firestore
        if phoneNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
                if phone1.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    phone1 = phoneNumber.text!
                    
                    if numberOfPlaces <= 1 {
                        showPopUp = false
                        uploadSPContactData(field: Constants.Firestore.Key.phone1code, value: phoneCode.text!, button: phoneListButton)
                        showPopUp = true
                        uploadSPContactData(field: Constants.Firestore.Key.phone1, value: phone1, button: phoneListButton)
                    } else if numberOfPlaces > 1 {
                        showPopUp = false
                        uploadMPContactData(field: Constants.Firestore.Key.phone1code, value: phoneCode.text!, button: phoneListButton)
                        showPopUp = true
                        uploadMPContactData(field: Constants.Firestore.Key.phone1, value: phone1, button: phoneListButton)
                    }
                    phoneNumber.text = ""
                    
                } else if phone2.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    phone2 = phoneNumber.text!
                    
                    if numberOfPlaces <= 1 {
                        showPopUp = false
                        uploadSPContactData(field: Constants.Firestore.Key.phone2code, value: phoneCode.text!, button: phoneListButton)
                        showPopUp = true
                        uploadSPContactData(field: Constants.Firestore.Key.phone2, value: phone2, button: phoneListButton)
                    } else if numberOfPlaces > 1 {
                        showPopUp = false
                        uploadMPContactData(field: Constants.Firestore.Key.phone2code, value: phoneCode.text!, button: phoneListButton)
                        showPopUp = true
                        uploadMPContactData(field: Constants.Firestore.Key.phone2, value: phone2, button: phoneListButton)
                    }
                    phoneNumber.text = ""
                    
                } else if phone3.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    phone3 = phoneNumber.text!
                    
                    if numberOfPlaces <= 1 {
                        showPopUp = false
                        uploadSPContactData(field: Constants.Firestore.Key.phone3code, value: phoneCode.text!, button: phoneListButton)
                        showPopUp = true
                        uploadSPContactData(field: Constants.Firestore.Key.phone3, value: phone3, button: phoneListButton)
                    } else if numberOfPlaces > 1 {
                        showPopUp = false
                        uploadMPContactData(field: Constants.Firestore.Key.phone3code, value: phoneCode.text!, button: phoneListButton)
                        showPopUp = true
                        uploadMPContactData(field: Constants.Firestore.Key.phone3, value: phone3, button: phoneListButton)
                    }
                    phoneNumber.text = ""
                
            } else {
                popUpWithOk(newTitle: "Maximum reached", newMessage: "You can add Maximum 3 Numbers to your VBC.")
            }
        } else {
            popUpWithOk(newTitle: "Missing Phone Number", newMessage: "Please Enter your Phone Number.")
        }
    }
    
    // MARK: - Email Number Action
    @IBAction func addEmailPressed(_ sender: UIButton) {
        // Adding Emails to Firestore
        if emailAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
    
            if email1.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    email1 = emailAddress.text!
                    
                    if numberOfPlaces <= 1 {
                        uploadSPContactData(field: Constants.Firestore.Key.email1, value: email1, button: emailListButton)
                    } else if numberOfPlaces > 1 {
                        uploadMPContactData(field: Constants.Firestore.Key.email1, value: email1, button: emailListButton)
                    }
                    emailAddress.text = ""
                    
            } else if email2.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    email2 = emailAddress.text!
                    
                    if numberOfPlaces <= 1 {
                        uploadSPContactData(field: Constants.Firestore.Key.email2, value: email2, button: emailListButton)
                    } else if numberOfPlaces > 1 {
                        uploadMPContactData(field: Constants.Firestore.Key.email2, value: email2, button: emailListButton)
                    }
                    emailAddress.text = ""
                
            } else {
                popUpWithOk(newTitle: "Maximum reached", newMessage: "You can add Maximum 2 Email Addresses to your VBC.")
            }
        } else {
            popUpWithOk(newTitle: "Missing Email", newMessage: "Please Enter your Email Address.")
        }
    }
    
    // MARK: - Website Link Action
    
    @IBAction func addWebsitePressed(_ sender: UIButton) {
        // Adding Websites to Firestore
        if websiteLink.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
                if web1.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    web1 = websiteLink.text!
                    
                    if numberOfPlaces <= 1 {
                        uploadSPContactData(field: Constants.Firestore.Key.web1, value: web1, button: websiteListButton)
                    } else if numberOfPlaces > 1 {
                        uploadMPContactData(field: Constants.Firestore.Key.web1, value: web1, button: websiteListButton)
                    }
                    websiteLink.text = ""
                    
                } else if web2.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    web2 = websiteLink.text!
                    
                    if numberOfPlaces <= 1 {
                        uploadSPContactData(field: Constants.Firestore.Key.web2, value: web2, button: websiteListButton)
                    } else if numberOfPlaces > 1 {
                        uploadMPContactData(field: Constants.Firestore.Key.web2, value: web2, button: websiteListButton)
                    }
                    websiteLink.text = ""
                
            } else  {
                popUpWithOk(newTitle: "Maximum reached", newMessage: "You can add Maximum 2 Website Links yo your VBC.")
            }
        } else {
            popUpWithOk(newTitle: "Missing Website", newMessage: "Please Enter your Website Link.")
        }
    }
    // MARK: - Show List of Contact Data Buttons
    
    @IBAction func showPhoneListPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segue.cPhoneListSegue, sender: self)
    }
    
    
    @IBAction func showEmailPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segue.cEmailListSegue, sender: self)
    }
    
    
    @IBAction func showWebsitePressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segue.cWebsiteListSegue, sender: self)
    }
    
    // MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.cPhoneListSegue {
            
            let destinationVC = segue.destination as! ContactListVC
            
            destinationVC.popUpTitle = "Phone Number List"
            destinationVC.phoneListPressed = true
            destinationVC.cardID = currentCardID
            destinationVC.dataForLocation = selectLocation.text!
            destinationVC.delegate = self
            
            if numberOfPlaces <= 1 {
                destinationVC.singlePlace = true
            } else if numberOfPlaces > 1 {
                destinationVC.singlePlace = false
            }
            
        }
        
        else if segue.identifier == Constants.Segue.cEmailListSegue {
            
            let destinationVC = segue.destination as! ContactListVC
            
            destinationVC.popUpTitle = "Email List"
            destinationVC.emailListPressed = true
            destinationVC.cardID = currentCardID
            destinationVC.dataForLocation = selectLocation.text!
            destinationVC.delegate = self
            
            if numberOfPlaces <= 1 {
                destinationVC.singlePlace = true
            } else if numberOfPlaces > 1 {
                destinationVC.singlePlace = false
            }
        }
        
        if segue.identifier == Constants.Segue.cWebsiteListSegue {
            
            let destinationVC = segue.destination as! ContactListVC
            
            destinationVC.popUpTitle = "Website List"
            destinationVC.websiteListPressed = true
            destinationVC.cardID = currentCardID
            destinationVC.dataForLocation = selectLocation.text!
            destinationVC.delegate = self
            
            if numberOfPlaces <= 1 {
                destinationVC.singlePlace = true
            } else if numberOfPlaces > 1 {
                destinationVC.singlePlace = false
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
    
    // MARK: - Blink Button Function
    
    func blinkButton(buttonName: UIButton) {
        buttonName.tintColor = .green
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            buttonName.tintColor = UIColor(named: "Color Dark")
        }
    }
    
    // MARK: - Upload Multiple Places Contact Data
    
    func uploadMPContactData(field: String, value: String, button: UIButton) {
        // Adding Contact Info for Multiple Places
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.multiplePlaces)
            .document(currentCardID)
            .collection(Constants.Firestore.CollectionName.locations)
            .document(selectLocation.text!)
            .setData(["\(field)":"\(value)"], merge: true) { error in
                
                if error != nil {
                    self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading Contact Info to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)")
                } else {
                    if self.showPopUp == true {
                        self.popUpWithOk(newTitle: "Contact Info successfully added", newMessage: "Contact Info for \(self.selectLocation.text!) successfully added.")
                    }
                    
                    self.blinkButton(buttonName: button)
                    self.finishButton.isEnabled = true
                    self.infoForPlace.updateValue(true, forKey: self.selectLocation.text!)
                }
            }
        
    }
    
    // MARK: - Upload Single Place Contact Data
    
    func uploadSPContactData(field: String, value: String, button: UIButton) {
        // Adding Contact Info for Single Place Location
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.singlePlace)
            .document(currentCardID)
            .setData(["\(field)":"\(value)"], merge: true) { error in
                
                if error != nil {
                    self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading Contact Info to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)")
                } else {
                    if self.showPopUp == true {
                        self.popUpWithOk(newTitle: "Contact Info successfully added", newMessage: "Contact Info for \(self.selectLocation.text!) successfully added.")
                    }
                    
                    self.blinkButton(buttonName: button)
                    self.finishButton.isEnabled = true
                    self.infoForPlace.updateValue(true, forKey: self.selectLocation.text!)
                }
            }
    }
    
    
}

// MARK: - UIPickerView for Location

extension CAdd3ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if selectLocation.isEditing {
            return locationsList.count
        }
        else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if selectLocation.isEditing {
            return "\(locationsList[row].city) - \(locationsList[row].street)"
        }
        else {
            return "Error adding Title for Row."
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if selectLocation.isEditing {
            selectLocation.text = "\(locationsList[row].city) - \(locationsList[row].street)"
            phone1 = ""
            phone2 = ""
            phone3 = ""
            email1 = ""
            email2 = ""
            web1 = ""
            web2 = ""
        }
        else {
            self.popUpWithOk(newTitle: "Error!", newMessage: "There was an Error when selected row. Please try again.")
        }
    }
}

// MARK: - NumberOfContactData protocol delegate functions

extension CAdd3ViewController: NumberOfContactDataDelegate {

        func keyForContactData(key: String) {
            
            if key == Constants.Firestore.Key.phone1 {
                phone1 = ""
            } else if key == Constants.Firestore.Key.phone2 {
                phone2 = ""
            } else if key == Constants.Firestore.Key.phone3 {
                phone3 = ""
            } else if key == Constants.Firestore.Key.email1 {
                email1 = ""
            } else if key == Constants.Firestore.Key.email2 {
                email2 = ""
            } else if key == Constants.Firestore.Key.web1 {
                web1 = ""
            } else if key == Constants.Firestore.Key.web2 {
                web2 = ""
            }
        }
}
