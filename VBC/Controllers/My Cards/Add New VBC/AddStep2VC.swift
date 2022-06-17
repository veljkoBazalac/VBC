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

class AddStep2VC: UIViewController {
    
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
    @IBOutlet weak var aMapsLink: UITextField!
    
    // Add Location Button Outlet
    @IBOutlet weak var addButton: UIButton!
    // Show Location Button Outlet
    @IBOutlet weak var listButton: UIButton!
    // Google Maps Link Info
    @IBOutlet weak var gMapsInfo: UIButton!
    // Apple Maps Link Info
    @IBOutlet weak var aMapsInfo: UIButton!
    // -------------------- //
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Storage
    let storage = Storage.storage().reference()
    // Firebase Auth Current User
    let user = Auth.auth().currentUser?.uid
    
    // PopUp with TableView and Blur
    private var popUpTableView : PopUpTableView!
    // Row Deleted in PopUp TableView
    private var rowDeleted = false
    // Row Edited in PopUp TableView
    private var rowEdited = false
    // PopUp with Spinner
    private var popUpSpinner : PopUpSpinner!
    
    // Country List Dict
    private var countryList : [Country] = []
    // List of Locations
    private var locationList : [Location] = []
    // Single or Multiple Locations
    var singlePlace : Bool = true
    // Current CardID
    var cardID : String = ""
    // Company or Personal Card
    var companyCard2 : Bool = true
    private var locationListPressed = false
    
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
    var locationForEdit : String = ""
    var onlyCityName : String = ""
    var onlyStreetName : String = ""
    var onlyMapLink : String = ""
    
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
        
        setPlaceholders()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        selectCountry.inputView = pickerView
  
        getBasicCard2()
        getCountryList()
        
