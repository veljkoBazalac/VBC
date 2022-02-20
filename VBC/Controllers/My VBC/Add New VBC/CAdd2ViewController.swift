//
//  CAdd2ViewController.swift
//  VBC
//
//  Created by VELJKO on 14.11.21..
//

import UIKit
import Firebase
import FirebaseStorage
import SafariServices

class CAdd2ViewController: UIViewController, MultiplePlacesDelegate {

    // Image and Text Stack Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var personalName: UILabel!
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
    // Firebase Auth Current User
    let user = Auth.auth().currentUser?.uid
    
    // Country List Dict
    private var countryList : [Country] = []
    
    // Current Number of Multiple Places
    private var numberOfPlaces: Int = 0
    private var singlePlace : Bool = true
    
    // Current CardID
    var cardID : String = ""
    // Company or Personal Card
    var companyCard2 : Bool = true
    
    // Edit Card
    var editCard2 : Bool = false
    var editCardID2 : String = ""
    var editUserID2 : String = ""
    var editSinglePlace2 : Bool = true
    var editCardSaved2 : Bool = false
    var editCardCountry2 : String = ""
    var editCardCity2 : String = ""
    var editCardStreet2 : String = ""
    var editCardMap2 : String = ""
    var NavBarTitle2 : String = ""
    
    // Picker View
    var pickerView = UIPickerView()
    
    // Previous Screen Info
    var sectorNumber2 : Int = 0
    var logoImage2 : UIImage?
    var personalName2 : String = ""
    var companyName2 : String = ""
    var sector2 : String = ""
    var productType2 : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        selectCountry.inputView = pickerView
        infoButton.isHidden = true
        
        getBasicCard2()

        getCountryList()
        
        if editCard2 == true {
            navigationItem.rightBarButtonItem?.title = "Save"
            navigationItem.title = NavBarTitle2
            cardID = editCardID2
            selectCountry.text = editCardCountry2
            selectCountry.isEnabled = false
            cityName.text = editCardCity2
            streetName.text = editCardStreet2
            googleMapsLink.text = editCardMap2
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        if editCard2 == false {
            
            if segmentedControl.selectedSegmentIndex == 0 {
                segmentedControl.isEnabled = true
                addButton.isHidden = true
                listButton.isHidden = true
                
            } else {
                segmentedControl.isEnabled = false
                addButton.isHidden = false
                listButton.isHidden = false
            }
            
        } else {
            
            if editSinglePlace2 == true {
                segmentedControl.selectedSegmentIndex = 0
                segmentedControl.isEnabled = true
                addButton.isHidden = true
                listButton.isHidden = true
            } else {
                segmentedControl.selectedSegmentIndex = 1
                segmentedControl.isEnabled = false
                addButton.isHidden = false
                listButton.isHidden = false
            }
        }
        
    }
    
    // MARK: - Get Card with Basic info from Step 1
    
    func getBasicCard2() {
        
        if companyCard2 == true {
            personalName.isHidden = true
        } else {
            personalName.text = personalName2
        }
        
        logoImageView.image = logoImage2
        companyName.text = companyName2
        companySector.text = sector2
        companyProductType.text = productType2
    }

// MARK: - Upload Company Logo Image
    
    func uploadImage() {
        
        guard let image = logoImage2, let data = image.jpegData(compressionQuality: 1.0) else {
            popUpWithOk(newTitle: "Error!", newMessage: "Something went wrong. Please Check your Internet connection and try again.")
            return
        }
        
        let imageName = UUID().uuidString
        let imageReference = storage.child(Constants.Firestore.Storage.companyLogo).child(imageName)
    
        imageReference.putData(data, metadata: nil) { mData, error in
            if let error = error {
                self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading Image data to Database. Please Check your Internet connection and try again. \(error.localizedDescription)")
                return
            }
            
            imageReference.downloadURL { [self] url, error in
                
                if let error = error {
                    popUpWithOk(newTitle: "Error!", newMessage: "Error Downloading Image URL from Database. Please Check your Internet connection and try again. \(error.localizedDescription)")
                    return
                }
                
                guard let url = url else {
                    popUpWithOk(newTitle: "Error!", newMessage: "Something went wrong. Please Check your Internet connection and try again.")
                    return
                }
                
                let urlString = url.absoluteString
                
                let dataReference = db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(user!)
                    .document(Constants.Firestore.CollectionName.cardID)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(cardID)
                
                let data = [
                    LogoImage.imageURL: urlString
                ]
                
                dataReference.setData(data, merge: true) { error in
                    
                    if let error = error {
                        popUpWithOk(newTitle: "Error!", newMessage: "Error Downloading Image URL from Database. Please Check your Internet connection and try again. \(error.localizedDescription)")
                        return
                    }
                    
                    UserDefaults.standard.set(cardID, forKey: LogoImage.uid)
                    
                    popUpWithOk(newTitle: "Success", newMessage: "Successfully Uploaded Image to Database.")
                    
                }
            }
        }
    }
    
// MARK: - Get Number of Places delegate
    
