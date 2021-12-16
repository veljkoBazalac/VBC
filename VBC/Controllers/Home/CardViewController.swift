//
//  CardViewController.swift
//  VBC
//
//  Created by VELJKO on 30.10.21..
//

import UIKit
import Firebase
import FirebaseStorage

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
    // PickerView
    var pickerView = UIPickerView()
    // Locations Dictionary
    var locationsList : [MultiplePlaces] = []
    
    var phoneNumbers : [String] = []
    var companyHasPhone : Bool?
    var companyHasEmail : Bool?
    var companyHasWebsite : Bool?
    
    var phone1Number : String = ""
    var phone2Number : String = ""
    var phone3Number : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCompanyCards()
        
        if singlePlace == true {
            getSinglePlaceList()
        } else {
            getMultiplePlacesList()
        }
        
        selectLocation.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(false, animated: true)
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
        
        if singlePlace == true {
            return Constants.Firestore.CollectionName.companyCards
        } else {
            return Constants.Firestore.CollectionName.companyCards
        }
        
    }
    
    // MARK: - Getting both Company and Personal cards
    func getCompanyCards() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(companyOrPersonal())
            .collection(user!)
            .document(singleOrMultiple())
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error getting Multiple Places List. \(e)")
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
                                        
                                        
                                        // Company Phone Check
                                        if (data![Constants.Firestore.Key.phone1] as? String) != nil {
                                            self.companyHasPhone = true
                                            if (data![Constants.Firestore.Key.phone2] as? String) != nil {
                                                self.companyHasPhone = true
                                                if (data![Constants.Firestore.Key.phone3] as? String) != nil {
                                                    self.companyHasPhone = true
                                                }
                                            }
                                        }
                                        // Company Email Check
                                        if (data![Constants.Firestore.Key.email1] as? String) != nil {
                                            self.companyHasEmail = true
                                            if (data![Constants.Firestore.Key.email2] as? String) != nil {
                                                self.companyHasEmail = true
                                            }
                                        }
                                        // Company Website Check
                                        if (data![Constants.Firestore.Key.web1] as? String) != nil {
                                            self.companyHasWebsite = true
                                            if (data![Constants.Firestore.Key.web2] as? String) != nil {
                                                self.companyHasWebsite = true
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
    
    // MARK: - Get Phone Numbers for Single Place
    func phoneNumbersSinglePlace() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(companyOrPersonal())
            .collection(user!)
            .document(singleOrMultiple())
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error getting Multiple Places List. \(e)")
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let data = document!.data()
                        
                        self.phoneNumbers = []
                        
                        // Company Contact Info
                        if let companyPhone1 = data![Constants.Firestore.Key.phone1] as? String {
                            self.phoneNumbers.append(companyPhone1)
                        }
                        if let companyPhone2 = data![Constants.Firestore.Key.phone2] as? String {
                            self.phoneNumbers.append(companyPhone2)
                        }
                        if let companyPhone3 = data![Constants.Firestore.Key.phone3] as? String {
                            self.phoneNumbers.append(companyPhone3)
                        }
                        self.performSegue(withIdentifier: Constants.Segue.cardToPopUp, sender: self)
                    }
                }
            }
        
        
    }
    
    
    
    
    // MARK: - Get Phone Number for selected Multiple Place location
    func phoneNumbersMultiplePlaces() {
        
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
                        
                        self.phoneNumbers = []
                        
                        // Company Contact Info
                        if let companyPhone1 = data![Constants.Firestore.Key.phone1] as? String {
                            self.phoneNumbers.append(companyPhone1)
                        }
                        if let companyPhone2 = data![Constants.Firestore.Key.phone2] as? String {
                            self.phoneNumbers.append(companyPhone2)
                        }
                        if let companyPhone3 = data![Constants.Firestore.Key.phone3] as? String {
                            self.phoneNumbers.append(companyPhone3)
                        }
                        self.performSegue(withIdentifier: Constants.Segue.cardToPopUp, sender: self)
                    }
                }
            }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.cardToPopUp {
            
            let destinationVC = segue.destination as! PopUpCardViewController
            
            
            destinationVC.popUpTitle = selectLocation.text
            destinationVC.phoneNumbersList = phoneNumbers
            
        }
    }
    
    // MARK: - Contact Buttons
    
    // Call Button
    @IBAction func callButtonPressed(_ sender: UITapGestureRecognizer) {
        if singlePlace == true {
            phoneNumbersSinglePlace()
        } else {
            phoneNumbersMultiplePlaces()
        }
    }
    
    // Email Button
    @IBAction func emailButtonPressed(_ sender: UITapGestureRecognizer) {
        print("Email Pressed")
        
        print(phoneNumbers)
    }
    
    // Map Button
    @IBAction func mapButtonPressed(_ sender: UITapGestureRecognizer) {
        print("Map Pressed")
        print(cardID)
    }
    
    // Website Button
    @IBAction func websiteButtonPressed(_ sender: UITapGestureRecognizer) {
        print("Website Pressed")
        
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
        selectLocation.text = "\(locationsList[row].city) - \(locationsList[row].street)"
    }
}
