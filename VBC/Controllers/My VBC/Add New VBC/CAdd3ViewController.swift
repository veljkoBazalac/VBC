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
    @IBOutlet weak var personalName: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var companySector: UILabel!
    @IBOutlet weak var companyProductType: UILabel!
    
    // Select Location Outlet
    @IBOutlet weak var selectLocation: UITextField!
    
    // Phone Number Outlets
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneCode: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var phoneListButton: UIButton!
    
    // Email Address Outlets
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var emailListButton: UIButton!
    
    // Website Outlets
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var websiteLink: UITextField!
    @IBOutlet weak var websiteListButton: UIButton!
    @IBOutlet weak var wwwLabel: UILabel!
    
    // Social Media Outlets
    @IBOutlet weak var selectSocial: UITextField!
    @IBOutlet weak var socialProfile: UITextField!
    @IBOutlet weak var addSocial: UIButton!
    @IBOutlet weak var socialList: UIButton!
    @IBOutlet weak var linkToFinish: UILabel!
    
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
    var singlePlace : Bool = true
    // Info successfully added
    var infoForPlace = [String:Bool]()
    // Show Pop Up or No
    var showPopUp : Bool = true
    // Number of Contact Data Added
    var numberOfPhones : Int = 0
    var numberOfEmails : Int = 0
    var numberOfWebsite : Int = 0
    
    // Social Networks List Dict
    private var socialMediaList : [SocialMedia] = []
    private var socialMediaNames : [String] = []
    private var socialExist : Bool = false
    
    // Edit Card
    var editCard3 : Bool = false
    var editCardID3 : String = ""
    var editUserID3 : String = ""
    var editSinglePlace3 : Bool = true
    var editCardSaved3 : Bool = false
    var editCardCountry3 : String = ""
    var editCardLocation : String = ""
    var NavBarTitle3 : String = ""
    
    // Basic Info from 1st Step
    var logoImage3 : UIImage?
    var personalName3 : String = ""
    var companyName3 : String = ""
    var sector3 : String = ""
    var productType3 : String = ""
    var companyCard3 : Bool = true
    
    // Location Info from 2nd Step
    var selectedNewCountry : String = ""
    var currentCardID : String = ""
    var numberOfPlaces : Int = 0
    
    // Contact Info from 3rd Step
    var phoneNumberCode : String = ""
    var phone1 : String = ""
    var phone2 : String = ""
    var phone3 : String = ""
    
    var email1 : String = ""
    var email2 : String = ""
    
    var web1 : String = ""
    var web2 : String = ""

    var social1 : String = ""
    var social2 : String = ""
    var social3 : String = ""
    var social4 : String = ""
    var social5 : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getBasicCard3()
        
        getCountryCode()
        
        getSocialMediaList()
        
        getData()
        
        selectLocation.inputView = pickerView
        selectSocial.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        
    }
    
    // MARK: - Get Card with Basic info from Step 1
    
    func getBasicCard3() {
        
        if companyCard3 == true {
            personalName.isHidden = true
        } else {
            personalName.text = personalName3
        }
        
        if editCard3 == true {
            navigationItem.rightBarButtonItem?.title = "Save"
            navigationItem.title = NavBarTitle3
            navigationItem.hidesBackButton = true
        }
            
        logoImageView.image = logoImage3
        companyName.text = companyName3
        companySector.text = sector3
        companyProductType.text = productType3
    }
    
    // MARK: - Get Data from Firestore Function
    func getData() {
        
        DispatchQueue.main.async {
            self.getLocationList()
        }
        
        if editCard3 == true {
            self.selectLocation.text = self.editCardLocation
            getContactData()
        }
    }
    
    // MARK: - Get Country Code and Show it in Text Field
    
    func getCountryCode() {
        let countryCode = Country().getCountryCode(country: selectedNewCountry)
        phoneNumberCode = countryCode
        phoneCode.text = "+\(phoneNumberCode)"
        
    }
    
    // MARK: - Get List of Location(s)
    
    func getLocationList() {
        // Getting location list
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
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
                                        self.infoForPlace.updateValue(false, forKey: "\(places.city) - \(places.street)")
                                        
                                        
                                        if self.editCard3 == false {
                                            
                                            if self.singlePlace == true {
                                                self.selectLocation.isEnabled = false
                                                self.selectLocation.text = "\(cityName) - \(cityStreet)"
                                            } else {
                                                self.selectLocation.text = "\(self.locationsList.first!.city) - \(self.locationsList.first!.street)"
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
    
    // MARK: - Finish Creating Company VBC
    
    @IBAction func finishButtonPressed(_ sender: UIBarButtonItem) {
        
        if infoForPlace.values.contains(false) && editCard3 == false {
            
            if singlePlace == true {
                self.popUpWithOk(newTitle: "Contact Info Missing", newMessage: "Press + button to add Contact Info. You must add at least one Contact Info.")
                
            } else {
                self.popUpWithOk(newTitle: "Contact Info Missing", newMessage: "Press + button to add Contact Info. You must add at least one Contact Info for every Location.")
            }
        } else {
            
            if editCard3 == false {
                performSegue(withIdentifier: Constants.Segue.addFinish, sender: self)
            } else {
                
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(user!)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(currentCardID)
                    .setData(["Contact Info Added" : false], merge: true) { error in
                        
                        if let e = error {
                            print("Contact Info Added Failed. \(e)")
                        } else {
                            
                            self.db.collection(Constants.Firestore.CollectionName.VBC)
                                .document(Constants.Firestore.CollectionName.data)
                                .collection(Constants.Firestore.CollectionName.users)
                                .document(self.user!)
                                .collection(Constants.Firestore.CollectionName.cardID)
                                .document(self.currentCardID)
                                .setData(["Contact Info Edited" : false], merge: true)
                            
                            self.db.collection(Constants.Firestore.CollectionName.VBC)
                                .document(Constants.Firestore.CollectionName.data)
                                .collection(Constants.Firestore.CollectionName.users)
                                .document(self.user!)
                                .collection(Constants.Firestore.CollectionName.cardID)
                                .document(self.currentCardID)
                                .setData(["Contact Info Edited" : true], merge: true)
                        }
                    }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - Add Phone Number Actions
    
    @IBAction func addPhonePressed(_ sender: UIButton) {
        // Adding Phone Numbers to Firestore
        if phoneNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
            if phone1.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                phone1 = phoneNumber.text!
                
                showPopUp = false
                uploadContactData(field: Constants.Firestore.Key.phone1code, value: phoneCode.text!, button: phoneListButton)
                showPopUp = true
                uploadContactData(field: Constants.Firestore.Key.phone1, value: phone1, button: phoneListButton)
                
                phoneNumber.text = ""
                    
                } else if phone2.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    phone2 = phoneNumber.text!
                    
                    showPopUp = false
                    uploadContactData(field: Constants.Firestore.Key.phone2code, value: phoneCode.text!, button: phoneListButton)
                    showPopUp = true
                    uploadContactData(field: Constants.Firestore.Key.phone2, value: phone2, button: phoneListButton)
                    
                    phoneNumber.text = ""
                    
                } else if phone3.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    phone3 = phoneNumber.text!
                    
                    showPopUp = false
                    uploadContactData(field: Constants.Firestore.Key.phone3code, value: phoneCode.text!, button: phoneListButton)
                    showPopUp = true
                    uploadContactData(field: Constants.Firestore.Key.phone3, value: phone3, button: phoneListButton)
                    
                    phoneNumber.text = ""
                    
                } else {
                popUpWithOk(newTitle: "Maximum reached", newMessage: "You can add Maximum 3 Numbers for \(self.selectLocation.text!).")
            }
        } else {
            popUpWithOk(newTitle: "Missing Phone Number", newMessage: "Please Enter your Phone Number.")
        }
    }
    
    // MARK: - Add Email Number Action
    @IBAction func addEmailPressed(_ sender: UIButton) {
        // Adding Emails to Firestore
        if emailAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
            if email1.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                email1 = emailAddress.text!
                
                uploadContactData(field: Constants.Firestore.Key.email1, value: email1, button: emailListButton)
                
                emailAddress.text = ""
                
            } else if email2.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                email2 = emailAddress.text!
                
                uploadContactData(field: Constants.Firestore.Key.email2, value: email2, button: emailListButton)
                
                emailAddress.text = ""
                
            } else {
                popUpWithOk(newTitle: "Maximum reached", newMessage: "You can add Maximum 2 Email Addresses for \(self.selectLocation.text!).")
            }
        } else {
            popUpWithOk(newTitle: "Missing Email", newMessage: "Please Enter your Email Address.")
        }
    }
    
    // MARK: - Add Website Link Action
    
    @IBAction func addWebsitePressed(_ sender: UIButton) {
        // Adding Websites to Firestore
        if websiteLink.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
                if web1.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    web1 = websiteLink.text!
                    
                    uploadContactData(field: Constants.Firestore.Key.web1, value: "\(wwwLabel.text!)\(web1)", button: websiteListButton)
                    
                    websiteLink.text = .none
                    
                } else if web2.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    web2 = websiteLink.text!
                    
                    uploadContactData(field: Constants.Firestore.Key.web2, value: "\(wwwLabel.text!)\(web2)", button: websiteListButton)
                    
                    websiteLink.text = .none
                    
                } else  {
                    popUpWithOk(newTitle: "Maximum reached", newMessage: "You can add Maximum 2 Website Links for \(self.selectLocation.text!)")
                }
        } else {
            popUpWithOk(newTitle: "Missing Website", newMessage: "Please Enter your Website Link.")
        }
    }
    
    
    // MARK: - Add Social Media Action
    
    @IBAction func addSocialPressed(_ sender: UIButton) {
        
        // Adding Social Media to Firestore
        if socialProfile.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
            if social1.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                social1 = selectSocial.text!
                blockSameSocialNetwork(name: social1)
                
                if socialExist == false {
                    
                    showPopUp = false
                    uploadSocialData(field: Constants.Firestore.Key.name, value: social1, blink: socialList)
                    
                    showPopUp = true
                    uploadSocialData(field: Constants.Firestore.Key.link, value: socialProfile.text!, blink: socialList)
                    
                    socialMediaNames.append(social1)
                    selectSocial.text = .none
                    socialProfile.text = .none
                    
                } else {
                    popUpWithOk(newTitle: "Social Media exist", newMessage: "You can only add one \(social1) Profile for \(self.selectLocation.text!).")
                    social1 = ""
                }
                
            } else if social2.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                social2 = selectSocial.text!
                blockSameSocialNetwork(name: social2)
                
                if socialExist == false {
                    
                    showPopUp = false
                    uploadSocialData(field: Constants.Firestore.Key.name, value: social2, blink: socialList)
                    
                    showPopUp = true
                    uploadSocialData(field: Constants.Firestore.Key.link, value: socialProfile.text!, blink: socialList)
                    
                    socialMediaNames.append(social2)
                    selectSocial.text = .none
                    socialProfile.text = .none
                    
                } else {
                    popUpWithOk(newTitle: "Social Media exist", newMessage: "You can only add one \(social2) Profile for \(self.selectLocation.text!).")
                    social2 = ""
                }
                
            } else if social3.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                social3 = selectSocial.text!
                blockSameSocialNetwork(name: social3)
                
                if socialExist == false {
                    
                    showPopUp = false
                    uploadSocialData(field: Constants.Firestore.Key.name, value: social3, blink: socialList)
                    
                    showPopUp = true
                    uploadSocialData(field: Constants.Firestore.Key.link, value: socialProfile.text!, blink: socialList)
                    
                    socialMediaNames.append(social3)
                    selectSocial.text = .none
                    socialProfile.text = .none
                    
                } else {
                    popUpWithOk(newTitle: "Social Media exist", newMessage: "You can only add one \(social3) Profile for \(self.selectLocation.text!).")
                    social3 = ""
                }
                
            } else if social4.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                social4 = selectSocial.text!
                blockSameSocialNetwork(name: social4)
                
                if socialExist == false {
                    
                    showPopUp = false
                    uploadSocialData(field: Constants.Firestore.Key.name, value: social4, blink: socialList)
                    
                    showPopUp = true
                    uploadSocialData(field: Constants.Firestore.Key.link, value: socialProfile.text!, blink: socialList)
                    
                    socialMediaNames.append(social4)
                    selectSocial.text = .none
                    socialProfile.text = .none
                    
                } else {
                    popUpWithOk(newTitle: "Social Media exist", newMessage: "You can only add one \(social4) Profile for \(self.selectLocation.text!).")
                    social4 = ""
                }
                
            } else if social5.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                social5 = selectSocial.text!
                blockSameSocialNetwork(name: social5)
                
                if socialExist == false {
                    
                    showPopUp = false
                    uploadSocialData(field: Constants.Firestore.Key.name, value: social5, blink: socialList)
                    
                    showPopUp = true
                    uploadSocialData(field: Constants.Firestore.Key.link, value: socialProfile.text!, blink: socialList)
                    
                    socialMediaNames.append(social5)
                    selectSocial.text = .none
                    socialProfile.text = .none
                    
                } else {
                    popUpWithOk(newTitle: "Social Media exist", newMessage: "You can only add one \(social5) Profile for \(self.selectLocation.text!).")
                    social5 = ""
                }
                
            } else {
                popUpWithOk(newTitle: "Maximum reached", newMessage: "You can add Maximum 5 Social Media profiles for \(self.selectLocation.text!).")
            }
            
        } else {
            popUpWithOk(newTitle: "Missing Social Profile", newMessage: "Please Choose your Social Media and Enter your Profile Link.")
        }
        
    }
    
    // MARK: - Show List of Contact Data Buttons
    
    @IBAction func showPhoneListPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segue.phoneListSegue, sender: self)
    }
    
    
    @IBAction func showEmailPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segue.emailListSegue, sender: self)
    }
    
    
    @IBAction func showWebsitePressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segue.websiteListSegue, sender: self)
    }
    
    @IBAction func showSocialPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segue.pSocialList, sender: self)
    }
    
    // MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.phoneListSegue {
            
            let destinationVC = segue.destination as! ContactListVC
            
            destinationVC.popUpTitle = "Phone Number List"
            destinationVC.phoneListPressed = true
            destinationVC.cardID = currentCardID
            destinationVC.dataForLocation = selectLocation.text!
            destinationVC.delegateCD = self
            destinationVC.delegateSL = self
            destinationVC.singlePlace = singlePlace
        }
        
        else if segue.identifier == Constants.Segue.emailListSegue {
            
            let destinationVC = segue.destination as! ContactListVC
            
            destinationVC.popUpTitle = "Email List"
            destinationVC.emailListPressed = true
            destinationVC.cardID = currentCardID
            destinationVC.dataForLocation = selectLocation.text!
            destinationVC.delegateCD = self
            destinationVC.delegateSL = self
            destinationVC.singlePlace = singlePlace
        }
        
        if segue.identifier == Constants.Segue.websiteListSegue {
            
            let destinationVC = segue.destination as! ContactListVC
            
            destinationVC.popUpTitle = "Website List"
            destinationVC.websiteListPressed = true
            destinationVC.cardID = currentCardID
            destinationVC.dataForLocation = selectLocation.text!
            destinationVC.delegateCD = self
            destinationVC.delegateSL = self
            destinationVC.singlePlace = singlePlace
        }
        
        if segue.identifier == Constants.Segue.pSocialList {
            
            let destinationVC = segue.destination as! ContactListVC
        
            destinationVC.popUpTitle = "Social Media"
            destinationVC.socialListPressed = true
            destinationVC.cardID = currentCardID
            destinationVC.dataForLocation = selectLocation.text!
            destinationVC.delegateCD = self
            destinationVC.delegateSL = self
            destinationVC.singlePlace = singlePlace
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

    
    
    // MARK: - Blink Button Function
    
    func blinkButton(buttonName: UIButton) {
        buttonName.tintColor = .green
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            buttonName.tintColor = UIColor(named: "Color Dark")
        }
    }
  
    // MARK: - Block User to Add same Social Media
    
    func blockSameSocialNetwork(name: String) {
        
        socialExist = false
        
        if socialMediaNames.contains(name) == true {
            socialExist = true
        } else {
            socialExist = false
        }
        
    }

    // MARK: - Change Link Label Function
    
    func changeLinkToFinishLabel() {
        
        socialProfile.text = ""
        socialProfile.placeholder = "Select Social Media"
        
        if selectSocial.text == "Facebook" {
            linkToFinish.text = "facebook.com/"
            socialProfile.placeholder = "Enter your Facebook Link"
        } else if selectSocial.text == "Instagram" {
            linkToFinish.text = "instagram.com/"
            socialProfile.placeholder = "Enter your Instagram Link"
        } else if selectSocial.text == "TikTok" || selectSocial.text == "Twitter" || selectSocial.text == "Pinterest" {
            linkToFinish.text = "Username: @"
            socialProfile.placeholder = "Enter your Name"
        } else if selectSocial.text == "Viber" || selectSocial.text == "WhatsApp" {
            linkToFinish.text = "Phone Number:"
            socialProfile.text = "+\(phoneNumberCode)"
        } else if selectSocial.text == "LinkedIn" {
            linkToFinish.text = "linkedin.com/in/"
            socialProfile.placeholder = "Enter your Linked In Link"
        } else if selectSocial.text == "GitHub" {
            linkToFinish.text = "github.com/"
            socialProfile.placeholder = "Enter your GitHub Link"
        } else if selectSocial.text == "YouTube" {
            linkToFinish.text = "youtube.com/channel/"
            socialProfile.placeholder = "Enter your YouTube Link"
        }
    }
    
    
    // MARK: - Upload Contact Data
    
    func uploadContactData(field: String, value: String, button: UIButton) {
        // Adding Contact Info for Multiple Places
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.cardID)
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
    
    // MARK: - Upload Social Media
    
    func uploadSocialData(field: String, value: String, blink: UIButton) {
        
            // Adding Social Media Data for Multiple Places to Firestore
            db.collection(Constants.Firestore.CollectionName.VBC)
                .document(Constants.Firestore.CollectionName.data)
                .collection(Constants.Firestore.CollectionName.users)
                .document(user!)
                .collection(Constants.Firestore.CollectionName.cardID)
                .document(currentCardID)
                .collection(Constants.Firestore.CollectionName.locations)
                .document(selectLocation.text!)
                .collection(Constants.Firestore.CollectionName.social)
                .document(selectSocial.text!)
                .setData(["\(field)":"\(value)"], merge: true) { error in
                    
                    if error != nil {
                        self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading Social Media Info to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)")
                    } else {
                        
                        self.db.collection(Constants.Firestore.CollectionName.VBC)
                            .document(Constants.Firestore.CollectionName.data)
                            .collection(Constants.Firestore.CollectionName.users)
                            .document(self.user!)
                            .collection(Constants.Firestore.CollectionName.cardID)
                            .document(self.currentCardID)
                            .collection(Constants.Firestore.CollectionName.locations)
                            .document(self.selectLocation.text!)
                            .setData(["Social Media Added" : true], merge: true)
                        
                        if self.showPopUp == true {
                            
                            self.popUpWithOk(newTitle: "Successfully added", newMessage: "Social Media successfully added for \(self.selectLocation.text!)")
                        }
                        self.finishButton.isEnabled = true
                        self.infoForPlace.updateValue(true, forKey: self.selectLocation.text!)
                        self.blinkButton(buttonName: blink)
                    }
                }
            
    
    }
    
    
}

