//
//  CAdd3ViewController.swift
//  VBC
//
//  Created by VELJKO on 14.11.21..
//

import UIKit
import Firebase

class AddStep3VC: UIViewController {
    
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
    @IBOutlet weak var linkStack: UIStackView!
    
    // Finish Nav Button
    @IBOutlet weak var finishButton: UIBarButtonItem!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Auth Current user ID
    let user = Auth.auth().currentUser?.uid
    // Picker View
    var pickerView = UIPickerView()
    // Pop Up With TableView
    var popUpTableView : PopUpTableView!
    // Locations Dict
    var locationsList : [Location] = []
    // Single Place or Multiple Places
    var singlePlace : Bool = true
    // Info successfully added
    var infoForPlace = [String:Bool]()
    
    // Contact Data List Dict
    private var phoneNumbersList : [PhoneNumber] = []
    private var emailAddressList : [Email] = []
    private var websiteList : [Website] = []
    private var socialMediaList : [SocialMedia] = []
    
    // Array of Keys for Firestore
    private var keyPhoneNumbersList : [String] = []
    private var keyEmailAddressList : [String] = []
    private var keyWebsiteList : [String] = []
    private var keySocialMedia : [String] = []
    
    // Social Networks List Dict
    private var selectSocialMedia : [SocialMedia] = []
    private var socialExist : Bool = false
    
    // Var that show which Button List is pressed
    private var phoneListPressed : Bool = false
    private var emailListPressed : Bool = false
    private var websiteListPressed : Bool = false
    private var socialListPressed : Bool = false
    