        if editCard2 == true {
            navigationItem.rightBarButtonItem?.title = "Save"
            navigationItem.hidesBackButton = true
            navigationItem.title = NavBarTitle2
            cardID = editCardID2
            selectCountry.text = editCardCountry2
            selectCountry.isEnabled = false
            getLocations()
        }
    }
    
    private func setPlaceholders() {
        selectCountry.attributedPlaceholder = NSAttributedString(
            string: "Select Country",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        cityName.attributedPlaceholder = NSAttributedString(
            string: "Enter City Name...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        streetName.attributedPlaceholder = NSAttributedString(
            string: "Enter Street Name and Number...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        googleMapsLink.attributedPlaceholder = NSAttributedString(
            string: "Paste Google Maps Link...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        aMapsLink.attributedPlaceholder = NSAttributedString(
            string: "Paste Apple Maps Link...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }
    
    // MARK: - Prepare for Segue
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.addNew3 {
            
            let destinationVC = segue.destination as! AddStep3VC
            
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
            destinationVC.selectedCountry = selectCountry.text!
            destinationVC.cardID = cardID
            destinationVC.singlePlace = singlePlace
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
        self.view.endEditing(true)
        if selectCountry.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || locationList.count == 0 {
            PopUp().popUpWithOk(newTitle: "Location missing",
                                newMessage: "Please select Country and enter City name. Press + Button to add location.",
                                vc: self )
        } else {
            
            if editCard2 == false {
                // User Create New Card.
                // PopUp with spinner.
                startSpinner()
                // Create CardID
                createCardID()
                // Create UserID
                createUserID()
                if logoImageView.image != nil {
                // Uploading Card with Logo Image from Step 1 to Firestore.
                uploadImage()
                } else {
                // Uploading Data to Firestore without Logo Image.
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(user!)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(cardID)
                    .setData([Constants.Firestore.Key.personalName : personalName2,
                              Constants.Firestore.Key.companyName : companyName.text!,
                              Constants.Firestore.Key.sector : companySector.text!,
                              Constants.Firestore.Key.type: companyProductType.text!,
                              Constants.Firestore.Key.cardID : cardID,
                              Constants.Firestore.Key.country : selectCountry.text!,
                              Constants.Firestore.Key.singlePlace : singlePlace,
                              Constants.Firestore.Key.companyCard : companyCard2,
                              Constants.Firestore.Key.userID : user!,
                              Constants.Firestore.Key.cardSaved : false,
                              Constants.Firestore.Key.imageURL : ""], merge: true) { error in
                        
                        if error != nil {
                            PopUp().popUpWithOk(newTitle: "Error!",
                                                newMessage: "Error Uploading data to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)",
                                                vc: self)
                        } else {
                            self.stopSpinner()
                            
                            if self.popUpSpinner.spinner.isAnimating == false {
                                // Perform Segue to Step 3
                                self.performSegue(withIdentifier: Constants.Segue.addNew3, sender: self)
                            }
                        }
                    }
                }
            } else {
                // User Edit existing Card.
                // PopUp with Spinner.
                startSpinner()
                // Updating Edited Data to Firestore Database
                self.db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(self.user!)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(self.cardID)
                    .setData(["Card Edited" : false,
                              Constants.Firestore.Key.singlePlace : self.singlePlace], merge: true) { err in
                        
                        if let e = err {
                            PopUp().popUpWithOk(newTitle: "Card Edit Error",
                                                newMessage: "Please check your internet connection and try again. \(e)",
                                                vc: self)
                            return
                        } else {
                            
                            self.db.collection(Constants.Firestore.CollectionName.VBC)
                                .document(Constants.Firestore.CollectionName.data)
                                .collection(Constants.Firestore.CollectionName.users)
                                .document(self.user!)
                                .collection(Constants.Firestore.CollectionName.cardID)
                                .document(self.cardID)
                                .setData(["Card Edited" : true], merge: true) { err in
                                    
                                    if let e = err {
                                        PopUp().popUpWithOk(newTitle: "Card Edit Error",
                                                            newMessage: "Please check your internet connection and try again. \(e)",
                                                            vc: self)
                                        return
                                    } else {
                                        self.stopSpinner()
                                        
                                        if self.popUpSpinner.spinner.isAnimating == false {
                                            // Go back to CardVC with Edited Card.
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                }
                        }
                    }
            }
        }
    }
    
// MARK: - Add Location Button Pressed
    
    @IBAction func addLocationPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        // Checking if Fields are empty.
        if selectCountry.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || cityName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            PopUp().popUpWithOk(newTitle: "Location missing",
                                newMessage: "Please select Country and enter City name. Press + Button to add location.",
                                vc: self )
        } else {
            
            if editCard2 == false {
                // Create CardID
                createCardID()
                // Create UserID
                createUserID()
            }
            // Uploading Location Data from Step 2
            db.collection(Constants.Firestore.CollectionName.VBC)
                .document(Constants.Firestore.CollectionName.data)
                .collection(Constants.Firestore.CollectionName.users)
                .document(user!)
                .collection(Constants.Firestore.CollectionName.cardID)
                .document(cardID)
                .collection(Constants.Firestore.CollectionName.locations)
                .document("\(cityName.text!) - \(streetName.text!)")
                .setData([Constants.Firestore.Key.city : cityName.text!,
                          Constants.Firestore.Key.street : streetName.text!,
                          Constants.Firestore.Key.gMaps : googleMapsLink.text!,
                          Constants.Firestore.Key.aMaps : aMapsLink.text!], merge: true) { [self] err in
                    
                    if let e = err {
                        PopUp().popUpWithOk(newTitle: "Error!",
                                            newMessage: "Error Uploading data to Database. Please Check your Internet connection and try again. \(e.localizedDescription)",
                                            vc: self)
                    } else {
                        blinkButton(buttonName: self.listButton)
                        if rowEdited == true {
                            // If this is New Edited Location, move data from Old to New location.
                            moveDataToNewLocation(city: cityName.text!,
                                                       street: streetName.text!)
                        }
                        
                        rowEdited = false
                        selectCountry.isEnabled = false
                        cityName.text?.removeAll()
                        streetName.text?.removeAll()
                        googleMapsLink.text?.removeAll()
                        aMapsLink.text?.removeAll()
                        getLocations()
                    }
                }
        }
    }
    
// MARK: - List Button Pressed
    
    @IBAction func listButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        locationListPressed = true
        // Show PopUp with TableView and Blur
        if selectCountry.text != nil {
            DispatchQueue.main.async {
                self.rowDeleted = false
                self.getLocations()
            }
        } else {
            PopUp().popUpWithOk(newTitle: "Location missing",
                                newMessage: "Please select Country and enter City name. Press + Button to add location.",
                                vc: self )
        }
    }

// MARK: - Google Maps Icon Pressed
    
    @IBAction func gMapsButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let url = URL(string: "https://www.google.com/maps") else { return }
        
        DispatchQueue.main.async {
            // Open Google Maps App if installed
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                self.gMapsInfo.setImage(UIImage.init(systemName: "doc.on.doc"), for: .normal)
            } else {
                //Open Safari and Go to Google Maps Link.
                let svc = SFSafariViewController(url: url)
                self.present(svc, animated: true, completion: nil)
                self.gMapsInfo.setImage(UIImage.init(systemName: "doc.on.doc"), for: .normal)
            }
        }
    }
    
    // MARK: - Apple Maps Button Pressed
    @IBAction func aMapsButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let url = URL(string: "map://") else { return }
        
        DispatchQueue.main.async {
            // Open Google Maps App if installed
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                self.aMapsInfo.setImage(UIImage.init(systemName: "doc.on.doc"), for: .normal)
            } else {
                //Open Safari and Go to Google Maps Link.
                self.aMapsInfo.setImage(UIImage.init(systemName: "doc.on.doc"), for: .normal)
                let svc = SFSafariViewController(url: url)
                self.present(svc, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Google Maps Info Pressed
    @IBAction func gMapsInfoPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if gMapsInfo.imageView?.image == UIImage.init(systemName: "questionmark.circle") {
            PopUp().popUpWithOk(newTitle: "How to Get Link?",
                                newMessage: "1. Press on Google Maps Icon\n2. Find Your Location\n3. Click on Share\n4. Click on Copy Link",
                                vc: self)
        } else {
            googleMapsLink.text = UIPasteboard.general.string
            self.gMapsInfo.setImage(UIImage.init(systemName: "questionmark.circle"), for: .normal)
        }
    }
    
    // MARK: - Apple Maps Info Pressed
    @IBAction func aMapsInfoPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if aMapsInfo.imageView?.image == UIImage.init(systemName: "questionmark.circle") {
            PopUp().popUpWithOk(newTitle: "How to Get Link?",
                                newMessage: "1. Press on Apple Maps Icon\n2. Find Your Location\n3. Click on Share\n4. Click on Copy Link",
                                vc: self)
        } else {
            aMapsLink.text = UIPasteboard.general.string
            self.aMapsInfo.setImage(UIImage.init(systemName: "questionmark.circle"), for: .normal)
        }
    }
    
    // MARK: - PopUp with TableView Back Button Pressed
    @objc func popUpBackButtonPressed() {
        dismissPopUpWithTableView()
        rowDeleted = false
        rowEdited = false
    }
    
}//