// MARK: - Get Data From Database

extension CAdd3ViewController {
    
    func getSocialMediaList() {
        
        db.collection(Constants.Firestore.CollectionName.social).getDocuments { snapshot, error in
            
            if let e = error {
                self.popUpWithOk(newTitle: "Error!", newMessage: "Error Getting data from Database. Please Check your Internet connection and try again. \(e.localizedDescription)")
            } else {
                
                if let snapshotDocuments = snapshot?.documents {
                    
                    for documents in snapshotDocuments {
                        
                        let data = documents.data()
                        
                        if let socialNetworkData = data[Constants.Firestore.Key.name] as? String {
                            
                            let socialNetwork = SocialMedia(name: socialNetworkData)
                            
                            self.socialMediaList.append(socialNetwork)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Get Contact Data
    func getContactData() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(currentCardID)
            .collection(Constants.Firestore.CollectionName.locations)
            .document(selectLocation.text!)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error getting Multiple Places Info. \(e)")
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let data = document!.data()
                            
                            // Phone Contact Info
                            if let phoneCode1 = data![Constants.Firestore.Key.phone1code] as? String {
                                if let phone1Number = data![Constants.Firestore.Key.phone1] as? String {
                                    
                                    if phone1Number != "" {
                                        self.phone1 = "\(phoneCode1)\(phone1Number)"
                                    }
                                }
                            }
                            
                            if let phoneCode2 = data![Constants.Firestore.Key.phone2code] as? String {
                                if let phone2Number = data![Constants.Firestore.Key.phone2] as? String {
                                    
                                    if phone2Number != "" {
                                        self.phone2 = "\(phoneCode2)\(phone2Number)"
                                    }
                                }
                            }
                            
                            if let phoneCode3 = data![Constants.Firestore.Key.phone3code] as? String {
                                if let phone3Number = data![Constants.Firestore.Key.phone3] as? String {
                                    
                                    if phone3Number != "" {
                                        self.phone3 = "\(phoneCode3)\(phone3Number)"
                                    }
                                }
                            }
                            
                            // Email Contact Info
                            if let email1Address = data![Constants.Firestore.Key.email1] as? String {
                                if email1Address != "" {
                                    self.email1 = email1Address
                                }
                            }
                            if let email2Address = data![Constants.Firestore.Key.email2] as? String {
                                if email2Address != "" {
                                    self.email2 = email2Address
                                }
                            }
                            
                            // Website Contact Info
                            if let web1Link = data![Constants.Firestore.Key.web1] as? String {
                                if web1Link != "" {
                                    self.web1 = web1Link
                                }
                            }
                            if let web2Link = data![Constants.Firestore.Key.web2] as? String {
                                if web2Link != "" {
                                    self.web2 = web2Link
                                }
                            }
                    }
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
        } else if selectSocial.isEditing {
            return socialMediaList.count
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if selectLocation.isEditing {
            return "\(locationsList[row].city) - \(locationsList[row].street)"
        } else if selectSocial.isEditing {
            return socialMediaList[row].name
        } else {
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
            social1 = ""
            social2 = ""
            social3 = ""
            social4 = ""
            social5 = ""
            
            if editCard3 == true {
                getContactData()
            }
            
        } else if selectSocial.isEditing {
            selectSocial.text = socialMediaList[row].name
            changeLinkToFinishLabel()
        }
        else {
            popUpWithOk(newTitle: "Error!", newMessage: "There was an Error when selected row. Please try again.")
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

extension CAdd3ViewController: SocialListDelegate {
    
    func newSocialMediaList(list: [String]) {
        socialMediaNames = list
    }
    
    
    func deletedSocialMedia(rowTitle: String, atRow: Int) {
        
        if rowTitle == social1 {
            social1 = ""
        } else if rowTitle == social2 {
            social2 = ""
        } else if rowTitle == social3 {
            social3 = ""
        } else if rowTitle == social4 {
            social4 = ""
        } else if rowTitle == social5 {
            social5 = ""
        }
    }
    
}
