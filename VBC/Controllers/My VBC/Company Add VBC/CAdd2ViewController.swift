//
//  CAdd2ViewController.swift
//  VBC
//
//  Created by VELJKO on 14.11.21..
//

import UIKit
import Firebase
import FirebaseStorage

class CAdd2ViewController: UIViewController {

    // Image and Text Stack Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var companySector: UILabel!
    @IBOutlet weak var companyProductType: UILabel!
    
    // Text Fields Outlets
    @IBOutlet weak var selectCountry: UITextField!
    @IBOutlet weak var cityName: UITextField!
    @IBOutlet weak var streetName: UITextField!
    @IBOutlet weak var googleMapsLink: UITextField!
    
    // Segment Outlet
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // Add, List and Delete Button Outlet
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Storage
    let storage = Storage.storage().reference()
    
    // Country List Dict
    private var countryList : [Country] = []
    // Multiple City List Dict
    private var multipleCityList : [MultipleCity] = []
    
    var cardID : String = ""
    
    var pickerView = UIPickerView()
    
    // Previous Screen Info
    var sectorNumber : Int?
    var logoImage : UIImage?
    var newCompanyName : String?
    var newSector : String?
    var newProductType : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        selectCountry.inputView = pickerView
        
        logoImageView.image = logoImage
        companyName.text = newCompanyName
        companySector.text = newSector
        companyProductType.text = newProductType

        getCountryList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        addButton.isHidden = true
        addButton.titleLabel?.text = ""
        listButton.isHidden = true
        listButton.titleLabel?.text = ""
        infoButton.isHidden = true
        infoButton.titleLabel?.text = ""
    }
    
// MARK: - Create Card ID Funcion
    func createCardID() {
        
        let countryCode = Country().getCountryCode(country: selectCountry.text!)
        let companyShortName = companyName.text!.prefix(3).uppercased()
        let randomNumber = Int.random(in: 100...999)
        
        let newCardID = "VBC\(countryCode)S\(sectorNumber!)\(companyShortName)\(randomNumber)"
        cardID = newCardID
    }
    
// MARK: - Next Button Pressed
    
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            
            db.collection(Constants.Firestore.CollectionName.companyCards).document(selectCountry.text!).collection(newSector!).document(cardID).setData(["Name": companyName.text!, "Sector": companySector.text!, "ProductType": companyProductType.text!, "CardID": cardID])
            
        } else {
            
            print("You selected Multiple Places. Please Add at least two Places.")
        }
        
     
        //performSegue(withIdentifier: Constants.Segue.cAdd3, sender: self)
    }
    
// MARK: - Add Location Button Pressed
    
    @IBAction func addLocationPressed(_ sender: UIButton) {
        
            
        db.collection(Constants.Firestore.CollectionName.companyCards).document(selectCountry.text!).collection(newSector!).document(cardID).setData(["Name": companyName.text, "Sector": companySector.text, "ProductType": companyProductType.text, "CardID": cardID])
            
            
        db.collection(Constants.Firestore.CollectionName.companyCards).document(selectCountry.text!).collection(newSector!).document(cardID).collection(Constants.Firestore.CollectionName.multipleCity).document("\(cityName.text!) - \(streetName.text!)").setData(["City": cityName.text, "Street": streetName.text, "gMaps Link": googleMapsLink.text]) { error in
            
            if error != nil {
                print("Error Uploading data to Firestore. \(error!)")
            } else {
                self.listButton.isHidden = false
                self.listButton.titleLabel?.text = ""
                self.addButton.titleLabel?.text = ""
            }
        }
        
    }
    
// MARK: - List Button Pressed
    
    @IBAction func listButtonPressed(_ sender: UIButton) {
        //getMultipleCity()

        performSegue(withIdentifier: Constants.Segue.cAddLocationList, sender: self)
    }
    
// MARK: - Info Button Pressed
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "You want to change a Country?", message: "To do it you first need to delete all your Places from the List.", preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) { action in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(actionOK)
        present(alert, animated: true, completion: nil)
    }

// MARK: - Segment Control
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
     
        if segmentedControl.selectedSegmentIndex == 1 {
            addButton.isHidden = false
            addButton.titleLabel?.text = ""
        } else {
            addButton.isHidden = true
            listButton.isHidden = true
        }
    }

// MARK: - Google Maps Icon Pressed
    
    @IBAction func gMapsIconPressed(_ sender: UITapGestureRecognizer) {
        
        print(cardID)
        
    }
    
// MARK: - Get Multiple City List
    
    func getMultipleCity() {
        
        
        db.collection(Constants.Firestore.CollectionName.companyCards).document(selectCountry.text!).collection(newSector!).document(cardID).collection(Constants.Firestore.CollectionName.multipleCity).getDocuments { snapshot, error in
            
            if let e = error {
                print ("Error getting Multiple City List. \(e)")
            } else {
                
                if let snapshotDocuments = snapshot?.documents {
                    
                    for documents in snapshotDocuments {
                       
                        let data = documents.data()
                        
                        if let cityName = data[Constants.Firestore.Key.city] as? String {
                            if let cityStreet = data[Constants.Firestore.Key.street] as? String {
                                if let cityMap = data[Constants.Firestore.Key.gMaps] as? String {
                                    
                                    let cities = MultipleCity(city: cityName, street: cityStreet, gMapsLink: cityMap)
                                 
                                    self.multipleCityList.append(cities)
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
// MARK: - Get Contries List Function
        
        func getCountryList() {
            
            db.collection(Constants.Firestore.CollectionName.countries).getDocuments { snapshot, error in
                
                if let e = error {
                    print("Error getting Country List. \(e)")
                } else {
                    
                    if let snapshotDocuments = snapshot?.documents {
                        
                        for documents in snapshotDocuments {
                            
                            let data = documents.data()
                                
                            if let countryData = data[Constants.Firestore.Key.name] as? String {
                                
                                let country = Country(name: countryData)
                                
                                self.countryList.append(country)
                            }
                        }
                    }
                }
            }
        }
    
    
}

// MARK: - UIPickerView for Country

extension CAdd2ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if selectCountry.isEditing {
            return countryList.count
        }
        else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if selectCountry.isEditing {
            return countryList[row].name
        }
         else {
            return "Error adding Title for Row."
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if selectCountry.isEditing {
            selectCountry.text = countryList[row].name
            createCardID()
            infoButton.isHidden = false
        }
         else {
            print("Error selecting Row!")
        }
    }
}
