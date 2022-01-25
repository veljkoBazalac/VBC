//
//  PAdd3VC.swift
//  VBC
//
//  Created by VELJKO on 25.12.21..
//

import UIKit
import Firebase

class PAdd3VC: UIViewController {
    
    // Basic Info Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var personalName: UILabel!
    @IBOutlet weak var personalSector: UILabel!
    @IBOutlet weak var personalProductType: UILabel!
    
    // Outlets for Social Network
    @IBOutlet weak var selectSocial: UITextField!
    @IBOutlet weak var socialProfile: UITextField!
    @IBOutlet weak var addSocial: UIButton!
    @IBOutlet weak var socialList: UIButton!
    @IBOutlet weak var linkToFinish: UILabel!
    
    // Outlets for Email Address
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var addEmail: UIButton!
    @IBOutlet weak var emailList: UIButton!
    
    // Outlets for Website
    @IBOutlet weak var websiteLink: UITextField!
    @IBOutlet weak var addWebsite: UIButton!
    @IBOutlet weak var websiteList: UIButton!
    @IBOutlet weak var wwwLabel: UILabel!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Auth Current User
    let user = Auth.auth().currentUser?.uid
    
    // Picker View
    var pickerView = UIPickerView()
    // Show Pop Up or No
    var showPopUp : Bool = true
    
    // Basic Info from 1st Step
    var personalImage3 : UIImage?
    var personalName3 : String = ""
    var personalSector3 : String = ""
    var personalProductType3 : String = ""
    
    // Location Info from 2nd Step
    var personalCardID : String = ""
    var phoneCodeNumber : String = ""
    
    // Social Networks List Dict
    private var socialMediaList : [SocialMedia] = []
    private var socialMediaNames : [String] = []
    private var socialExist : Bool = false
    
    var social1 : String = ""
    var social2 : String = ""
    var social3 : String = ""
    var social4 : String = ""
    var social5 : String = ""
    
    var email1 : String = ""
    var email2 : String = ""
    
    var web1 : String = ""
    var web2 : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = personalImage3
        personalName.text = personalName3
        personalSector.text = personalSector3
        personalProductType.text = personalProductType3
        
        getSocialMediaList()
        
        selectSocial.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    // MARK: - Finish NavBar Button Presssed
    
