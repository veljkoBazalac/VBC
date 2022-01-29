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
    
    // Current CardID
    var cardID : String = ""
    
    // Edit Card
    var editCard2 : Bool = false
    var editCardID2 : String = ""
    var editUserID2 : String = ""
    var editSinglePlace2 : Bool = true
    var editCardCountry2 : String = ""
    
    // Picker View
    var pickerView = UIPickerView()
    
    // Previous Screen Info
    var sectorNumber : Int?
    var logoImage : UIImage?
    var newCompanyName : String?
    var newSector : String?
    var newProductType : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customBackButton()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        selectCountry.inputView = pickerView
        infoButton.isHidden = true
        
        logoImageView.image = logoImage
        companyName.text = newCompanyName
        companySector.text = newSector
        companyProductType.text = newProductType

        getCountryList()
        
        if editCard2 == true {
            selectCountry.text = editCardCountry2
            selectCountry.isEnabled = false
            cardID = editCardID2
            getCardForEdit2SP()
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

// MARK: - Upload Company Logo Image
    
    func uploadImage() {
        
        guard let image = logoImage, let data = image.jpegData(compressionQuality: 1.0) else {
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
                    self.popUpWithOk(newTitle: "Error!", newMessage: "Error Downloading Image URL from Database. Please Check your Internet connection and try again. \(error.localizedDescription)")
                    return
                }
                
                guard let url = url else {
                    self.popUpWithOk(newTitle: "Error!", newMessage: "Something went wrong. Please Check your Internet connection and try again.")
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
                        self.popUpWithOk(newTitle: "Error!", newMessage: "Error Downloading Image URL from Database. Please Check your Internet connection and try again. \(error.localizedDescription)")
                        return
                    }
                    
                    UserDefaults.standard.set(cardID, forKey: LogoImage.uid)
                    
                    popUpWithOk(newTitle: "Success", newMessage: "Successfully Uploaded Image to Database.")
                    
                }
            }
        }
    }
    
// MARK: - NavBar Back Button
    
    func customBackButton() {
        
        let customBackButton = UIBarButtonItem(image: UIImage(named: "backArrow") , style: .plain, target: self, action: #selector(backAction(sender:)))
            customBackButton.imageInsets = UIEdgeInsets(top: 2, left: -8, bottom: 0, right: 0)
            navigationItem.leftBarButtonItem = customBackButton
    }
    
    
    @objc func backAction(sender: UIBarButtonItem) {
        // Pop Up with Yes and No
        let alert = UIAlertController(title: "Going Back?", message: "If you Go Back all your data will be lost. If you made a mistake previously, you can edit your data later!", preferredStyle: .alert)
        let actionCANCEL = UIAlertAction(title: "Cancel", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        let actionGOBACK = UIAlertAction(title: "GO BACK", style: .destructive) { [self] action in
            navigationController?.popViewController(animated: true)
        }

        alert.addAction(actionGOBACK)
        alert.addAction(actionCANCEL)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
// MARK: - Get Number of Places delegate
    
    func getNumberOfPlaces(places: Int) {
        numberOfPlaces = places
        
        if numberOfPlaces == 0 {
            selectCountry.isEnabled = true
            segmentedControl.isEnabled = true
            listButton.isHidden = true
            infoButton.isHidden = true
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
    
// MARK: - Create Card ID Funcion
    
    func createCardID() {
        
        if cardID == "" && editCard2 == false {
            let countryCode = Country().getCountryCode(country: selectCountry.text!)
            let companyShortName = companyName.text!.prefix(3).uppercased()
            let randomNumber = Int.random(in: 100...999)
            
            let newCardID = "VBC\(countryCode)S\(sectorNumber!)\(companyShortName)\(randomNumber)"
            cardID = newCardID
        }
    }
    
    func createUserID() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .setData(["User ID" : user!], merge: true)
        
    }
    
// MARK: - Next Button Pressed
    
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
            
            if segmentedControl.selectedSegmentIndex == 0 {
                
                if selectCountry.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || cityName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || streetName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    
                    popUpWithOk(newTitle: "Location fields empty", newMessage: "Please fill all Location fields. Google Maps Link is optional." )
                
                } else {
                    
                    
                    numberOfPlaces = 1
                    
                    // Uploading Logo image.
                    //uploadImage()
                    
                    
//                    if editCard2 == false {
                        // Create CardID
                        createCardID()
                        
                        // Create UserID
                        createUserID()
//                    }
                    
                    // Adding Data to Firestore Database if user selected Single Place
                    db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.data)
                        .collection(Constants.Firestore.CollectionName.users)
                        .document(user!)
                        .collection(Constants.Firestore.CollectionName.cardID)
                        .document(cardID)
                        .setData(["Name": companyName.text!, "Sector": companySector.text!, "ProductType": companyProductType.text!, "CardID": cardID, "Country": selectCountry.text!, "Single Place": true, "City": cityName.text!, "Street": streetName.text!, "gMaps Link": googleMapsLink.text!, "Company Card": true, "User ID": user!], merge: true) { error in
                        
                        if error != nil {
                            self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading data to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)")
                            print("Error Uploading data to Firestore. \(error!)")
                        } else {
                            self.performSegue(withIdentifier: Constants.Segue.cAdd3, sender: self)
                        }
                    }
                }
                
            } else {
                
                if numberOfPlaces <= 1 {
                    popUpWithOk(newTitle: "You selected Multiple Places", newMessage: "You must add at least two places.")
                } else {
                    // Uploading Logo image.
                    //uploadImage()
                    
                    performSegue(withIdentifier: Constants.Segue.cAdd3, sender: self)
                }
                
            }
            
    }
  
    