    // Bool that indicates if user deleted row in PopUpTableView
    private var rowDeleted : Bool = false
    
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
    var cardID : String = ""
    var numberOfPlaces : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumber.attributedPlaceholder = NSAttributedString(
            string: "Enter Phone number...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        emailAddress.attributedPlaceholder = NSAttributedString(
            string: "Enter Email address...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        websiteLink.attributedPlaceholder = NSAttributedString(
            string: "Enter Website link...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        selectSocial.attributedPlaceholder = NSAttributedString(
            string: "Select Social Media",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        socialProfile.attributedPlaceholder = NSAttributedString(
            string: "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        
        
        getBasicCard3()
        
        getCountryCode()
        
        getSocialMediaList()
        
        DispatchQueue.main.async {
            self.getLocationList()
        }
        
        linkStack.isHidden = true
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
    
    // MARK: - Get Country Code and Show it in Text Field
    
    func getCountryCode() {
        let countryCode = Country().getCountryCode(country: selectedNewCountry)
        phoneCode.text = "+\(countryCode)"
        
    }
    
    // MARK: - Finish Creating Company VBC
    
    @IBAction func finishButtonPressed(_ sender: UIBarButtonItem) {
        
        if infoForPlace.values.contains(false) && editCard3 == false {
            
            if singlePlace == true {
                PopUp().popUpWithOk(newTitle: "Contact Info Missing",
                                    newMessage: "Press + button to add Contact Info. You must add at least one Contact Info.",
                                    vc: self)
                
            } else {
                PopUp().popUpWithOk(newTitle: "Contact Info Missing",
                                    newMessage: "Press + button to add Contact Info. You must add at least one Contact Info for every Location.",
                                    vc: self)
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
                    .document(cardID)
                    .setData(["Contact Info Added" : false], merge: true) { error in
                        
                        if let e = error {
                            print("Contact Info Added Failed. \(e)")
                        } else {
                            
                            self.db.collection(Constants.Firestore.CollectionName.VBC)
                                .document(Constants.Firestore.CollectionName.data)
                                .collection(Constants.Firestore.CollectionName.users)
                                .document(self.user!)
                                .collection(Constants.Firestore.CollectionName.cardID)
                                .document(self.cardID)
                                .setData(["Contact Info Edited" : false], merge: true)
                            
                            self.db.collection(Constants.Firestore.CollectionName.VBC)
                                .document(Constants.Firestore.CollectionName.data)
                                .collection(Constants.Firestore.CollectionName.users)
                                .document(self.user!)
                                .collection(Constants.Firestore.CollectionName.cardID)
                                .document(self.cardID)
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
            
            if keyPhoneNumbersList.contains(Constants.Firestore.Key.phone1) == false {
                
                uploadContactData(field: Constants.Firestore.Key.phone1code,
                                  value: phoneCode.text!.replacingOccurrences(of: " ", with: ""),
                                  button: phoneListButton)
                uploadContactData(field: Constants.Firestore.Key.phone1,
                                  value: phoneNumber.text!.replacingOccurrences(of: " ", with: ""),
                                  button: phoneListButton)
                
                phoneNumber.text?.removeAll()
                getContactData()
                } else if keyPhoneNumbersList.contains(Constants.Firestore.Key.phone2) == false {
                    
                    uploadContactData(field: Constants.Firestore.Key.phone2code,
                                      value: phoneCode.text!.replacingOccurrences(of: " ", with: ""),
                                      button: phoneListButton)
                    uploadContactData(field: Constants.Firestore.Key.phone2,
                                      value: phoneNumber.text!.replacingOccurrences(of: " ", with: ""),
                                      button: phoneListButton)
                    
                    phoneNumber.text?.removeAll()
                    getContactData()
                } else if keyPhoneNumbersList.contains(Constants.Firestore.Key.phone3) == false {
                    
                    uploadContactData(field: Constants.Firestore.Key.phone3code, value:
                                        phoneCode.text!.replacingOccurrences(of: " ", with: ""),
                                      button: phoneListButton)
                    uploadContactData(field: Constants.Firestore.Key.phone3,
                                      value: phoneNumber.text!.replacingOccurrences(of: " ", with: ""),
                                      button: phoneListButton)
                    
                    phoneNumber.text?.removeAll()
                    getContactData()
                } else if keyPhoneNumbersList.contains(Constants.Firestore.Key.phone1) && keyPhoneNumbersList.contains(Constants.Firestore.Key.phone2) && keyPhoneNumbersList.contains(Constants.Firestore.Key.phone3){
                    self.view.endEditing(true)
                    PopUp().popUpWithOk(newTitle: "Maximum reached",
                                        newMessage: "You can add Maximum 3 Numbers for \n\(self.selectLocation.text!).",
                                        vc: self)
                    
            }
        } else {
            self.view.endEditing(true)
            PopUp().popUpWithOk(newTitle: "Missing Phone Number",
                                newMessage: "Please Enter your Phone Number.",
                                vc: self)
        }
        self.view.endEditing(true)
    }
    
    // MARK: - Add Email Number Action
    
    @IBAction func addEmailPressed(_ sender: UIButton) {
        // Adding Emails to Firestore
        if emailAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
            if keyEmailAddressList.contains(Constants.Firestore.Key.email1) == false {
                
                uploadContactData(field: Constants.Firestore.Key.email1,
                                  value: emailAddress.text!.replacingOccurrences(of: " ", with: ""),
                                  button: emailListButton)
                
                emailAddress.text?.removeAll()
                getContactData()
            } else if keyEmailAddressList.contains(Constants.Firestore.Key.email2) == false {
                
                uploadContactData(field: Constants.Firestore.Key.email2,
                                  value: emailAddress.text!.replacingOccurrences(of: " ", with: ""),
                                  button: emailListButton)
                
                emailAddress.text?.removeAll()
                        getContactData()
            } else if keyEmailAddressList.contains(Constants.Firestore.Key.email1) && keyEmailAddressList.contains(Constants.Firestore.Key.email2){
                self.view.endEditing(true)
                PopUp().popUpWithOk(newTitle: "Maximum reached",
                                    newMessage: "You can add Maximum 2 Email Addresses for \n\(self.selectLocation.text!).",
                                    vc: self)
            }
        } else {
            self.view.endEditing(true)
            PopUp().popUpWithOk(newTitle: "Missing Email",
                                newMessage: "Please Enter your Email Address.",
                                vc: self)
        }
        self.view.endEditing(true)
    }
    
    // MARK: - Add Website Link Action
    
    @IBAction func addWebsitePressed(_ sender: UIButton) {
        // Adding Websites to Firestore
        if websiteLink.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
            if keyWebsiteList.contains(Constants.Firestore.Key.web1) == false {
                    
                uploadContactData(field: Constants.Firestore.Key.web1,
                                  value: "\(wwwLabel.text!)\(websiteLink.text!.replacingOccurrences(of: " ", with: ""))",
                                  button: websiteListButton)
                    
                    websiteLink.text?.removeAll()
                    getContactData()
                } else if keyWebsiteList.contains(Constants.Firestore.Key.web2) == false {
                    
                    uploadContactData(field: Constants.Firestore.Key.web2,
                                      value: "\(wwwLabel.text!)\(websiteLink.text!.replacingOccurrences(of: " ", with: ""))",
                                      button: websiteListButton)
                    
                    websiteLink.text?.removeAll()
                    getContactData()
                } else if keyWebsiteList.contains(Constants.Firestore.Key.web1) && keyWebsiteList.contains(Constants.Firestore.Key.web2) {
                    self.view.endEditing(true)
                    PopUp().popUpWithOk(newTitle: "Maximum reached",
                                        newMessage: "You can add Maximum 2 Website Links for \n\(self.selectLocation.text!)",
                                        vc: self)
                }
        } else {
            self.view.endEditing(true)
            PopUp().popUpWithOk(newTitle: "Missing Website",
                                newMessage: "Please Enter your Website Link.",
                                vc: self)
        }
        self.view.endEditing(true)
    }
    
    // MARK: - Add Social Media Action
    
    @IBAction func addSocialPressed(_ sender: UIButton) {
        
        // Adding Social Media to Firestore
        if socialProfile.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
            if socialMediaList.count == 0 {
                blockSameSocialNetwork(name: selectSocial.text!)
                
                if socialExist == false {
                    
                    uploadSocialData(field: Constants.Firestore.Key.name,
                                     value: selectSocial.text!,
                                     blink: socialList)
                    
                    uploadSocialData(field: Constants.Firestore.Key.link,
                                     value: socialProfile.text!.replacingOccurrences(of: " ", with: ""),
                                     blink: socialList)
                    
                    selectSocial.text?.removeAll()
                    socialProfile.text?.removeAll()
                    getSocialData()
                } else {
                    self.view.endEditing(true)
                    PopUp().popUpWithOk(newTitle: "Social Media exist",
                                        newMessage: "You can only add one \(selectSocial.text!) Profile for \(self.selectLocation.text!).",
                                        vc: self)
                }
                
            } else if socialMediaList.count == 1 {
                blockSameSocialNetwork(name: selectSocial.text!)
                
                if socialExist == false {
                    
                    uploadSocialData(field: Constants.Firestore.Key.name,
                                     value: selectSocial.text!,
                                     blink: socialList)
                    
                    uploadSocialData(field: Constants.Firestore.Key.link,
                                     value: socialProfile.text!.replacingOccurrences(of: " ", with: ""),
                                     blink: socialList)
                    
                    selectSocial.text?.removeAll()
                    socialProfile.text?.removeAll()
                    getSocialData()
                } else {
                    self.view.endEditing(true)
                    PopUp().popUpWithOk(newTitle: "Social Media exist",
                                        newMessage: "You can only add one \(selectSocial.text!) Profile for \(self.selectLocation.text!).",
                                        vc: self)
                }
                
            } else if socialMediaList.count == 2 {
                blockSameSocialNetwork(name: selectSocial.text!)
                
                if socialExist == false {
                    
                    uploadSocialData(field: Constants.Firestore.Key.name,
                                     value: selectSocial.text!,
                                     blink: socialList)
                    
                    uploadSocialData(field: Constants.Firestore.Key.link,
                                     value: socialProfile.text!.replacingOccurrences(of: " ", with: ""),
                                     blink: socialList)
                    
                    selectSocial.text?.removeAll()
                    socialProfile.text?.removeAll()
                    getSocialData()
                } else {
                    self.view.endEditing(true)
                    PopUp().popUpWithOk(newTitle: "Social Media exist",
                                        newMessage: "You can only add one \(selectSocial.text!) Profile for \(self.selectLocation.text!).",
                                        vc: self)
                }
                
            } else if socialMediaList.count == 3 {
                blockSameSocialNetwork(name: selectSocial.text!)
                
                if socialExist == false {
                    
                    uploadSocialData(field: Constants.Firestore.Key.name,
                                     value: selectSocial.text!,
                                     blink: socialList)
                    
                    uploadSocialData(field: Constants.Firestore.Key.link,
                                     value: socialProfile.text!.replacingOccurrences(of: " ", with: ""),
                                     blink: socialList)
                    
                    selectSocial.text?.removeAll()
                    socialProfile.text?.removeAll()
                    getSocialData()
                } else {
                    self.view.endEditing(true)
                    PopUp().popUpWithOk(newTitle: "Social Media exist",
                                        newMessage: "You can only add one \(selectSocial.text!) Profile for \(self.selectLocation.text!).",
                                        vc: self)
                }
                
            } else if socialMediaList.count == 4 {
                blockSameSocialNetwork(name: selectSocial.text!)
                
                if socialExist == false {
                    
                    uploadSocialData(field: Constants.Firestore.Key.name,
                                     value: selectSocial.text!,
                                     blink: socialList)
                    
                    uploadSocialData(field: Constants.Firestore.Key.link,
                                     value: socialProfile.text!.replacingOccurrences(of: " ", with: ""),
                                     blink: socialList)
                    
                    selectSocial.text?.removeAll()
                    socialProfile.text?.removeAll()
                    getSocialData()
                } else {
                    self.view.endEditing(true)
                    PopUp().popUpWithOk(newTitle: "Social Media exist",
                                        newMessage: "You can only add one \(selectSocial.text!) Profile for \(self.selectLocation.text!).",
                                        vc: self)
                }
                
            } else {
                self.view.endEditing(true)
                PopUp().popUpWithOk(newTitle: "Maximum reached",
                                    newMessage: "You can add Maximum 5 Social Media profiles for \n\(self.selectLocation.text!).",
                                    vc: self)
            }
            
        } else {
            self.view.endEditing(true)
            PopUp().popUpWithOk(newTitle: "Missing Social Profile",
                                newMessage: "Please Choose your Social Media and Enter your Profile Link.",
                                vc: self)
        }
        self.view.endEditing(true)
    }
    
    // MARK: - Block User to Add same Social Media
    func blockSameSocialNetwork(name: String) {
        socialExist = false
        
        if keySocialMedia.contains(name) == true {
            socialExist = true
        } else {
            socialExist = false
        }
    }

    // MARK: - Change Social Media Link Label Function
    func changeSocialLinkLabel() {
        socialProfile.text?.removeAll()
        socialProfile.attributedPlaceholder = NSAttributedString(
            string: "Select Social Media",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        
        if selectSocial.text == "Facebook" {
            linkToFinish.text = "facebook.com/"
            socialProfile.attributedPlaceholder = NSAttributedString(
                string: "Enter your Facebook Link...",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
            socialProfile.keyboardType = .default
        } else if selectSocial.text == "Instagram" {
            linkToFinish.text = "instagram.com/"
            socialProfile.attributedPlaceholder = NSAttributedString(
                string: "Enter your Instagram Link...",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
            socialProfile.keyboardType = .default
        } else if selectSocial.text == "TikTok" || selectSocial.text == "Twitter" || selectSocial.text == "Pinterest" {
            linkToFinish.text = "Username: @"
            socialProfile.attributedPlaceholder = NSAttributedString(
                string: "Enter your Name...",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
            socialProfile.keyboardType = .default
        } else if selectSocial.text == "Viber" || selectSocial.text == "WhatsApp" {
            linkToFinish.text = "Phone Number:"
            socialProfile.text = "\(phoneCode.text!)"
            socialProfile.keyboardType = .phonePad
        } else if selectSocial.text == "LinkedIn" {
            linkToFinish.text = "linkedin.com/in/"
            socialProfile.attributedPlaceholder = NSAttributedString(
                string: "Enter your Linked In Link...",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
            socialProfile.keyboardType = .default
        } else if selectSocial.text == "GitHub" {
            linkToFinish.text = "github.com/"
            socialProfile.attributedPlaceholder = NSAttributedString(
                string: "Enter your GitHub Link...",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
            socialProfile.keyboardType = .default
        } else if selectSocial.text == "YouTube" {
            linkToFinish.text = "youtube.com/channel/"
            socialProfile.attributedPlaceholder = NSAttributedString(
                string: "Enter your YouTube Link...",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
            socialProfile.keyboardType = .default
        } else if selectSocial.text == "Telegram" {
            linkToFinish.text = "t.me/"
            socialProfile.attributedPlaceholder = NSAttributedString(
                string: "Enter Phone Number or Link...",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
            socialProfile.keyboardType = .default
        }
    }
    
    // MARK: - Show Phone List
    @IBAction func showPhoneListPressed(_ sender: UIButton) {
        phoneListPressed = true
        rowDeleted = false
        
        DispatchQueue.main.async {
            self.getContactData()
        }
        self.view.endEditing(true)
    }
    
    // MARK: - Show Email List
    @IBAction func showEmailPressed(_ sender: UIButton) {
        emailListPressed = true
        rowDeleted = false
        
        DispatchQueue.main.async {
            self.getContactData()
        }
        self.view.endEditing(true)
    }
    
    // MARK: - Show Website List
    @IBAction func showWebsitePressed(_ sender: UIButton) {
        websiteListPressed = true
        rowDeleted = false
        
        DispatchQueue.main.async {
            self.getContactData()
        }
        self.view.endEditing(true)
    }
    
    // MARK: - Show Social Media List
    @IBAction func showSocialPressed(_ sender: UIButton) {
        socialListPressed = true
        rowDeleted = false
        
        DispatchQueue.main.async {
            self.getSocialData()
        }
        self.view.endEditing(true)
    }
    
    // MARK: - PopUp with TableView Back button Pressed
    @objc func popUpBackButtonPressed() {
        dismissPopUpWithTableView()
        
        phoneListPressed = false
        emailListPressed = false
        websiteListPressed = false
        socialListPressed = false
        rowDeleted = false
    }
    
}//

// MARK: - Upload Data to Firebase

extension AddStep3VC {
    
    // MARK: - Upload Contact Data

    func uploadContactData(field: String, value: String, button: UIButton) {
        // Adding Contact Info for Multiple Places
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.locations)
            .document(selectLocation.text!)
            .setData(["\(field)":"\(value)"], merge: true) { error in
                
                if error != nil {
                    PopUp().popUpWithOk(newTitle: "Error!",
                                        newMessage: "Error Uploading Contact Info to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)",
                                        vc: self)
                } else {
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
                .document(cardID)
                .collection(Constants.Firestore.CollectionName.locations)
                .document(selectLocation.text!)
                .collection(Constants.Firestore.CollectionName.social)
                .document(selectSocial.text!)
                .setData(["\(field)":"\(value)"], merge: true) { error in
                    
                    if error != nil {
                        PopUp().popUpWithOk(newTitle: "Error!",
                                            newMessage: "Error Uploading Social Media Info to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)",
                                            vc: self)
                    } else {
                        
                        self.db.collection(Constants.Firestore.CollectionName.VBC)
                            .document(Constants.Firestore.CollectionName.data)
                            .collection(Constants.Firestore.CollectionName.users)
                            .document(self.user!)
                            .collection(Constants.Firestore.CollectionName.cardID)
                            .document(self.cardID)
                            .collection(Constants.Firestore.CollectionName.locations)
                            .document(self.selectLocation.text!)
                            .setData(["Social Media Added" : true], merge: true)
                        
                        self.linkStack.isHidden = true
                        self.finishButton.isEnabled = true
                        self.infoForPlace.updateValue(true, forKey: self.selectLocation.text!)
                        self.blinkButton(buttonName: blink)
                    }
                }
    }
    
}

// MARK: - Get Data From Firebase

extension AddStep3VC {
    
    // MARK: - Get List of Location(s)
    func getLocationList() {

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
                      
                        for documents in snapshotDocuments {
                            
                            let data = documents.data()
                            
                            if let cityName = data[Constants.Firestore.Key.city] as? String {
                                if let cityStreet = data[Constants.Firestore.Key.street] as? String {
                                    if let cityMap = data[Constants.Firestore.Key.gMaps] as? String {
                                        
                                        let places = Location(city: cityName, street: cityStreet, gMapsLink: cityMap)
                                        
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
                                        
                                        if self.editCard3 == true {
                                            self.selectLocation.text = self.editCardLocation
                                        }
                                        
                                        self.getContactData()
                                        self.getSocialData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    // MARK: - Get Social Media List to pick from PickerView
    func getSocialMediaList() {
        
        db.collection(Constants.Firestore.CollectionName.social).getDocuments { snapshot, error in
            
            if let e = error {
                PopUp().popUpWithOk(newTitle: "Error!",
                                    newMessage: "Error Getting data from Database. Please Check your Internet connection and try again. \(e.localizedDescription)",
                                    vc: self)
            } else {
                
                if let snapshotDocuments = snapshot?.documents {
                    
                    for documents in snapshotDocuments {
                        
                        let data = documents.data()
                        
                        if let socialNetworkData = data[Constants.Firestore.Key.name] as? String {
                            
                            let socialNetwork = SocialMedia(name: socialNetworkData)
                            
                            self.selectSocialMedia.append(socialNetwork)
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
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.locations)
            .document(selectLocation.text!)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error getting Multiple Places Info. \(e)")
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let data = document!.data()
                            
                        
                        self.keyPhoneNumbersList.removeAll()
                            self.phoneNumbersList.removeAll()
                            // Phone Contact Info
                            if let phoneCode1 = data![Constants.Firestore.Key.phone1code] as? String {
                                if let phone1Number = data![Constants.Firestore.Key.phone1] as? String {
                                    
                                    if phone1Number != "" {
                                        let number = PhoneNumber(code: phoneCode1,
                                                                 number: phone1Number,
                                                                 field: Constants.Firestore.Key.phone1)
                                        self.phoneNumbersList.append(number)
                                    }
                                }
                            }
                            
                            if let phoneCode2 = data![Constants.Firestore.Key.phone2code] as? String {
                                if let phone2Number = data![Constants.Firestore.Key.phone2] as? String {
                                    
                                    if phone2Number != "" {
                                        let number = PhoneNumber(code: phoneCode2,
                                                                 number: phone2Number,
                                                                 field: Constants.Firestore.Key.phone2)
                                        self.phoneNumbersList.append(number)
                                    }
                                }
                            }
                            
                            if let phoneCode3 = data![Constants.Firestore.Key.phone3code] as? String {
                                if let phone3Number = data![Constants.Firestore.Key.phone3] as? String {
                                    
                                    if phone3Number != "" {
                                        let number = PhoneNumber(code: phoneCode3,
                                                                 number: phone3Number,
                                                                 field: Constants.Firestore.Key.phone3)
                                        self.phoneNumbersList.append(number)
                                    }
                                }
                            }
                        
                        for item in self.phoneNumbersList {
                            self.keyPhoneNumbersList.append(item.field)
                        }
                        
                        if self.phoneListPressed == true {
                            if self.rowDeleted == false {
                                DispatchQueue.main.async {
                                    self.popUpWithTableView(rows: self.phoneNumbersList.count, type: "Phone")
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.popUpTableView.rowDeleted(numberOfRows: self.phoneNumbersList.count)
                                }
                            }
                        }
                        
                    
                        // Email Contact Info
                        self.keyEmailAddressList.removeAll()
                            self.emailAddressList.removeAll()
                            
                            if let email1Address = data![Constants.Firestore.Key.email1] as? String {
                                if email1Address != "" {
                                    let email = Email(address: email1Address,
                                                      key: Constants.Firestore.Key.email1)
                                    self.emailAddressList.append(email)
                                }
                            }
                            if let email2Address = data![Constants.Firestore.Key.email2] as? String {
                                if email2Address != "" {
                                    let email = Email(address: email2Address,
                                                      key: Constants.Firestore.Key.email2)
                                    self.emailAddressList.append(email)
                                }
                            }
                        
                        for item in self.emailAddressList {
                            self.keyEmailAddressList.append(item.key)
                        }
                        
                        if self.emailListPressed == true {
                            if self.rowDeleted == false {
                                DispatchQueue.main.async {
                                    self.popUpWithTableView(rows: self.emailAddressList.count, type: "Email")
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.popUpTableView.rowDeleted(numberOfRows: self.emailAddressList.count)
                                }
                            }
                        }
                        
                        // Website Contact Info
                        self.keyWebsiteList.removeAll()
                            self.websiteList.removeAll()
                            
                            if let web1Link = data![Constants.Firestore.Key.web1] as? String {
                                if web1Link != "" {
                                    let web = Website(link: web1Link,
                                                      key: Constants.Firestore.Key.web1)
                                    self.websiteList.append(web)
                                }
                            }
                            if let web2Link = data![Constants.Firestore.Key.web2] as? String {
                                if web2Link != "" {
                                    let web = Website(link: web2Link,
                                                      key: Constants.Firestore.Key.web2)
                                    self.websiteList.append(web)
                                }
                            }
                        
                        for item in self.websiteList {
                            self.keyWebsiteList.append(item.key)
                        }
                        
                        if self.websiteListPressed == true {
                            if self.rowDeleted == false {
                                DispatchQueue.main.async {
                                    self.popUpWithTableView(rows: self.websiteList.count, type: "Website")
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.popUpTableView.rowDeleted(numberOfRows: self.websiteList.count)
                                }
                            }
                        }
                        
                    }
                }
            }
    }
    
    // MARK: - Get Social Media Data
    func getSocialData() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.locations)
            .document(selectLocation.text!)
            .collection(Constants.Firestore.CollectionName.social)
            .getDocuments { snapshot, error in
                
                if let e = error {
                    print ("Error getting Social Media List. \(e)")
                } else {
                    
                    self.keySocialMedia.removeAll()
                    self.socialMediaList.removeAll()
                    
                    if let snapshotDocuments = snapshot?.documents {
                        
                        for documents in snapshotDocuments {
                            
                            let data = documents.data()
                            
                            if let socialName = data[Constants.Firestore.Key.name] as? String {
                                
                                let social = SocialMedia(name: socialName)
                        
                                self.keySocialMedia.append(social.name)
                                self.socialMediaList.append(social)
                            }
                        }
                    }
                    
                    if self.socialListPressed == true {
                        if self.rowDeleted == false {
                            DispatchQueue.main.async {
                                self.popUpWithTableView(rows: self.socialMediaList.count, type: "Social")
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.popUpTableView.rowDeleted(numberOfRows: self.socialMediaList.count)
                            }
                        }
                    }
                    
                }
            }
    }
    
}

// MARK: - UIPickerView for Location and Social Media

extension AddStep3VC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if selectLocation.isEditing {
            return locationsList.count
        } else if selectSocial.isEditing {
            return selectSocialMedia.count
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if selectLocation.isEditing {
            return "\(locationsList[row].city) - \(locationsList[row].street)"
        } else if selectSocial.isEditing {
            return selectSocialMedia[row].name
        } else {
            return "Error adding Title for Row."
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if selectLocation.isEditing {
            selectLocation.text = "\(locationsList[row].city) - \(locationsList[row].street)"
            
        } else if selectSocial.isEditing {
            selectSocial.text = selectSocialMedia[row].name
            changeSocialLinkLabel()
            linkStack.isHidden = false
            socialProfile.becomeFirstResponder()
        }
        else {
            PopUp().popUpWithOk(newTitle: "Error!",
                                newMessage: "There was an Error when selected row. Please try again.",
                                vc: self)
        }
    }
}

// MARK: - TableView and Cell Delete Delegate

extension AddStep3VC: UITableViewDelegate, UITableViewDataSource, DeleteCellDelegate {
    
    func deleteButtonPressed(with title: String, row: Int) {
        
        // Pop Up with Yes and No
        let alert = UIAlertController(title: "Delete?", message: "Are you sure that you want to delete? Data will be lost forever.", preferredStyle: .alert)
        let actionBACK = UIAlertAction(title: "Back", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        let actionDELETE = UIAlertAction(title: "Delete", style: .destructive) { [self] action in
            
            if phoneListPressed == true || emailListPressed == true || websiteListPressed == true {
                
                let fieldKey = getKeyForDelete(rowNumber: row)
                
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(user!)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(cardID)
                    .collection(Constants.Firestore.CollectionName.locations)
                    .document(selectLocation.text!)
                    .updateData(["\(fieldKey)": FieldValue.delete()], completion: { [self] err in
                        if let e = err {
                            PopUp().popUpWithOk(newTitle: "Error",
                                                newMessage: "Error Deleting Contact Info. \(e)",
                                                vc: self)
                        } else {
                            
                            rowDeleted = true
                            
                            if phoneListPressed == true {
                                
                                if phoneNumbersList.count == 1 {
                                    dismissPopUpWithTableView()
                                }
                                getContactData()
                                
                            } else if emailListPressed == true {

                                if emailAddressList.count == 1 {
                                    dismissPopUpWithTableView()
                                }
                                getContactData()
                                
                            } else if websiteListPressed == true {

                                if websiteList.count == 1 {
                                    dismissPopUpWithTableView()
                                }
                                getContactData()
                            }
                        }
                    })
            
            }
            
            if socialListPressed == true {

                let documentName = title
                
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(user!)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(cardID)
                    .collection(Constants.Firestore.CollectionName.locations)
                    .document(selectLocation.text!)
                    .collection(Constants.Firestore.CollectionName.social)
                    .document(documentName)
                    .delete { err in
                        if let e = err {
                            PopUp().popUpWithOk(newTitle: "Error",
                                                newMessage: "Error Deleting Social Media. \(e)",
                                                vc: self)
                        } else {
                            
                            self.rowDeleted = true

                            if self.socialMediaList.count == 1 {
                                self.dismissPopUpWithTableView()
                            }
                            self.getSocialData()
                            
                        }
                    }
            }
        }

        alert.addAction(actionDELETE)
        alert.addAction(actionBACK)

        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Get Key for Deleted Button
    
    func getKeyForDelete(rowNumber: Int) -> String {
        
        if phoneListPressed == true {
            return phoneNumbersList[rowNumber].field
        } else if emailListPressed == true {
            return emailAddressList[rowNumber].key
        } else if websiteListPressed == true {
            return websiteList[rowNumber].key
        } else {
            return ""
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if phoneListPressed == true {
            return phoneNumbersList.count
        } else if emailListPressed == true {
            return emailAddressList.count
        } else if websiteListPressed == true {
            return websiteList.count
        } else {
            return socialMediaList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.contactListCell, for: indexPath) as! ContactListCell
        
        if phoneListPressed == true {
            cell.configure(title: "\(phoneNumbersList[indexPath.row].code) \(phoneNumbersList[indexPath.row].number)", row: indexPath.row)
        } else if emailListPressed == true {
            cell.configure(title: emailAddressList[indexPath.row].address, row: indexPath.row)
        } else if websiteListPressed == true {
            cell.configure(title: websiteList[indexPath.row].link, row: indexPath.row)
        } else {
            cell.configure(title: socialMediaList[indexPath.row].name, row: indexPath.row)
        }
        
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UI Settings
extension AddStep3VC {
    
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
                                               nibName: Constants.Nib.contactListCell,
                                               cellIdentifier: Constants.Cell.contactListCell)
        self.popUpTableView.backButton.addTarget(self, action: #selector(self.popUpBackButtonPressed), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.popUpTableView)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func dismissPopUpWithTableView() {
        popUpTableView.animateOut(forView: popUpTableView.popUpView, mainView: popUpTableView)
        popUpTableView.animateOut(forView: popUpTableView.blurEffectView, mainView: popUpTableView)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
