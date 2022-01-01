//
//  PAdd2VC.swift
//  VBC
//
//  Created by VELJKO on 25.12.21..
//

import UIKit
import Firebase
import FirebaseStorage

class PAdd2VC: UIViewController {
    // Basic Info Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var personalName: UILabel!
    @IBOutlet weak var personalSector: UILabel!
    @IBOutlet weak var personalProductType: UILabel!
    // Location Outlets
    @IBOutlet weak var selectCountry: UITextField!
    @IBOutlet weak var cityName: UITextField!
    @IBOutlet weak var streetName: UITextField!
    // Phone Number Outlets
    @IBOutlet weak var phoneCode: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    
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
    
    var phoneNumberList : [PhoneNumber] = []
    
    // Current CardID
    var cardID : String = ""
    
    // Picker View
    var pickerView = UIPickerView()
    
    // Basic Info from 1st Step
    var sectorNumber : Int?
    var logoImage : UIImage?
    var newPersonalName : String?
    var newSector : String?
    var newProductType : String?
    
    // Phone Info from 2nd Step
    var phone1 : String = ""
    var phone2 : String = ""
    var phone3 : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCountryList()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        selectCountry.inputView = pickerView
        
        imageView.image = logoImage
        personalName.text = newPersonalName
        personalSector.text = newSector
        personalProductType.text = newProductType
    }
    
    // MARK: - Add Phone Button Pressed
    
    @IBAction func addPhonePressed(_ sender: UIButton) {
        
        if phoneNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
            if phone1 == "" {
                phone1 = phoneNumber.text!
                let phone = PhoneNumber(code: phoneCode.text!, number: phone1)
                phoneNumberList.append(phone)
                blinkButton(buttonName: listButton)
                phoneNumber.text = .none
            } else if phone2 == "" {
                phone2 = phoneNumber.text!
                let phone = PhoneNumber(code: phoneCode.text!, number: phone2)
                phoneNumberList.append(phone)
                blinkButton(buttonName: listButton)
                phoneNumber.text = .none
            } else if phone3 == "" {
                phone3 = phoneNumber.text!
                let phone = PhoneNumber(code: phoneCode.text!, number: phone3)
                phoneNumberList.append(phone)
                blinkButton(buttonName: listButton)
                phoneNumber.text = .none
            } else {
                popUpWithOk(newTitle: "Maximum reached", newMessage: "You can add Maximum 3 Numbers to your VBC.")
            }
        } else {
            popUpWithOk(newTitle: "Missing Phone Number", newMessage: "Please Enter your Phone Number.")
        }
    }
    
    // MARK: - Show Phone List Button Pressed
    
    @IBAction func showPhoneListPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segue.pPhoneListSegue, sender: self)
    }
    
    // MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.pPhoneListSegue {
            
            let destinationVC = segue.destination as! PersonalContactListVC
            
            destinationVC.popUpTitle = "Phone Numbers"
            destinationVC.phoneListPressed = true
            destinationVC.cardID = cardID
            destinationVC.phoneNumbers = phoneNumberList
            destinationVC.delegate = self
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
    
    // MARK: - Create Card ID Funcion
    
    func createCardID() {
        
        let countryCode = Country().getCountryCode(country: selectCountry.text!)
        let personalShortName = personalName.text!.prefix(3).uppercased()
        let randomNumber = Int.random(in: 100...999)
        
        let newCardID = "VBC\(countryCode)S\(sectorNumber!)\(personalShortName)\(randomNumber)"
        cardID = newCardID
    }
    
    // MARK: - Configure Phone Numbers and return String for Firebase
    
    func configurePhoneNumbers(key: String) -> String {
        
        if phoneNumberList.count == 1 {
            
            let phoneNumber1 = phoneNumberList[0].number
            let phoneCode1 = phoneNumberList[0].code
            
            if phoneNumber1.trimmingCharacters(in: .whitespacesAndNewlines) != "" && key == Constants.Firestore.Key.phone1 {
                return phoneNumber1
            } else if phoneCode1.trimmingCharacters(in: .whitespacesAndNewlines) != "" && key == Constants.Firestore.Key.phone1code{
                return phoneCode1
            } else {
                return ""
            }
            
        } else if phoneNumberList.count == 2 {
            
            let phoneNumber1 = phoneNumberList[0].number
            let phoneCode1 = phoneNumberList[0].code
            let phoneNumber2 = phoneNumberList[1].number
            let phoneCode2 = phoneNumberList[1].code
            
            if phoneNumber1.trimmingCharacters(in: .whitespacesAndNewlines) != "" && key == Constants.Firestore.Key.phone1 {
                return phoneNumber1
            } else if phoneCode1.trimmingCharacters(in: .whitespacesAndNewlines) != "" && key == Constants.Firestore.Key.phone1code{
                return phoneCode1
            } else if phoneNumber2.trimmingCharacters(in: .whitespacesAndNewlines) != "" && key == Constants.Firestore.Key.phone2 {
                return phoneNumber2
            } else if phoneCode2.trimmingCharacters(in: .whitespacesAndNewlines) != "" && key == Constants.Firestore.Key.phone2code {
                return phoneCode2
            } else {
                return ""
            }
            
        } else if phoneNumberList.count == 3 {
            
            let phoneNumber1 = phoneNumberList[0].number
            let phoneCode1 = phoneNumberList[0].code
            let phoneNumber2 = phoneNumberList[1].number
            let phoneCode2 = phoneNumberList[1].code
            let phoneNumber3 = phoneNumberList[2].number
            let phoneCode3 = phoneNumberList[2].code
            
            if phoneNumber1.trimmingCharacters(in: .whitespacesAndNewlines) != "" && key == Constants.Firestore.Key.phone1 {
                return phoneNumber1
            } else if phoneCode1.trimmingCharacters(in: .whitespacesAndNewlines) != "" && key == Constants.Firestore.Key.phone1code{
                return phoneCode1
            } else if phoneNumber2.trimmingCharacters(in: .whitespacesAndNewlines) != "" && key == Constants.Firestore.Key.phone2 {
                return phoneNumber2
            } else if phoneCode2.trimmingCharacters(in: .whitespacesAndNewlines) != "" && key == Constants.Firestore.Key.phone2code {
                return phoneCode2
            } else if phoneNumber3.trimmingCharacters(in: .whitespacesAndNewlines) != "" && key == Constants.Firestore.Key.phone3 {
                return phoneNumber3
            } else if phoneCode3.trimmingCharacters(in: .whitespacesAndNewlines) != "" && key == Constants.Firestore.Key.phone3code {
                return phoneCode3
            } else {
                return ""
            }
            
        } else {
            return ""
        }
    }
    
    // MARK: - Next Navigation Bar Button Pressed
    
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
        
        // Uploading Logo image.
        //uploadImage()
        
        // Adding Data to Firestore Database
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.personalCards)
            .collection(user!)
            .document(cardID)
            .setData(["Name": personalName.text!,
                      "Sector": personalSector.text!,
                      "ProductType": personalProductType.text!,
                      "CardID": cardID,
                      "Country": selectCountry.text!,
                      "City": cityName.text!,
                      "Street": streetName.text!,
                      "Phone 1": configurePhoneNumbers(key: Constants.Firestore.Key.phone1),
                      "Phone1Code": configurePhoneNumbers(key: Constants.Firestore.Key.phone1code),
                      "Phone 2": configurePhoneNumbers(key: Constants.Firestore.Key.phone2),
                      "Phone2Code": configurePhoneNumbers(key: Constants.Firestore.Key.phone2code),
                      "Phone 3": configurePhoneNumbers(key: Constants.Firestore.Key.phone3),
                      "Phone3Code": configurePhoneNumbers(key: Constants.Firestore.Key.phone3code),]) { error in
                
                if error != nil {
                    self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading data to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)")
                    print("Error Uploading data to Firestore. \(error!)")
                } else {
                    self.performSegue(withIdentifier: Constants.Segue.pAdd3, sender: self)
                }
            }
    }
    
    // MARK: - Info Button Pressed
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        popUpWithOk(newTitle: "You want to change a Country?", newMessage: "To do it, you first need to delete all your Places from the List.")
    }
    
    // MARK: - Upload Personal Image to Firebase
    
    func uploadImage() {
        
        guard let image = logoImage, let data = image.jpegData(compressionQuality: 1.0) else {
            popUpWithOk(newTitle: "Error!", newMessage: "Something went wrong. Please Check your Internet connection and try again.")
            return
        }
        
        let imageName = UUID().uuidString
        let imageReference = storage.child(Constants.Firestore.Storage.personalImage).child(imageName)
        
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
                    .document(Constants.Firestore.CollectionName.personalCards)
                    .collection(user!)
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
    
    
    // MARK: - Get Contries List Function from Firebase
    
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

// MARK: - Protocol to Reload changed data from PersonalContactListVC

extension PAdd2VC: PhoneNumberListDelegate {
    
    func deletedPhoneNumber(atRow: Int) {
        if atRow == 0 {
            phone1 = ""
        } else if atRow == 1 {
            phone2 = ""
        } else if atRow == 2 {
            phone3 = ""
        }
    }
    
    func newPhoneNumberList(list: [PhoneNumber]) {
        phoneNumberList = list
    }
}

// MARK: - UIPickerView for Country

extension PAdd2VC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        }
        else {
            self.popUpWithOk(newTitle: "Error!", newMessage: "There was an Error when selected row. Please try again.")
        }
    }
}

