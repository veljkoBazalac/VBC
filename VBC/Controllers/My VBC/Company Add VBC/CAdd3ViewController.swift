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
    @IBOutlet weak var addLocationContact: UIButton!
    
    // Phone Number 1
    @IBOutlet weak var phone1Label: UILabel!
    @IBOutlet weak var phone1Code: UITextField!
    @IBOutlet weak var phone1Number: UITextField!
    @IBOutlet weak var addPhone2: UIButton!
    
    // Phone Number 2
    @IBOutlet weak var phone2Stack: UIStackView!
    @IBOutlet weak var phone2Code: UITextField!
    @IBOutlet weak var phone2Number: UITextField!
    @IBOutlet weak var addPhone3: UIButton!
    
    //Phone Number 3
    @IBOutlet weak var phone3Stack: UIStackView!
    @IBOutlet weak var phone3Code: UITextField!
    @IBOutlet weak var phone3Number: UITextField!
    
    // Email Address 1
    @IBOutlet weak var email1Label: UILabel!
    @IBOutlet weak var email1Address: UITextField!
    @IBOutlet weak var addEmail2: UIButton!
    
    // Email Address 2
    @IBOutlet weak var email2Stack: UIStackView!
    @IBOutlet weak var email2Address: UITextField!
    
    // Website 1
    @IBOutlet weak var website1Label: UILabel!
    @IBOutlet weak var website1Link: UITextField!
    @IBOutlet weak var addWebsite2: UIButton!
    
    // Website 2
    @IBOutlet weak var website2Stack: UIStackView!
    @IBOutlet weak var website2Link: UITextField!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    
    // Firebase Auth Current user ID
    let user = Auth.auth().currentUser?.uid
    
    // Picker View
    var pickerView = UIPickerView()
    
    // Locations Dict
    var locationsList : [MultiplePlaces] = []
    
    // Info successfully added
    var infoAdded : Bool = false
    var infoForPlace : Int = 0
    
    // Basic Info from 1st Step
    var selectedNewLogo : UIImage?
    var selectedNewCompanyName : String = ""
    var selectedNewSector : String = ""
    var selectedNewProductType : String = ""
    
    // Location Info from 2nd Step
    var selectedNewCountry : String = ""
    var currentCardID : String = ""
    var numberOfPlaces : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(infoForPlace)
        print(numberOfPlaces)
        
        
        getCountryCode()
        
        if numberOfPlaces <= 1 {
            getSinglePlace()
        } else {
            getMultiplePlaces()
        }
        
        selectLocation.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        
        phone2Stack.isHidden = true
        phone3Stack.isHidden = true
        email2Stack.isHidden = true
        website2Stack.isHidden = true
        
        logoImageView.image = selectedNewLogo
        companyName.text = selectedNewCompanyName
        companySector.text = selectedNewSector
        companyProductType.text = selectedNewProductType
        
    }
    
    // MARK: - Get Country Code and Show it in Text Field
    
    func getCountryCode() {
        
        let countryCode = Country().getCountryCode(country: selectedNewCountry)
        
        phone1Code.text = "+\(countryCode)"
        phone2Code.text = "+\(countryCode)"
        phone3Code.text = "+\(countryCode)"
        
    }
    
    // MARK: - Get Single Place
    
    func getSinglePlace() {
        
        // Getting Single Place location
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(user!)
            .document(Constants.Firestore.CollectionName.singlePlace)
            .collection(Constants.Firestore.CollectionName.cardID)
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
            .collection(user!)
            .document(Constants.Firestore.CollectionName.multiplePlaces)
            .collection(Constants.Firestore.CollectionName.cardID)
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
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Add Contact for Selected Location
    
    @IBAction func addLocationContactPressed(_ sender: UIButton) {
        
        if numberOfPlaces <= 1 {
            // At least one Field must have Contact info
            if phone1Number.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" && email1Address.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" && website1Link.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                
                self.popUpWithOk(newTitle: "Contact Info Missing", newMessage: "Please add at least one Contact info.")
                
            }  else {
                // Adding Contact Info for Single Place Location
                
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.companyCards)
                    .collection(user!)
                    .document(Constants.Firestore.CollectionName.singlePlace)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(currentCardID)
                    .setData(["Phone1Code": phone1Code.text!,"Phone 1": phone1Number.text!,"Phone2Code": phone2Code.text!, "Phone 2": phone2Number.text!, "Phone3Code": phone3Code.text!,"Phone 3": phone3Number.text!, "Email 1": email1Address.text!, "Email 2": email2Address.text!, "Website 1": website1Link.text!, "Website 2": website2Link.text!], merge: true) { error in
                    
                    if error != nil {
                        self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading Contact Info to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)")
                    } else {
                        self.popUpWithOk(newTitle: "Contact Info successfully added", newMessage: "Contact Info for \(self.selectLocation.text!) successfully added.")
                        self.infoAdded = true
                        self.infoForPlace += 1
                    }
                }
            }
        } else if numberOfPlaces > 1 {
            // At least one Field must have Contact info
            if selectLocation.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                self.popUpWithOk(newTitle: "Select Location", newMessage: "Please select Location to add Contact Info.")
        }
           else if phone1Number.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" && email1Address.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" && website1Link.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                
                self.popUpWithOk(newTitle: "Contact Info Missing", newMessage: "Please add at least one Contact info.")
             
            } else {
                // Adding Contact Info for Multiple Places
                
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.companyCards)
                    .collection(user!)
                    .document(Constants.Firestore.CollectionName.multiplePlaces)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(currentCardID)
                    .collection(Constants.Firestore.CollectionName.locations)
                    .document(selectLocation.text!)
                    .setData(["Phone1Code": phone1Code.text!,"Phone 1": phone1Number.text!,"Phone2Code": phone2Code.text!, "Phone 2": phone2Number.text!, "Phone3Code": phone3Code.text!,"Phone 3": phone3Number.text!, "Email 1": email1Address.text!, "Email 2": email2Address.text!, "Website 1": website1Link.text!, "Website 2": website2Link.text!], merge: true) { error in
                    
                    if error != nil {
                        self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading Contact Info to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)")
                    } else {
                        self.popUpWithOk(newTitle: "Contact Info successfully added", newMessage: "Contact Info for \(self.selectLocation.text!) successfully added.")
                        self.infoAdded = true
                        self.infoForPlace += 1
                    }
                }
            }
        }
    }
    
    // MARK: - Finish Creating Company VBC
    
    @IBAction func finishButtonPressed(_ sender: UIBarButtonItem) {
        
        if infoAdded == true && infoForPlace == numberOfPlaces {
            
            performSegue(withIdentifier: Constants.Segue.cAddFinish, sender: self)
                
        } else {
            if numberOfPlaces <= 1 {
                self.popUpWithOk(newTitle: "Contact Info Missing", newMessage: "Press + button next to your Location field to add Contact Info. You must add at least one Contact Info.")
                
            } else if numberOfPlaces > 1 {
                self.popUpWithOk(newTitle: "Contact Info Missing", newMessage: "Press + button next to your Location field to add Contact Info. You must add at least one Contact Info for every Location.")
            }
        }
    }
    
    // MARK: - Phone Number Actions
    
    @IBAction func addPhone2ButtonPressed(_ sender: UIButton) {
        
        if phone1Number.text != "" {
            phone2Stack.isHidden = false
            phone1Label.text = "Phone 1 :"
            addPhone2.isHidden = true
        }
    
    }
    
    
    @IBAction func addPhone3ButtonPressed(_ sender: UIButton) {
        
        if phone2Number.text != "" {
            phone3Stack.isHidden = false
            addPhone3.isHidden = true
        }
        
    }
    
    // MARK: - Email Number Action
    
    @IBAction func addEmail2ButtonPressed(_ sender: UIButton) {
        
        if email1Address.text != "" {
            
            email2Stack.isHidden = false
            email1Label.text = "Email 1 :"
            addEmail2.isHidden = true
        }
        
    }
    
    // MARK: - Website Link Action
    
    @IBAction func addWebsite2ButtonPressed(_ sender: UIButton) {
        
        if website1Link.text != "" {
            
            website2Stack.isHidden = false
            website1Label.text = "Website 1 :"
            addWebsite2.isHidden = true
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
            
        }
        else {
            self.popUpWithOk(newTitle: "Error!", newMessage: "There was an Error when selected row. Please try again.")
        }
    }
}
