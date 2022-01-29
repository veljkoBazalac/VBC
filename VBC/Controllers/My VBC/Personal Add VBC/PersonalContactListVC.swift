//
//  PersonalContactListVC.swift
//  VBC
//
//  Created by VELJKO on 1.1.22..
//

import UIKit
import Firebase

protocol PhoneNumberListDelegate: AnyObject {
    func newPhoneNumberList(list: [PhoneNumber])
    func deletedPhoneNumber(atRow: Int)
}

protocol SocialListDelegate: AnyObject {
    func deletedSocialMedia(rowTitle: String, atRow: Int)
    func newSocialMediaList(list: [String])
}

class PersonalContactListVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Auth Current User
    let user = Auth.auth().currentUser?.uid
    
    var phoneNumbers : [PhoneNumber] = []
    
    // Delegate for Protocols
    weak var delegate : PhoneNumberListDelegate?
    weak var delegateCD : NumberOfContactDataDelegate?
    weak var delegateSL : SocialListDelegate?
    // Card ID
    var cardID : String = ""
    // Pop Up Title
    var popUpTitle : String?
    // Social Media List
    var socialMediaList : [SocialMedia] = []
    // Array of Keys for Social Media
    var keySocialMedia : [String] = []
    // List of Email Addresses
    var emailAddressList : [String] = []
    // Array of Keys for Email Addresses
    var keyEmailList : [String] = []
    // List of Website Links
    var websiteList : [String] = []
    // Array of Keys for Website Links
    var keyWebsiteList : [String] = []
    
    // Var that show which Button is pressed on previous View Controller
    var phoneListPressed : Bool = false
    var socialListPressed : Bool = false
    var emailListPressed : Bool = false
    var websiteListPressed : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = popUpTitle
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.Nib.addLocList, bundle: nil), forCellReuseIdentifier: Constants.Cell.addLocListCell)
        
        getData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if phoneListPressed == true {
            delegate?.newPhoneNumberList(list: phoneNumbers)
        } else if socialListPressed == true {
            delegateSL?.newSocialMediaList(list: keySocialMedia)
        }
    }
    
    // MARK: - Get Data from Firebase
    
    func getData() {
        
        if socialListPressed == true {
            getSocialData()
        } else if emailListPressed == true || websiteListPressed == true {
            getEWData()
        }
    }
    
    // MARK: - Get Data for Email and Website
    
    func getEWData() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(user!)
            .document(cardID)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error getting Email & Website Info. \(e)")
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let data = document!.data()
                        
                        if self.emailListPressed == true {
                            
                            self.emailAddressList = []
                            
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
                            
                            self.websiteList = []
                            
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
    
    // MARK: - Get Data for Social Media
    
    func getSocialData() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(user!)
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.social)
            .getDocuments { snapshot, error in
                
                if let e = error {
                    print ("Error getting Social Media List. \(e)")
                } else {
                    
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
    
    // MARK: - Get Key for Deleted Button
        
        func getKey(rowNumber: Int) -> String? {
            
            if socialListPressed == true {
                return keySocialMedia[rowNumber]
            } else if emailListPressed == true {
                return keyEmailList[rowNumber]
            } else if websiteListPressed == true {
                return keyWebsiteList[rowNumber]
            }
            
            return nil
        }
    
}
// MARK: - Delete Table View Cell

extension PersonalContactListVC: DeleteCellDelegate {
    
    func deleteButtonPressed(with title: String, row: Int) {
        
        // Pop Up with Yes and No
        let alert = UIAlertController(title: "Delete?", message: "Are you sure that you want to delete? Data will be lost forever.", preferredStyle: .alert)
        let actionBACK = UIAlertAction(title: "Back", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        let actionDELETE = UIAlertAction(title: "Delete", style: .destructive) { [self] action in
            
            let documentName = title
            let fieldKey = getKey(rowNumber: row)
            
            if phoneListPressed == true {
                phoneNumbers.remove(at: row)
                tableView.reloadData()
                delegate?.deletedPhoneNumber(atRow: row)
                
            } else if socialListPressed == true {
                
                    db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.data)
                        .collection(user!)
                        .document(cardID)
                        .collection(Constants.Firestore.CollectionName.social)
                        .document(documentName)
                        .delete()
                    
                if socialMediaList.count == 1 {
                    socialMediaList.removeAll()
                    self.dismiss(animated: true, completion: nil)
                }
                
                socialMediaList.removeAll()
                keySocialMedia.removeAll()
                getSocialData()
                
                delegateSL?.deletedSocialMedia(rowTitle: title, atRow: row)
                delegateCD?.keyForContactData(key: title)
                
            } else if emailListPressed == true  || websiteListPressed == true {
                
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(user!)
                    .document(cardID)
                    .updateData(["\(fieldKey!)": FieldValue.delete()])
                
                if emailListPressed == true {
                    emailAddressList.removeAll()
                    getEWData()
                } else {
                    websiteList.removeAll()
                    getEWData()
                }
                
                if emailAddressList.count < 1 || websiteList.count < 1 {
                    self.dismiss(animated: true, completion: nil)
                }
                delegateCD?.keyForContactData(key: fieldKey!)
            }
            
        }
        
        alert.addAction(actionDELETE)
        alert.addAction(actionBACK)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension PersonalContactListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if phoneListPressed == true {
            return phoneNumbers.count
        } else if socialListPressed == true {
            return socialMediaList.count
        } else if emailListPressed == true {
            return emailAddressList.count
        } else {
            return websiteList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.addLocListCell, for: indexPath) as! AddLocListTableViewCell
        
        if phoneListPressed == true {
            cell.configure(with: "\(phoneNumbers[indexPath.row].code) \(phoneNumbers[indexPath.row].number)", row: indexPath.row)
        } else if socialListPressed == true {
            cell.configure(with: socialMediaList[indexPath.row].name, row: indexPath.row)
        } else if emailListPressed == true {
            cell.configure(with: emailAddressList[indexPath.row], row: indexPath.row)
        } else {
            cell.configure(with: websiteList[indexPath.row], row: indexPath.row)
        }
        
        cell.delegate = self
        return cell
    }
    
}