    @IBAction func finishButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.Segue.pAddFinish, sender: self)
    }
    
    
    func blockSameSocialNetwork(name: String) {
        
        socialExist = false
        
        if socialMediaNames.contains(name) == true {
            socialExist = true
        } else {
            socialExist = false
        }
        
    }
    
    // MARK: - Add Social Media Button Pressed
    
    @IBAction func addSocialButtonPressed(_ sender: UIButton) {
        
        // Adding Social Media to Firestore
        if socialProfile.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
            if social1.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                social1 = selectSocial.text!
                blockSameSocialNetwork(name: social1)
                
                if socialExist == false {
                    
                    showPopUp = false
                    uploadContactData(field: Constants.Firestore.Key.name, value: social1, pressed: addSocial, blink: socialList)
                    
                    showPopUp = true
                    uploadContactData(field: Constants.Firestore.Key.link, value: socialProfile.text!, pressed: addSocial, blink: socialList)
                    
                    socialMediaNames.append(social1)
                    selectSocial.text = .none
                    socialProfile.text = .none
                    
                } else {
                    popUpWithOk(newTitle: "Social Media exist", newMessage: "You can only add one \(social1) Profile.")
                    social1 = ""
                }
                
            } else if social2.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                social2 = selectSocial.text!
                blockSameSocialNetwork(name: social2)
                
                if socialExist == false {
                    
                    showPopUp = false
                    uploadContactData(field: Constants.Firestore.Key.name, value: social2, pressed: addSocial, blink: socialList)
                    
                    showPopUp = true
                    uploadContactData(field: Constants.Firestore.Key.link, value: socialProfile.text!, pressed: addSocial, blink: socialList)
                    
                    socialMediaNames.append(social2)
                    selectSocial.text = .none
                    socialProfile.text = .none
                    
                } else {
                    popUpWithOk(newTitle: "Social Media exist", newMessage: "You can only add one \(social2) Profile.")
                    social2 = ""
                }
                
            } else if social3.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                social3 = selectSocial.text!
                blockSameSocialNetwork(name: social3)
                
                if socialExist == false {
                    
                    showPopUp = false
                    uploadContactData(field: Constants.Firestore.Key.name, value: social3, pressed: addSocial, blink: socialList)
                    
                    showPopUp = true
                    uploadContactData(field: Constants.Firestore.Key.link, value: socialProfile.text!, pressed: addSocial, blink: socialList)
                    
                    socialMediaNames.append(social3)
                    selectSocial.text = .none
                    socialProfile.text = .none
                    
                } else {
                    popUpWithOk(newTitle: "Social Media exist", newMessage: "You can only add one \(social3) Profile.")
                    social3 = ""
                }
                
            } else if social4.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                social4 = selectSocial.text!
                blockSameSocialNetwork(name: social4)
                
                if socialExist == false {
                    
                    showPopUp = false
                    uploadContactData(field: Constants.Firestore.Key.name, value: social4, pressed: addSocial, blink: socialList)
                    
                    showPopUp = true
                    uploadContactData(field: Constants.Firestore.Key.link, value: socialProfile.text!, pressed: addSocial, blink: socialList)
                    
                    socialMediaNames.append(social4)
                    selectSocial.text = .none
                    socialProfile.text = .none
                    
                } else {
                    popUpWithOk(newTitle: "Social Media exist", newMessage: "You can only add one \(social4) Profile.")
                    social4 = ""
                }
                
            } else if social5.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                social5 = selectSocial.text!
                blockSameSocialNetwork(name: social5)
                
                if socialExist == false {
                    
                    showPopUp = false
                    uploadContactData(field: Constants.Firestore.Key.name, value: social5, pressed: addSocial, blink: socialList)
                    
                    showPopUp = true
                    uploadContactData(field: Constants.Firestore.Key.link, value: socialProfile.text!, pressed: addSocial, blink: socialList)
                    
                    socialMediaNames.append(social5)
                    selectSocial.text = .none
                    socialProfile.text = .none
                    
                } else {
                    popUpWithOk(newTitle: "Social Media exist", newMessage: "You can only add one \(social5) Profile.")
                    social5 = ""
                }
                
            } else {
                popUpWithOk(newTitle: "Maximum reached", newMessage: "You can add Maximum 5 Social Media profiles.")
            }
            
        } else {
            popUpWithOk(newTitle: "Missing Social Profile", newMessage: "Please Choose your Social Media and Enter your Profile Link.")
        }
    }
    
    // MARK: - Add Email Button Pressed
    
    @IBAction func addEmailButtonPressed(_ sender: UIButton) {
        
        // Adding Emails to Firestore
        if emailAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
            if email1.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                email1 = emailAddress.text!
                
                uploadContactData(field: Constants.Firestore.Key.email1, value: email1, pressed: addEmail, blink: emailList)
                emailAddress.text = .none
            } else if email2.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                email2 = emailAddress.text!
                
                uploadContactData(field: Constants.Firestore.Key.email2, value: email2, pressed: addEmail, blink: emailList)
                emailAddress.text = .none
            } else {
                popUpWithOk(newTitle: "Maximum reached", newMessage: "You can add Maximum 2 Email Addresses to your VBC.")
            }
            
        } else {
            popUpWithOk(newTitle: "Missing Email", newMessage: "Please Enter your Email Address.")
        }
    }
    
    
    // MARK: - Add Website Button Pressed
    
    @IBAction func addWebsiteButtonPressed(_ sender: UIButton) {
        
        // Adding Websites to Firestore
        if websiteLink.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            
            if web1.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                web1 = websiteLink.text!
                
                uploadContactData(field: Constants.Firestore.Key.web1, value: "\(wwwLabel.text!)\(web1)", pressed: addWebsite, blink: websiteList)
                websiteLink.text = .none
            } else if web2.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                web2 = websiteLink.text!
                
                uploadContactData(field: Constants.Firestore.Key.web2, value: "\(wwwLabel.text!)\(web2)", pressed: addWebsite, blink: websiteList)
                websiteLink.text = .none
            } else {
                popUpWithOk(newTitle: "Maximum reached", newMessage: "You can add Maximum 2 Website Links to your VBC.")
            }
            
        } else {
            popUpWithOk(newTitle: "Missing Website Link", newMessage: "Please Enter your Website Link.")
        }
    }
    
    
    // MARK: - Show Social List Button Pressed
    
    @IBAction func showSocialList(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segue.pSocialList, sender: self)
    }
    
    
    // MARK: - Show Email List Button Pressed
    
    @IBAction func showEmailList(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segue.pEmailList, sender: self)
    }
    
    
    // MARK: - Show Website List Button Pressed
    
    @IBAction func showWebsiteList(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.Segue.pWebList, sender: self)
    }
    
  // MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.pSocialList {
            
            let destinationVC = segue.destination as! PersonalContactListVC
            
            destinationVC.popUpTitle = "Social Media"
            destinationVC.socialListPressed = true
            destinationVC.cardID = personalCardID
            destinationVC.delegateCD = self
            destinationVC.delegateSL = self
            
        }
        
        if segue.identifier == Constants.Segue.pEmailList {
            
            let destinationVC = segue.destination as! PersonalContactListVC
            
            destinationVC.popUpTitle = "Email Address"
            destinationVC.emailListPressed = true
            destinationVC.cardID = personalCardID
            destinationVC.delegateCD = self
            
        }
        
        if segue.identifier == Constants.Segue.pWebList {
            
            let destinationVC = segue.destination as! PersonalContactListVC
            
            destinationVC.popUpTitle = "Website Link"
            destinationVC.websiteListPressed = true
            destinationVC.cardID = personalCardID
            destinationVC.delegateCD = self
            
        }
    }
    
    // MARK: - Upload Contact Data
    
    func uploadContactData(field: String, value: String, pressed: UIButton , blink: UIButton) {
        
        if pressed != addSocial {
        // Adding Email and Website Data to Firestore
            db.collection(Constants.Firestore.CollectionName.VBC)
                .document(Constants.Firestore.CollectionName.personalCards)
                .collection(Constants.Firestore.CollectionName.users)
                .document(user!)
                .collection(Constants.Firestore.CollectionName.cardID)
                .document(personalCardID)
            .setData(["\(field)":"\(value)"], merge: true) { error in
                
                if error != nil {
                    self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading Contact Info to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)")
                } else {
                    
                    if pressed == self.addEmail {
                    self.popUpWithOk(newTitle: "Successfully added", newMessage: "Email Address successfully added.")
                    } else if pressed == self.addWebsite {
                    self.popUpWithOk(newTitle: "Successfully added", newMessage: "Website Link successfully added.")
                    }
                    self.blinkButton(buttonName: blink)
                }
            }
            
        } else {
            
            // Adding Social Media Data to Firestore
            db.collection(Constants.Firestore.CollectionName.VBC)
                .document(Constants.Firestore.CollectionName.personalCards)
                .collection(Constants.Firestore.CollectionName.users)
                .document(user!)
                .collection(Constants.Firestore.CollectionName.cardID)
                .document(personalCardID)
                .collection(Constants.Firestore.CollectionName.social)
                .document(selectSocial.text!)
                .setData(["\(field)":"\(value)"], merge: true) { error in
                    
                    if error != nil {
                        self.popUpWithOk(newTitle: "Error!", newMessage: "Error Uploading Social Media Info to Database. Please Check your Internet connection and try again. \(error!.localizedDescription)")
                    } else {
                        
                        if self.showPopUp == true {
                            
                        self.popUpWithOk(newTitle: "Successfully added", newMessage: "Social Media successfully added.")
                        }
                        self.blinkButton(buttonName: blink)
                    }
                }
            
            db.collection(Constants.Firestore.CollectionName.VBC)
                .document(Constants.Firestore.CollectionName.personalCards)
                .collection(Constants.Firestore.CollectionName.users)
                .document(user!)
                .collection(Constants.Firestore.CollectionName.cardID)
                .document(personalCardID)
                .setData(["Social Media Added" : true], merge: true)
        }
    }
    
    // MARK: - Get Social Network List Function
    
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
    
    
    // MARK: - Blink Button Function
    
    func blinkButton(buttonName: UIButton) {
        buttonName.tintColor = .green
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            buttonName.tintColor = UIColor(named: "Color Dark")
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
            socialProfile.text = phoneCodeNumber
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
    
}

// MARK: - UIPickerView

extension PAdd3VC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if selectSocial.isEditing {
            return socialMediaList.count
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if selectSocial.isEditing {
            return socialMediaList[row].name
        }
        else {
            return "Error adding Title for Row."
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if selectSocial.isEditing {
            selectSocial.text = socialMediaList[row].name
            changeLinkToFinishLabel()
        } else {
            self.popUpWithOk(newTitle: "Error!", newMessage: "There was an Error when selected row. Please try again.")
        }
    }
    
}

extension PAdd3VC: SocialListDelegate {
    
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

extension PAdd3VC: NumberOfContactDataDelegate {
    
    func keyForContactData(key: String) {
      
        if key == Constants.Firestore.Key.email1 {
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