    func getNumberOfPlaces(places: Int) {
        numberOfPlaces = places
        
        if numberOfPlaces == 0 && editCard2 == false {
            selectCountry.isEnabled = true
            segmentedControl.isEnabled = true
            infoButton.isHidden = true
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

    
// MARK: - Create Card ID Function
    
    func createCardID() {
        
        if cardID == "" && editCard2 == false {
            let countryCode = Country().getCountryCode(country: selectCountry.text!)
            let companyShortName = companyName.text!.prefix(3).uppercased()
            let randomNumber = Int.random(in: 100...999)
            
            let newCardID = "VBC\(countryCode)S\(sectorNumber2)\(companyShortName)\(randomNumber)"
            cardID = newCardID
        }
    }
    
// MARK: - Create User ID Function
    
    func createUserID() {
        
        if editCard2 == false {
            db.collection(Constants.Firestore.CollectionName.VBC)
                .document(Constants.Firestore.CollectionName.data)
                .collection(Constants.Firestore.CollectionName.users)
                .document(user!)
                .setData(["User ID" : user!], merge: true)
        }
    }
    
// MARK: - Next Button Pressed
    
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
            
            if segmentedControl.selectedSegmentIndex == 0 {
                
                if selectCountry.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || cityName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || streetName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    
                    popUpWithOk(newTitle: "Location fields empty", newMessage: "Please fill all Location fields. Google Maps Link is optional." )
                
                } else {
                    
                    if editCard2 == false {
                        
                        numberOfPlaces = 1
                        singlePlace = true
                        
                        // Uploading Logo image.
                        //uploadImage()
                        
                        // Create CardID
                        createCardID()
                        
                        // Create UserID
                        createUserID()
                        
                        // Adding Data to Firestore Database if user selected Single Place
                        db.collection(Constants.Firestore.CollectionName.VBC)
                            .document(Constants.Firestore.CollectionName.data)
                            .collection(Constants.Firestore.CollectionName.users)
                            .document(user!)
                            .collection(Constants.Firestore.CollectionName.cardID)
                            .document(cardID)
                            .setData(["Personal Name": personalName2,
                                      "Company Name": companyName.text!,
                                      "Sector": companySector.text!,
                                      "ProductType": companyProductType.text!,
                                      "CardID": cardID,
                                      "Country": selectCountry.text!,
                                      "Single Place": true,
                                      "City": cityName.text!,
                                      "Street": streetName.text!,
                                      "gMaps Link": googleMapsLink.text!,
                                      "Company Card": companyCard2,
                                      "User ID": user!,
                                      "Card Saved": false], merge: true) { error in
                                
                                if error != nil {
                                    self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading data to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)")
                                } else {
                                    // Perform Segue to Step 3 for Single Place
                                    self.performSegue(withIdentifier: Constants.Segue.addNew3, sender: self)
                                }
                            }
                    } else {
                        
                        // Updating Edited Data to Firestore Database for Single Place
                        db.collection(Constants.Firestore.CollectionName.VBC)
                            .document(Constants.Firestore.CollectionName.data)
                            .collection(Constants.Firestore.CollectionName.users)
                            .document(user!)
                            .collection(Constants.Firestore.CollectionName.cardID)
                            .document(editCardID2)
                            .setData(["City": cityName.text!,
                                      "Street": streetName.text!,
                                      "gMaps Link": googleMapsLink.text!,
                                      "Single Place": true], merge: true) { error in
                                
                                if error != nil {
                                    self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading edited data to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)")
                                } else {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                    }
                }
                
            } else {
                
                if numberOfPlaces <= 1 {
                    popUpWithOk(newTitle: "You selected Multiple Places", newMessage: "You must add at least two places.")
                } else {
                    
                    if editCard2 == false {
                        // Uploading Logo image.
                        //uploadImage()
                        
                        // Perform Segue to Step 3 for Multiple Places
                        performSegue(withIdentifier: Constants.Segue.addNew3, sender: self)
                    } else {
                        
                        // Updating Edited Data to Firestore Database for Multiple Places
                        db.collection(Constants.Firestore.CollectionName.VBC)
                            .document(Constants.Firestore.CollectionName.data)
                            .collection(Constants.Firestore.CollectionName.users)
                            .document(user!)
                            .collection(Constants.Firestore.CollectionName.cardID)
                            .document(editCardID2)
                            .setData(["Single Place": false], merge: true) { error in
                                
                                if error != nil {
                                    self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading edited data to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)")
                                } else {
                                    // Go Back to Card View Controller with Edited Data
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        
                    }
                }
            }
    }
  
    
// MARK: - Add Location Button Pressed
    
    @IBAction func addLocationPressed(_ sender: UIButton) {
        
        // Adding data to Firestore Database if user selected Multiple Places.
        
        // Checking if Fields are empty.
        if selectCountry.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || cityName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || streetName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            popUpWithOk(newTitle: "Location fields empty", newMessage: "Please fill all Location fields. Google Maps Link is optional." )

        } else {
            
            singlePlace = false
            
            if editCard2 == false {
                
                // Create CardID
                createCardID()
                // Create UserID
                createUserID()
                
                // Adding Basic Data from Step 1
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(user!)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(cardID)
                    .setData(["Personal Name": personalName2,
                              "Company Name": companyName.text!,
                              "Sector": companySector.text!,
                              "ProductType": companyProductType.text!,
                              "Country": selectCountry.text!,
                              "Single Place": singlePlace,
                              "CardID": cardID,
                              "Company Card": companyCard2,
                              "User ID": user!,
                              "Card Saved": false], merge: true)
            }
            
                // Adding Location Data from Step 2
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(user!)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(cardID)
                    .collection(Constants.Firestore.CollectionName.locations)
                    .document("\(cityName.text!) - \(streetName.text!)")
                    .setData(["City": cityName.text!,
                              "Street": streetName.text!,
                              "gMaps Link": googleMapsLink.text!], merge: true) { error in
                        
                        if error != nil {
                            self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading data to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)")
                        } else {
                            self.popUpWithOk(newTitle: "Location successfully added", newMessage: "You can see list of your locations by pressing List button.")
                            
                            self.listButton.isHidden = false
                            self.infoButton.isHidden = false
                            self.selectCountry.isEnabled = false
                            self.segmentedControl.isEnabled = false
                            self.cityName.text = ""
                            self.streetName.text = ""
                            self.googleMapsLink.text = ""
                            self.numberOfPlaces += 1
                        }
                    }
        }
    }
    