// MARK: - Firebase Functions
        
extension AddStep2VC {
    
    // MARK: - Upload Company Logo Image to Firebase Storage
    func uploadImage() {
        // User Selected Image in Step 1.
        guard let image = logoImage2, let data = image.jpegData(compressionQuality: 0.2) else {
            PopUp().popUpWithOk(newTitle: "Error!",
                                newMessage: "Something went wrong. Please Check your Internet connection and try again.",
                                vc: self)
            return
        }
        
        let imageName = "Img.\(cardID)"
        let imageReference = storage
            .child(Constants.Firestore.Storage.logoImage)
            .child(user!)
            .child(imageName)
        
        imageReference.putData(data, metadata: nil) { mData, error in
            if let e = error {
                PopUp().popUpWithOk(newTitle: "Error!",
                                    newMessage: "Error Uploading Image data to Storage. Please Check your Internet connection and try again. \(e.localizedDescription)",
                                    vc: self)
                return
            }
            
            imageReference.downloadURL { [self] url, error in
                
                if let e = error {
                    PopUp().popUpWithOk(newTitle: "Error!",
                                        newMessage: "Error Downloading Image URL from Database. Please Check your Internet connection and try again. \(e.localizedDescription)",
                                        vc: self)
                    return
                }
                
                imageReference.downloadURL { [self] url, error in
                    if let e = error {
                        PopUp().popUpWithOk(newTitle: "Error!",
                                            newMessage: "Error Downloading URL. \(e.localizedDescription)",
                                            vc: self)
                    } else {
                        
                        guard let url = url else {
                            PopUp().popUpWithOk(newTitle: "Error!",
                                                newMessage: "Something went wrong. Please Check your Internet connection and try again.",
                                                vc: self)
                            return
                        }
                        
                        let urlString = url.absoluteString
                        
                        db.collection(Constants.Firestore.CollectionName.VBC)
                            .document(Constants.Firestore.CollectionName.data)
                            .collection(Constants.Firestore.CollectionName.users)
                            .document(user!)
                            .collection(Constants.Firestore.CollectionName.cardID)
                            .document(cardID)
                            .setData([Constants.Firestore.Key.personalName : personalName2,
                                      Constants.Firestore.Key.companyName : companyName.text!,
                                      Constants.Firestore.Key.sector : companySector.text!,
                                      Constants.Firestore.Key.type: companyProductType.text!,
                                      Constants.Firestore.Key.cardID : cardID,
                                      Constants.Firestore.Key.country : selectCountry.text!,
                                      Constants.Firestore.Key.singlePlace : singlePlace,
                                      Constants.Firestore.Key.companyCard : companyCard2,
                                      Constants.Firestore.Key.userID : user!,
                                      Constants.Firestore.Key.cardSaved : false,
                                      Constants.Firestore.Key.imageURL : "\(urlString)"], merge: true) { error in
                                
                                if let error = error {
                                    PopUp().popUpWithOk(newTitle: "Error!",
                                                        newMessage: "Error Uploading Data with Image URL to Firestore. Please Check your Internet connection and try again. \(error.localizedDescription)",
                                                        vc: self)
                                    return
                                } else {
                                    self.stopSpinner()
                                    
                                    if self.editCard2 == false {
                                        if self.popUpSpinner.spinner.isAnimating == false {
                                            self.performSegue(withIdentifier: Constants.Segue.addNew3, sender: self)
                                        }
                                    } else {
                                        if self.popUpSpinner.spinner.isAnimating == false {
                                            // Go back to CardVC with Edited Card.
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                }
                            }
                        
                    }
                }
            }
        }
        
        
    }//
    
    // MARK: - Get Contries List from Firestore
    func getCountryList() {
        
        db.collection(Constants.Firestore.CollectionName.countries).getDocuments { snapshot, error in
            
            if let e = error {
                PopUp().popUpWithOk(newTitle: "Error!",
                                    newMessage: "Error Getting data from Database. Please Check your Internet connection and try again. \(e.localizedDescription)",
                                    vc: self)
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
    
    // MARK: - Get Locations from Firestore
    func getLocations() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.locations)
            .getDocuments { snapshot, error in
                
                if let e = error {
                    print ("Error getting Multiple Places List. \(e)")
                } else {
                    
                    if let snapshotDocuments = snapshot?.documents {
                        
                        self.locationList.removeAll()
                        
                        for documents in snapshotDocuments {
                            
                            let data = documents.data()
                            
                            if let cityName = data[Constants.Firestore.Key.city] as? String {
                                if let cityStreet = data[Constants.Firestore.Key.street] as? String {
                                    if let gMap = data[Constants.Firestore.Key.gMaps] as? String {
                                        if let aMap = data[Constants.Firestore.Key.aMaps] as? String {
                                            
                                            let places = Location(city: cityName, street: cityStreet, gMapsLink: gMap, aMapsLink: aMap)
                                            
                                            self.locationList.append(places)
                                        }
                                    }
                                }
                            }
                        }
                        if self.locationListPressed == true {
                            DispatchQueue.main.async {
                                if self.rowDeleted == false {
                                    self.popUpWithTableView(rows: self.locationList.count, type: "Location")
                                } else {
                                    self.popUpTableView.rowDeleted(numberOfRows: self.locationList.count)
                                }
                            }
                        }
                    }
                }
            }
    }

    
}

// MARK: - UIPickerView for Country
extension AddStep2VC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        }
        else {
            PopUp().popUpWithOk(newTitle: "Error!",
                                newMessage: "There was an Error when selected row. Please try again.",
                                vc: self)
        }
    }
}