// MARK: - Add Location Button Pressed
    
    @IBAction func addLocationPressed(_ sender: UIButton) {
        
        // Adding data to Firestore Database if user selected Multiple Places.
        if selectCountry.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || cityName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || streetName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            //Checking if Fields are empty.
            popUpWithOk(newTitle: "Location fields empty", newMessage: "Please fill all Location fields. Google Maps Link is optional." )

        } else {
            
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
                .setData(["Name": companyName.text!, "Sector": companySector.text!, "ProductType": companyProductType.text!, "Country": selectCountry.text!, "Single Place": false, "CardID": cardID, "Company Card": true, "User ID": user!], merge: true)
            
            // Adding Location Data from Step 2
            db.collection(Constants.Firestore.CollectionName.VBC)
                .document(Constants.Firestore.CollectionName.data)
                .collection(Constants.Firestore.CollectionName.users)
                .document(user!)
                .collection(Constants.Firestore.CollectionName.cardID)
                .document(cardID)
                .collection(Constants.Firestore.CollectionName.locations)
                .document("\(cityName.text!) - \(streetName.text!)")
                .setData(["City": cityName.text!, "Street": streetName.text!, "gMaps Link": googleMapsLink.text!], merge: true) { error in
                
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
        self.performSegue(withIdentifier: Constants.Segue.cAddLocationList, sender: self)
    }

// MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.cAddLocationList {
            
            let destinationVC = segue.destination as! AddListViewController
            
            if editCard2 == false {
                destinationVC.cardID = cardID
            } else {
                destinationVC.cardID = editCardID2
            }
            
            destinationVC.delegate = self
    
        }
        
        if segue.identifier == Constants.Segue.cAdd3 {
            
            let destinationVC = segue.destination as! CAdd3ViewController
            
            // Basic Info from 1st Step
            destinationVC.selectedNewLogo = logoImage
            destinationVC.selectedNewCompanyName = newCompanyName!
            destinationVC.selectedNewProductType = newProductType!
            destinationVC.selectedNewSector = newSector!
            
            // Location Info from 2nd Step
            destinationVC.selectedNewCountry = selectCountry.text!
            destinationVC.currentCardID = cardID
            destinationVC.numberOfPlaces = numberOfPlaces
           
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
        } else {
            addButton.isHidden = true
            listButton.isHidden = true
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
    
    // MARK: - Get Company Single Place Card for Edit
    
    func getCardForEdit2SP() {
        
        // Getting Company Card from Firebase Database for Step 2
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(editUserID2)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(editCardID2)
            .getDocument { document, error in
                
                if let e = error {
                    print("Error Getting Company Card for Edit. \(e)")
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let data = document!.data()
                        
                        
                            if let comCity = data![Constants.Firestore.Key.city] as? String {
                                if let comStreet = data![Constants.Firestore.Key.street] as? String {
                                    if let comMap = data![Constants.Firestore.Key.gMaps] as? String {
                                        
                                        self.cityName.text = comCity
                                        self.streetName.text = comStreet
                                        self.googleMapsLink.text = comMap
                                        self.listButton.isHidden = false
                                        self.addButton.isHidden = false
                            
                                        
                                }
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
             self.popUpWithOk(newTitle: "Error!", newMessage: "There was an Error when selected row. Please try again.")
        }
    }
}