// MARK: - Edit or New Functions for Card ID and User ID
    
    func editOrNewUserID() -> String {
        if editCard2 == true {
            return editUserID2
        } else {
            return user!
        }
    }
    
    func editOrNewCardID() -> String {
        if editCard2 == true {
            return editCardID2
        } else {
            return cardID
        }
    }
    
// MARK: - List Button Pressed
    
    @IBAction func listButtonPressed(_ sender: UIButton) {
        // Perform Segue to view List of Locations
        self.performSegue(withIdentifier: Constants.Segue.newLocationsList, sender: self)
    }

// MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.newLocationsList {
            
            let destinationVC = segue.destination as! AddListViewController
            
            if editCard2 == false {
                destinationVC.cardID = cardID
            } else {
                destinationVC.cardID = editCardID2
            }
            
            destinationVC.delegate = self
            destinationVC.delegateEdit = self
    
        }
        
        if segue.identifier == Constants.Segue.addNew3 {
            
            let destinationVC = segue.destination as! CAdd3ViewController
            
            // Basic Info from 1st Step
            destinationVC.logoImage3 = logoImage2
            destinationVC.companyName3 = companyName2
            destinationVC.productType3 = productType2
            destinationVC.sector3 = sector2
            destinationVC.companyCard3 = companyCard2
            
            if companyCard2 == false {
                destinationVC.personalName3 = personalName2
            }
            
            // Location Info from 2nd Step
            destinationVC.selectedNewCountry = selectCountry.text!
            destinationVC.currentCardID = cardID
            destinationVC.numberOfPlaces = numberOfPlaces
            destinationVC.singlePlace = singlePlace
           
        }
        
    }
    
// MARK: - Info Button Pressed
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        
        popUpWithOk(newTitle: "You want to change a Country?", newMessage: "To do it, you first need to delete all your Places from the List.")
    }

// MARK: - Segment Control
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        // If Segment is 1, you can add Multiple places - If segment is 0, you can add only Single place
        if segmentedControl.selectedSegmentIndex == 1 {
            addButton.isHidden = false
            listButton.isHidden = false
            
            if editCard2 == true {
                editSinglePlace2 = false
                
                if numberOfPlaces <= 1 {
                    cityName.text = editCardCity2
                    streetName.text = editCardStreet2
                } else {
                    cityName.text = ""
                    streetName.text = ""
                }
            }
        } else {
            addButton.isHidden = true
            listButton.isHidden = true
            
            if editCard2 == true {
                editSinglePlace2 = true
                cityName.text = editCardCity2
                streetName.text = editCardStreet2
            }
        }
    }

// MARK: - Google Maps Icon Pressed
    
    @IBAction func gMapsIconPressed(_ sender: UITapGestureRecognizer) {
        //Open Safari and Go to Google Maps Link.
        guard let url = URL(string: "https://www.google.com/maps") else { return }
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }

    
// MARK: - Get Contries List Function
        
        func getCountryList() {
            
            db.collection(Constants.Firestore.CollectionName.countries).getDocuments { snapshot, error in
                
                if let e = error {
                    self.popUpWithOk(newTitle: "Error!", newMessage: "Error Getting data from Database. Please Check your Internet connection and try again. \(e.localizedDescription)")
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
            infoButton.isHidden = true
            return countryList[row].name
        }
         else {
            return "Error adding Title for Row."
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if selectCountry.isEditing {
            selectCountry.text = countryList[row].name
        }
         else {
             popUpWithOk(newTitle: "Error!", newMessage: "There was an Error when selected row. Please try again.")
        }
    }
}

extension CAdd2ViewController: EditSelectedLocation {
    
    func getEditLocation(city: String, street: String, map: String) {
        
        cityName.text = city
        streetName.text = street
        
        if map != "" {
            googleMapsLink.text = map
        }
        
    }
    
    
    
}
