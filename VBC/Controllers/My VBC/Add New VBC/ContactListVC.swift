//
//  ContactListVC.swift
//  VBC
//
//  Created by VELJKO on 27.12.21..
//

import UIKit
import Firebase

protocol NumberOfContactDataDelegate: AnyObject {
    func keyForContactData(key: String)
}

protocol SocialListDelegate: AnyObject {
    func deletedSocialMedia(rowTitle: String, atRow: Int)
    func newSocialMediaList(list: [String])
}

class ContactListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DeleteCellDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Current Auth User ID
    let user = Auth.auth().currentUser?.uid
    // Card ID
    var cardID : String = ""
    // Single Place or Multiple Places
    var singlePlace : Bool = true
    // Var that show which Button is pressed on previous View Controller
    var phoneListPressed : Bool = false
    var emailListPressed : Bool = false
    var websiteListPressed : Bool = false
    var socialListPressed : Bool = false
    // Delegate for Protocol
    weak var delegateCD : NumberOfContactDataDelegate?
    weak var delegateSL : SocialListDelegate?
    // Pop Up Title
    var popUpTitle : String?
    // Data For Selected Location from Previous View Controller
    var dataForLocation : String?
    // List of Phone Numbers
    var phoneNumbersList : [PhoneNumber] = []
    // Array of Keys for Phone Numbers
    var keyNumbersList : [String] = []
    // List of Email Addresses
    var emailAddressList : [String] = []
    // Array of Keys for Email Addresses
    var keyEmailList : [String] = []
    // List of Website Links
    var websiteList : [String] = []
    // Array of Keys for Website Links
    var keyWebsiteList : [String] = []
    // Social Media List
    var socialMediaList : [SocialMedia] = []
    // Array of Keys for Social Media
    var keySocialMedia : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = popUpTitle
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
        
        tableView.register(UINib(nibName: Constants.Nib.contactListCell, bundle: nil), forCellReuseIdentifier: Constants.Cell.contactListCell)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        delegateSL?.newSocialMediaList(list: keySocialMedia)
    }
    
    // MARK: - Get Data Function
    func getData() {
        
        if socialListPressed == false {
            getContactData()
        } else {
            getSocialData()
        }
    }
    
    // MARK: - Table View
    
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
            cell.configure(title: "\(phoneNumbersList[indexPath.row].code)\(phoneNumbersList[indexPath.row].number)", row: indexPath.row)
        } else if emailListPressed == true {
            cell.configure(title: emailAddressList[indexPath.row], row: indexPath.row)
        } else if websiteListPressed == true {
            cell.configure(title: websiteList[indexPath.row], row: indexPath.row)
        } else {
            cell.configure(title: socialMediaList[indexPath.row].name, row: indexPath.row)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - Get Key for Deleted Button
    
    func getKey(rowNumber: Int) -> String {
        
        if phoneListPressed == true {
            return keyNumbersList[rowNumber]
        } else if emailListPressed == true {
            return keyEmailList[rowNumber]
        } else if websiteListPressed == true {
            return keyWebsiteList[rowNumber]
        } else {
            return keySocialMedia[rowNumber]
        }
        
    }
 
    // MARK: - Delete Cell Button Pressed
    
    func deleteButtonPressed(with title: String, row: Int) {
        
        // Pop Up with Yes and No
        let alert = UIAlertController(title: "Delete?", message: "Are you sure that you want to delete? Data will be lost forever.", preferredStyle: .alert)
        let actionBACK = UIAlertAction(title: "Back", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        let actionDELETE = UIAlertAction(title: "Delete", style: .destructive) { [self] action in
            
            let fieldKey = getKey(rowNumber: row)
            
            if phoneListPressed == true || emailListPressed == true || websiteListPressed || true {
                
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(user!)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(cardID)
                    .collection(Constants.Firestore.CollectionName.locations)
                    .document(dataForLocation!)
                    .updateData(["\(fieldKey)": FieldValue.delete()])
                
                if phoneListPressed == true {
                    
                    if phoneNumbersList.count == 1 {
                        phoneNumbersList.removeAll()
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    phoneNumbersList.removeAll()
                    getData()
                } else if emailListPressed == true {
                    
                    if emailAddressList.count == 1 {
                        emailAddressList.removeAll()
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    emailAddressList.removeAll()
                    getData()
                } else {
                    
                    if websiteList.count == 1 {
                        websiteList.removeAll()
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    websiteList.removeAll()
                    getData()
                }
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
                    .document(dataForLocation!)
                    .collection(Constants.Firestore.CollectionName.social)
                    .document(documentName)
                    .delete()
                
                if socialMediaList.count == 1 {
                    socialMediaList.removeAll()
                    self.dismiss(animated: true, completion: nil)
                }
                
                socialMediaList.removeAll()
                keySocialMedia.removeAll()
                getData()
                
                delegateSL?.deletedSocialMedia(rowTitle: title, atRow: row)
            }
            delegateCD?.keyForContactData(key: fieldKey)
        }
        
        alert.addAction(actionDELETE)
        alert.addAction(actionBACK)
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Getting Contact Data from Firebase

extension ContactListVC {
    
    func getContactData() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.locations)
            .document(dataForLocation!)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error getting Multiple Places Info. \(e)")
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let data = document!.data()
                        
                        if self.phoneListPressed == true {
                            
                            self.phoneNumbersList.removeAll()
                            
                            // Phone Contact Info
                            if let phoneCode1 = data![Constants.Firestore.Key.phone1code] as? String {
                                if let phone1 = data![Constants.Firestore.Key.phone1] as? String {
                                    
                                    if phone1 != "" {
                                        let number = PhoneNumber(code: phoneCode1, number: phone1)
                                        let key = Constants.Firestore.Key.phone1
                                        self.phoneNumbersList.append(number)
                                        self.keyNumbersList.append(key)
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                            
                            if let phoneCode2 = data![Constants.Firestore.Key.phone2code] as? String {
                                if let phone2 = data![Constants.Firestore.Key.phone2] as? String {
                                    
                                    if phone2 != "" {
                                        let number = PhoneNumber(code: phoneCode2, number: phone2)
                                        let key = Constants.Firestore.Key.phone2
                                        self.phoneNumbersList.append(number)
                                        self.keyNumbersList.append(key)
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                            
                            if let phoneCode3 = data![Constants.Firestore.Key.phone3code] as? String {
                                if let phone3 = data![Constants.Firestore.Key.phone3] as? String {
                                    
                                    if phone3 != "" {
                                        let number = PhoneNumber(code: phoneCode3, number: phone3)
                                        let key = Constants.Firestore.Key.phone3
                                        self.phoneNumbersList.append(number)
                                        self.keyNumbersList.append(key)
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                        
                        if self.emailListPressed == true {
                            
                            self.emailAddressList.removeAll()
                            
                            // Email Contact Info
                            if let email1 = data![Constants.Firestore.Key.email1] as? String {
                                if email1 != "" {
                                    let key = Constants.Firestore.Key.email1
                                    self.keyEmailList.append(key)
                                    self.emailAddressList.append(email1)
                                    self.tableView.reloadData()
                                }
                            }
                            if let email2 = data![Constants.Firestore.Key.email2] as? String {
                                if email2 != "" {
                                    let key = Constants.Firestore.Key.email2
                                    self.keyEmailList.append(key)
                                    self.emailAddressList.append(email2)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                        
                        if self.websiteListPressed == true {
                            
                            self.websiteList.removeAll()
                            
                            // Website Contact Info
                            if let web1 = data![Constants.Firestore.Key.web1] as? String {
                                if web1 != "" {
                                    let key = Constants.Firestore.Key.web1
                                    self.keyWebsiteList.append(key)
                                    self.websiteList.append(web1)
                                    self.tableView.reloadData()
                                }
                            }
                            if let web2 = data![Constants.Firestore.Key.web2] as? String {
                                if web2 != "" {
                                    let key = Constants.Firestore.Key.web2
                                    self.keyWebsiteList.append(key)
                                    self.websiteList.append(web2)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                        
                    }
                }
            }
    }
}

// MARK: - Getting Data for Social Media from Firebase

extension ContactListVC {
    
    func getSocialData() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.locations)
            .document(dataForLocation!)
            .collection(Constants.Firestore.CollectionName.social)
            .getDocuments { snapshot, error in
                
                if let e = error {
                    print ("Error getting Social Media List. \(e)")
                } else {
                    
                    self.socialMediaList.removeAll()
                    
                    if let snapshotDocuments = snapshot?.documents {
                        
                        for documents in snapshotDocuments {
                            
                            let data = documents.data()
                            
                            if let socialName = data[Constants.Firestore.Key.name] as? String {
                                
                                let social = SocialMedia(name: socialName)
                                let key = social.name
                                
                                self.keySocialMedia.append(key)
                                self.socialMediaList.append(social)
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
    }
}
