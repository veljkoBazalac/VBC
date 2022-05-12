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

protocol NewEditedLocation: AnyObject {
    func getNewEditedLocation(newLocation: String)
}

class AddStep2VC: UIViewController {
    
    @IBOutlet var blurEffect: UIVisualEffectView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet var spinner: UIActivityIndicatorView!

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
    
    // Delegate For Edit Location
    weak var delegate: NewEditedLocation?
    
    // Country List Dict
    private var countryList : [Country] = []
    
    // Current Number of Multiple Places
    var numberOfPlaces: Int = 0
    var singlePlace : Bool = true
    
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
        
        pickerView.delegate = self
        pickerView.dataSource = self
        selectCountry.inputView = pickerView
        infoButton.isHidden = true
        
        getBasicCard2()

        getCountryList()
        
        if editCard2 == true {
            navigationItem.rightBarButtonItem?.title = "Save"
            navigationItem.hidesBackButton = true
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
    
    // MARK: - Prepare for Segue
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.newLocationsList {
            
            let destinationVC = segue.destination as! LocationListVC
            
            if editCard2 == false {
                destinationVC.cardID = cardID
            } else {
                destinationVC.cardID = editCardID2
            }
            
            destinationVC.delegate = self
            destinationVC.delegateEdit = self
    
        }
        
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
            destinationVC.selectedNewCountry = selectCountry.text!
            destinationVC.cardID = cardID
            destinationVC.numberOfPlaces = numberOfPlaces
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
        
        if segmentedControl.selectedSegmentIndex == 0 {
            
            if selectCountry.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || cityName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || streetName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                
                PopUp().popUpWithOk(newTitle: "Location fields empty",
                                    newMessage: "Please fill all Location fields. Google Maps Link is optional.",
                                    vc: self )
                
            } else {
                
                if editCard2 == false {
                    
                    singlePlace = true
                    
                    // Create CardID
                    createCardID()
                    
                    // Create UserID
                    createUserID()
                    
                    // Uploading Data to Firestore with Logo Image
                    if self.logoImageView.image != nil {
                        self.uploadImage()
                    } else {
                        
                        // Adding Data to Firestore Database if user selected Single Place without Image
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
                                      Constants.Firestore.Key.singlePlace : true,
                                      Constants.Firestore.Key.companyCard : companyCard2,
                                      Constants.Firestore.Key.userID : user!,
                                      Constants.Firestore.Key.cardSaved : false,
                                      Constants.Firestore.Key.imageURL : ""], merge: true)
                        
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
                                      Constants.Firestore.Key.gMaps : googleMapsLink.text!], merge: true) { error in
                                
                                if error != nil {
                                    PopUp().popUpWithOk(newTitle: "Error!",
                                                        newMessage: "Error Uploading data to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)",
                                                        vc: self)
                                } else {
                                    // Perform Segue to Step 3 for Single Place without Image
                                    self.performSegue(withIdentifier: Constants.Segue.addNew3, sender: self)
                                }
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
                            .collection(Constants.Firestore.CollectionName.locations)
                            .document("\(self.cityName.text!) - \(self.streetName.text!)")
                            .setData([Constants.Firestore.Key.city : cityName.text!,
                                      Constants.Firestore.Key.street : streetName.text!,
                                      Constants.Firestore.Key.gMaps : googleMapsLink.text!], merge: true) { error in
                                
                                if error != nil {
                                    PopUp().popUpWithOk(newTitle: "Error!",
                                                        newMessage: "Error Uploading edited data to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)",
                                                        vc: self)
                                } else {
                                    
                                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                                        .document(Constants.Firestore.CollectionName.data)
                                        .collection(Constants.Firestore.CollectionName.users)
                                        .document(self.user!)
                                        .collection(Constants.Firestore.CollectionName.cardID)
                                        .document(self.cardID)
                                        .setData(["Card Edited" : false,
                                                  Constants.Firestore.Key.singlePlace : true], merge: true)
                                    
                                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                                        .document(Constants.Firestore.CollectionName.data)
                                        .collection(Constants.Firestore.CollectionName.users)
                                        .document(self.user!)
                                        .collection(Constants.Firestore.CollectionName.cardID)
                                        .document(self.cardID)
                                        .setData(["Card Edited" : true], merge: true)
                                    
                                        self.navigationController?.popViewController(animated: true)
                                }
                            }
                    }
                }
               
            } else {
               // Save Data for Multiple Places
                if numberOfPlaces <= 1 {
                    PopUp().popUpWithOk(newTitle: "You selected Multiple Places",
                                        newMessage: "You must add at least two places.",
                                        vc: self)
                } else {
                    // Creating New VBC
                    if editCard2 == false {
                        // Uploading Logo image.
                        if self.logoImageView.image != nil {
                            self.uploadImage()
                        } else {
                            // Perform Segue to Step 3 for Multiple Places without Image
                            self.performSegue(withIdentifier: Constants.Segue.addNew3, sender: self)
                        }
                    } else {
                        
                        // Updating Edited Data to Firestore Database for Multiple Places
                        db.collection(Constants.Firestore.CollectionName.VBC)
                            .document(Constants.Firestore.CollectionName.data)
                            .collection(Constants.Firestore.CollectionName.users)
                            .document(user!)
                            .collection(Constants.Firestore.CollectionName.cardID)
                            .document(editCardID2)
                            .setData([Constants.Firestore.Key.singlePlace : false], merge: true) { error in
                                
                                if error != nil {
                                    PopUp().popUpWithOk(newTitle: "Error!",
                                                        newMessage: "Error Uploading edited data to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)",
                                                        vc: self)
                                } else {
                                    
                                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                                        .document(Constants.Firestore.CollectionName.data)
                                        .collection(Constants.Firestore.CollectionName.users)
                                        .document(self.user!)
                                        .collection(Constants.Firestore.CollectionName.cardID)
                                        .document(self.cardID)
                                        .setData(["Card Edited" : false], merge: true)
                                    
                                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                                        .document(Constants.Firestore.CollectionName.data)
                                        .collection(Constants.Firestore.CollectionName.users)
                                        .document(self.user!)
                                        .collection(Constants.Firestore.CollectionName.cardID)
                                        .document(self.cardID)
                                        .setData(["Card Edited" : true], merge: true)
                                    
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
            
            PopUp().popUpWithOk(newTitle: "Location fields empty",
                                newMessage: "Please fill all Location fields. Google Maps Link is optional.",
                                vc: self)

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
                    .setData([Constants.Firestore.Key.personalName: personalName2,
                              Constants.Firestore.Key.companyName : companyName.text!,
                              Constants.Firestore.Key.sector : companySector.text!,
                              Constants.Firestore.Key.type : companyProductType.text!,
                              Constants.Firestore.Key.country : selectCountry.text!,
                              Constants.Firestore.Key.singlePlace : singlePlace,
                              Constants.Firestore.Key.cardID : cardID,
                              Constants.Firestore.Key.companyCard : companyCard2,
                              Constants.Firestore.Key.userID : user!,
                              Constants.Firestore.Key.cardSaved : false,
                              Constants.Firestore.Key.imageURL : ""], merge: true)
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
                    .setData([Constants.Firestore.Key.city : cityName.text!,
                              Constants.Firestore.Key.street : streetName.text!,
                              Constants.Firestore.Key.gMaps : googleMapsLink.text!,
                              Constants.Firestore.Key.socialAdded : false], merge: true) { error in
                        
                        if error != nil {
                            PopUp().popUpWithOk(newTitle: "Error!",
                                                newMessage: "Error Uploading data to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)",
                                                vc: self)
                        } else {
                            PopUp().popUpWithOk(newTitle: "Location successfully added",
                                                newMessage: "You can see list of your locations by pressing List button.",
                                                vc: self)
                            
                            if self.locationForEdit != "" {
                                self.moveDataToNewLocation(city: self.cityName.text!,
                                                           street: self.streetName.text!)
                            }
                            
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
    
// MARK: - List Button Pressed
    
    @IBAction func listButtonPressed(_ sender: UIButton) {
        // Perform Segue to view List of Locations
        self.performSegue(withIdentifier: Constants.Segue.newLocationsList, sender: self)
    }
    
// MARK: - Info Button Pressed
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        PopUp().popUpWithOk(newTitle: "You want to change a Country?",
                            newMessage: "To do it, you first need to delete all your Places from the List.",
                            vc: self)
    }

// MARK: - Segment Control
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        // If Segment is 1, you can add Multiple places - If segment is 0, you can add only Single place
        if segmentedControl.selectedSegmentIndex == 1 {
            addButton.isHidden = false
            listButton.isHidden = false
            
            if onlyCityName != "" || onlyStreetName != "" || onlyMapLink != "" {
                cityName.text?.removeAll()
                streetName.text?.removeAll()
                googleMapsLink.text?.removeAll()
            }
            
            if editSinglePlace2 == true {
                onlyCityName = editCardCity2
                onlyStreetName = editCardStreet2
                onlyMapLink = editCardMap2
                cityName.text?.removeAll()
                streetName.text?.removeAll()
                googleMapsLink.text?.removeAll()
            }
            
            if editCard2 == true {
                editSinglePlace2 = false
            }
        } else {
            addButton.isHidden = true
            listButton.isHidden = true
            
            if onlyCityName != "" || onlyStreetName != "" || onlyMapLink != "" {
                cityName.text = onlyCityName
                streetName.text = onlyStreetName
                googleMapsLink.text = onlyMapLink
            }
            
            if editCard2 == true {
                editSinglePlace2 = true
            }
        }
    }

// MARK: - Google Maps Icon Pressed
    
    @IBAction func gMapsIconPressed(_ sender: UITapGestureRecognizer) {
        
        guard let url = URL(string: "https://www.google.com/maps") else { return }
        
        DispatchQueue.main.async {
            // Open Google Maps App if installed
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                //Open Safari and Go to Google Maps Link.
                let svc = SFSafariViewController(url: url)
                self.present(svc, animated: true, completion: nil)
            }
        }
    }

    
}//

// MARK: - Firebase Functions
        
extension AddStep2VC {
    
    // MARK: - Upload Company Logo Image to Firebase Storage
        
    func uploadImage() {
        
        spinnerWithBlur()
        
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

                    let dbPath = db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.data)
                        .collection(Constants.Firestore.CollectionName.users)
                        .document(user!)
                        .collection(Constants.Firestore.CollectionName.cardID)
                        .document(cardID)
                        
                        if singlePlace == true {
                            
                            dbPath.setData(["\(Constants.Firestore.Key.imageURL)" : "\(urlString)",
                                            "Personal Name": personalName2,
                                            "Company Name": companyName.text!,
                                            "Sector": companySector.text!,
                                            "ProductType": companyProductType.text!,
                                            "CardID": cardID,
                                            "Country": selectCountry.text!,
                                            "Single Place": true,
                                            "Company Card": companyCard2,
                                            "User ID": user!,
                                            "Card Saved": false], merge: true)
                            
                            dbPath.collection(Constants.Firestore.CollectionName.locations)
                                .document("\(cityName.text!) - \(streetName.text!)")
                                .setData(["City": cityName.text!,
                                            "Street": streetName.text!,
                                            "gMaps Link": googleMapsLink.text!], merge: true) { error in
                                    
                                    if error != nil {
                                        PopUp().popUpWithOk(newTitle: "Error!",
                                                            newMessage: "Error Uploading data to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)",
                                                            vc: self)
                                    } else {
                                        
                                        self.spinner.stopAnimating()
                                        
                                        if self.spinner.isAnimating == false {
                                            // Perform Segue to Step 3
                                            self.performSegue(withIdentifier: Constants.Segue.addNew3, sender: self)
                                        }
                                    }
                                }
                            
                        } else {
                            
                            dbPath.setData([Constants.Firestore.Key.imageURL : "\(url)",
                                            Constants.Firestore.Key.singlePlace : false], merge: true) { error in
                                
                                if let error = error {
                                    PopUp().popUpWithOk(newTitle: "Error!",
                                                        newMessage: "Error Uploading Data with Image URL to Firestore. Please Check your Internet connection and try again. \(error.localizedDescription)",
                                                        vc: self)
                                    return
                                } else {
                                    
                                    self.spinner.stopAnimating()
                                    
                                    if self.spinner.isAnimating == false {
                                        // Perform Segue to Step 3
                                        self.performSegue(withIdentifier: Constants.Segue.addNew3, sender: self)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
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
    
}

// MARK: - Spinner With Blur

extension AddStep2VC {
    
    func spinnerWithBlur() {
        
        // Set the Size of the Blur View to be = to all screen
        blurEffect.bounds = self.view.bounds
        
        popUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.5, height: self.view.bounds.width * 0.5)
        
        animateIn(forView: blurEffect)
        animateIn(forView: popUpView)
        
        spinner.startAnimating()
    }
    
    func animateIn(forView: UIView) {
        let backgroundView = self.view!
        
        backgroundView.addSubview(forView)
        
        forView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        forView.alpha = 0
        forView.center = backgroundView.center
        
        UIView.animate(withDuration: 0.3, animations: {
            forView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            forView.alpha = 1
        })
        
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
            PopUp().popUpWithOk(newTitle: "Error!",
                                newMessage: "There was an Error when selected row. Please try again.",
                                vc: self)
        }
    }
}

// MARK: - EditSelectedLocation Delegate Function
extension AddStep2VC: EditSelectedLocation {
    
    func getEditLocation(city: String, street: String, map: String) {
        
        locationForEdit = "\(city) - \(street)"
        
        cityName.text = city
        streetName.text = street
        
        if map != "" {
            googleMapsLink.text = map
        }
    }
    
    func moveDataToNewLocation(city: String, street: String) {
        
        DispatchQueue.main.async {
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
                                            .document("\(city) - \(street)")
                                            .collection(Constants.Firestore.CollectionName.social)
                                            .document(socialName)
                                            .setData([
                                                Constants.Firestore.Key.name : socialName,
                                                Constants.Firestore.Key.link : socialLink
                                            ],merge: true) { error in
                                                if let e = error {
                                                    PopUp().popUpWithOk(newTitle: "Error",
                                                                        newMessage: "Error Moving Data to New Location.",
                                                                        vc: self)
                                                    print("\(e)")
                                                } else {
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
                                                                                    newMessage: "Error Deleting Social Media from Old Location.",
                                                                                    vc: self)
                                                                print("\(e)")
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
                            .document("\(city) - \(street)")
                            .setData([
                                Constants.Firestore.Key.socialAdded : socialAdded!,
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
                                                        newMessage: "Error Moving Contact Data to New Location.",
                                                        vc: self)
                                    print("\(e)")
                                } else {
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
                                                                    newMessage: "Error Deleting Contact Data from Old Location.",
                                                                    vc: self)
                                                print("\(e)")
                                            }
                                        }
                                }
                            }
                        self.delegate?.getNewEditedLocation(newLocation: "\(city) - \(street)")
                    }
                }
            }
    }
    
}

// MARK: - Get Number of Places Delegate
extension AddStep2VC: MultiplePlacesDelegate {
    
    func getOnlyLocation(city: String, street: String, map: String) {
        segmentedControl.selectedSegmentIndex = 0
        addButton.isHidden = true
        listButton.isHidden = true
        onlyCityName = city
        onlyStreetName = street
        onlyMapLink = map
        
        cityName.text = city
        streetName.text = street
        googleMapsLink.text = map
    }
    
    
    func getNumberOfPlaces(places: Int) {
        numberOfPlaces = places
        
        if places == 0 && editCard2 == false {
            selectCountry.isEnabled = true
            segmentedControl.isEnabled = true
            infoButton.isHidden = true
        } else if places == 0 && editCard2 == true {
            selectCountry.isEnabled = false
            segmentedControl.isEnabled = true
            infoButton.isHidden = false
        } else if places == 1 {
            selectCountry.isEnabled = false
            segmentedControl.isEnabled = true
            infoButton.isHidden = false
        } else if places > 1 {
            selectCountry.isEnabled = false
            segmentedControl.isEnabled = false
            infoButton.isHidden = false
        }
    }
    
}