// MARK: - Edit Location Function
extension AddStep2VC {
    
    func moveDataToNewLocation(city: String, street: String) {
        // TODO: Dodaj spiner
        let newLocation = "\(city) - \(street)"
        
        DispatchQueue.main.async { [self] in
            // Get Social Media for Old Location
            self.db.collection(Constants.Firestore.CollectionName.VBC)
                .document(Constants.Firestore.CollectionName.data)
                .collection(Constants.Firestore.CollectionName.users)
                .document(self.user!)
                .collection(Constants.Firestore.CollectionName.cardID)
                .document(self.cardID)
                .collection(Constants.Firestore.CollectionName.locations)
                .document(self.locationForEdit)
                .collection(Constants.Firestore.CollectionName.social)
                .getDocuments { snapshot, err in
                    if let e = err {
                        print("Error Getting Social Media. \(e)")
                    } else {
                        
                        if let snapshotDocuments = snapshot?.documents {
                            
                            for document in snapshotDocuments {
                                
                                let data = document.data()
                                
                                if let socialName = data[Constants.Firestore.Key.name] as? String {
                                    if let socialLink = data[Constants.Firestore.Key.link] as? String {
                                        // Move Social Media Data to New Location
                                        self.db.collection(Constants.Firestore.CollectionName.VBC)
                                            .document(Constants.Firestore.CollectionName.data)
                                            .collection(Constants.Firestore.CollectionName.users)
                                            .document(self.user!)
                                            .collection(Constants.Firestore.CollectionName.cardID)
                                            .document(self.cardID)
                                            .collection(Constants.Firestore.CollectionName.locations)
                                            .document(newLocation)
                                            .collection(Constants.Firestore.CollectionName.social)
                                            .document(socialName)
                                            .setData([
                                                Constants.Firestore.Key.name : socialName,
                                                Constants.Firestore.Key.link : socialLink
                                            ],merge: true) { error in
                                                if let e = error {
                                                    PopUp().popUpWithOk(newTitle: "Error",
                                                                        newMessage: "Error Moving Data to New Location. \(e.localizedDescription)",
                                                                        vc: self)
                                                } else {
                                                    
                                                    if self.locationForEdit != newLocation {
                                                        // Delete Social Media Data from Old Location
                                                        self.db.collection(Constants.Firestore.CollectionName.VBC)
                                                            .document(Constants.Firestore.CollectionName.data)
                                                            .collection(Constants.Firestore.CollectionName.users)
                                                            .document(self.user!)
                                                            .collection(Constants.Firestore.CollectionName.cardID)
                                                            .document(self.cardID)
                                                            .collection(Constants.Firestore.CollectionName.locations)
                                                            .document(self.locationForEdit)
                                                            .collection(Constants.Firestore.CollectionName.social)
                                                            .document(socialName)
                                                            .delete() { err in
                                                                if let e = err {
                                                                    PopUp().popUpWithOk(newTitle: "Error",
                                                                                        newMessage: "Error Deleting Social Media from Old Location. \(e.localizedDescription)",
                                                                                        vc: self)
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
            
            // Get Contact Data for Old Location
            db.collection(Constants.Firestore.CollectionName.VBC)
                .document(Constants.Firestore.CollectionName.data)
                .collection(Constants.Firestore.CollectionName.users)
                .document(user!)
                .collection(Constants.Firestore.CollectionName.cardID)
                .document(cardID)
                .collection(Constants.Firestore.CollectionName.locations)
                .document(locationForEdit)
                .getDocument { document, err in
                    if let e = err {
                        print("Error Getting Data for Edit Location.\(e)")
                    } else {
                        
                        if document != nil && document!.exists {
                            
                            let data = document?.data()
                            
                            let socialAdded = data![Constants.Firestore.Key.socialAdded] as? Bool
                            let email1 = data![Constants.Firestore.Key.email1] as? String
                            let email2 = data![Constants.Firestore.Key.email2] as? String
                            let phone1 = data![Constants.Firestore.Key.phone1] as? String
                            let phone1Code = data![Constants.Firestore.Key.phone1code] as? String
                            let phone2 = data![Constants.Firestore.Key.phone2] as? String
                            let phone2Code = data![Constants.Firestore.Key.phone2code] as? String
                            let phone3 = data![Constants.Firestore.Key.phone3] as? String
                            let phone3Code = data![Constants.Firestore.Key.phone3code] as? String
                            let web1 = data![Constants.Firestore.Key.web1] as? String
                            let web2 = data![Constants.Firestore.Key.web2] as? String
                            // Move Contact Data to New Location
                            self.db.collection(Constants.Firestore.CollectionName.VBC)
                                .document(Constants.Firestore.CollectionName.data)
                                .collection(Constants.Firestore.CollectionName.users)
                                .document(self.user!)
                                .collection(Constants.Firestore.CollectionName.cardID)
                                .document(self.cardID)
                                .collection(Constants.Firestore.CollectionName.locations)
                                .document(newLocation)
                                .setData([
                                    Constants.Firestore.Key.socialAdded : socialAdded ?? "",
                                    Constants.Firestore.Key.email1 : email1 ?? "",
                                    Constants.Firestore.Key.email2 : email2 ?? "",
                                    Constants.Firestore.Key.phone1 : phone1 ?? "",
                                    Constants.Firestore.Key.phone1code : phone1Code ?? "",
                                    Constants.Firestore.Key.phone2 : phone2 ?? "",
                                    Constants.Firestore.Key.phone2code : phone2Code ?? "",
                                    Constants.Firestore.Key.phone3 : phone3 ?? "",
                                    Constants.Firestore.Key.phone3code : phone3Code ?? "",
                                    Constants.Firestore.Key.web1 : web1 ?? "",
                                    Constants.Firestore.Key.web2 : web2 ?? ""
                                ],merge: true) { err in
                                    if let e = err {
                                        PopUp().popUpWithOk(newTitle: "Error",
                                                            newMessage: "Error Moving Contact Data to New Location. \(e.localizedDescription)",
                                                            vc: self)
                                    } else {
                                        
                                        if self.locationForEdit != newLocation {
                                            // Delete Old Location and All Data
                                            self.db.collection(Constants.Firestore.CollectionName.VBC)
                                                .document(Constants.Firestore.CollectionName.data)
                                                .collection(Constants.Firestore.CollectionName.users)
                                                .document(self.user!)
                                                .collection(Constants.Firestore.CollectionName.cardID)
                                                .document(self.cardID)
                                                .collection(Constants.Firestore.CollectionName.locations)
                                                .document(self.locationForEdit)
                                                .delete() { err in
                                                    if let e = err {
                                                        PopUp().popUpWithOk(newTitle: "Error",
                                                                            newMessage: "Error Deleting Contact Data from Old Location. \(e.localizedDescription)",
                                                                            vc: self)
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

// MARK: - Pop Ups and other UI Settings
extension AddStep2VC {
    
    //  Blink Button Function
    func blinkButton(buttonName: UIButton) {
        buttonName.tintColor = .green
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            buttonName.tintColor = UIColor(named: "Reverse Background Color")
        }
    }
    
    // Pop Up With Table View and Blur
    func popUpWithTableView(rows: Int, type: String) {
        
        self.popUpTableView = PopUpTableView(frame: self.view.frame)
        self.popUpTableView.popUpWithTableView(vc: self,
                                               rows: rows,
                                               type: type,
                                               nibName: Constants.Nib.locationCell,
                                               cellIdentifier: Constants.Cell.locationCell)
        self.popUpTableView.backButton.addTarget(self, action: #selector(self.popUpBackButtonPressed), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.popUpTableView)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func dismissPopUpWithTableView() {
        popUpTableView.animateOut(forView: popUpTableView.popUpView, mainView: popUpTableView)
        popUpTableView.animateOut(forView: popUpTableView.blurEffectView, mainView: popUpTableView)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        locationListPressed = false
    }
    
    func startSpinner() {
        self.popUpSpinner = PopUpSpinner(frame: self.view.frame)
        self.popUpSpinner.spinnerWithBlur()
        self.view.addSubview(self.popUpSpinner)
    }
    
    func stopSpinner() {
        self.popUpSpinner.animateOut(forView: popUpSpinner.popUpView, mainView: popUpSpinner)
    }
}

// MARK: - Table View

extension AddStep2VC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.locationCell, for: indexPath) as! LocationCell
        
        let locationRow = locationList[indexPath.row]
        
        cell.configure(city: locationRow.city,
                       street: locationRow.street,
                       gMap: locationRow.gMapsLink,
                       aMap: locationRow.aMapsLink)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedLocation = "\(locationList[indexPath.row].city) - \(locationList[indexPath.row].street)"
        
        let actionSheetController: UIAlertController = UIAlertController(title: selectedLocation, message: nil, preferredStyle: .actionSheet)
        
        // Edit Location Action
        let editLocation: UIAlertAction = UIAlertAction(title: "Edit", style: .default) { [self] action -> Void in
            locationForEdit = selectedLocation
            rowEdited = true
            
            cityName.text = locationList[indexPath.row].city
            streetName.text = locationList[indexPath.row].street
            googleMapsLink.text = locationList[indexPath.row].gMapsLink
            aMapsLink.text = locationList[indexPath.row].aMapsLink
            
            dismissPopUpWithTableView()
        }
        // Delete Location Action
        let deleteLocation: UIAlertAction = UIAlertAction(title: "Delete", style: .destructive) { [self] action -> Void in
            
            DispatchQueue.main.async {
                // Get Location Social Media Data
                self.db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(self.user!)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(self.cardID)
                    .collection(Constants.Firestore.CollectionName.locations)
                    .document(selectedLocation)
                    .collection(Constants.Firestore.CollectionName.social)
                    .getDocuments { snapshot, err in
                        if let e = err {
                            PopUp().popUpWithOk(newTitle: "Error", newMessage: "\(e)", vc: self)
                        } else {
                            
                            if let snapshotDocuments = snapshot?.documents {
                                
                                for documents in snapshotDocuments {
                                    
                                    let data = documents.data()
                                    // Delete Social Media Data for Location
                                    if let socialName = data[Constants.Firestore.Key.name] as? String {
                                        self.db.collection(Constants.Firestore.CollectionName.VBC)
                                            .document(Constants.Firestore.CollectionName.data)
                                            .collection(Constants.Firestore.CollectionName.users)
                                            .document(self.user!)
                                            .collection(Constants.Firestore.CollectionName.cardID)
                                            .document(self.cardID)
                                            .collection(Constants.Firestore.CollectionName.locations)
                                            .document(selectedLocation)
                                            .collection(Constants.Firestore.CollectionName.social)
                                            .document(socialName)
                                            .delete() { err in
                                                if let e = err {
                                                    PopUp().popUpWithOk(newTitle: "Error",
                                                                        newMessage: "Error Deleting Location Social Media Data. \(e.localizedDescription)",
                                                                        vc: self)
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
            }
            // Delete Location
            db.collection(Constants.Firestore.CollectionName.VBC)
                .document(Constants.Firestore.CollectionName.data)
                .collection(Constants.Firestore.CollectionName.users)
                .document(user!)
                .collection(Constants.Firestore.CollectionName.cardID)
                .document(cardID)
                .collection(Constants.Firestore.CollectionName.locations)
                .document(selectedLocation)
                .delete()
            
            
            DispatchQueue.main.async {
                self.rowDeleted = true
                self.locationList.removeAll()
                self.getLocations()
            }
        }
        // Cancel Action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        
        actionSheetController.addAction(editLocation)
        actionSheetController.addAction(deleteLocation)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
}
