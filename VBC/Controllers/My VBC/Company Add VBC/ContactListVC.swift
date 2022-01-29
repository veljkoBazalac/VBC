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
    // Delegate for Protocol
    weak var delegate : NumberOfContactDataDelegate?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = popUpTitle
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.Nib.addLocList, bundle: nil), forCellReuseIdentifier: Constants.Cell.addLocListCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getData()
    }
    
    // MARK: - Get Data Function
    
    func getData() {
        if singlePlace == true {
            getSPContactData()
        } else if singlePlace == false {
            getMPContactData()
        }
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if phoneListPressed == true {
            return phoneNumbersList.count
        } else if emailListPressed == true {
            return emailAddressList.count
        } else {
            return websiteList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.addLocListCell, for: indexPath) as! AddLocListTableViewCell
        
        if phoneListPressed == true {
            cell.configure(with: "\(phoneNumbersList[indexPath.row].code)\(phoneNumbersList[indexPath.row].number)", row: indexPath.row)
        } else if emailListPressed == true {
            cell.configure(with: emailAddressList[indexPath.row], row: indexPath.row)
        } else {
            cell.configure(with: websiteList[indexPath.row], row: indexPath.row)
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
        } else {
            return keyWebsiteList[rowNumber]
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
            
            if phoneNumbersList.count > 1 || emailAddressList.count > 1 || websiteList.count > 1 {
                
                if singlePlace == true {
                    db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.data)
                        .collection(Constants.Firestore.CollectionName.users)
                        .document(user!)
                        .collection(Constants.Firestore.CollectionName.cardID)
                        .document(cardID)
                        .updateData(["\(fieldKey)": FieldValue.delete()])
                } else {
                    db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.data)
                        .collection(Constants.Firestore.CollectionName.users)
                        .document(user!)
                        .collection(Constants.Firestore.CollectionName.cardID)
                        .document(cardID)
                        .collection(Constants.Firestore.CollectionName.locations)
                        .document(dataForLocation!)
                        .updateData(["\(fieldKey)": FieldValue.delete()])
                }
                
                if phoneListPressed == true {
                    phoneNumbersList = []
                    getData()
                } else if emailListPressed == true {
                    emailAddressList = []
                    getData()
                } else {
                    websiteList = []
                    getData()
                }
                delegate?.keyForContactData(key: fieldKey)
            } else {
                
                if singlePlace == true {
                    db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.data)
                        .collection(Constants.Firestore.CollectionName.users)
                        .document(user!)
                        .collection(Constants.Firestore.CollectionName.cardID)
                        .document(cardID)
                        .updateData(["\(fieldKey)": FieldValue.delete()])
                } else {
                    
                    db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.data)
                        .collection(Constants.Firestore.CollectionName.users)
                        .document(user!)
                        .collection(Constants.Firestore.CollectionName.cardID)
                        .document(cardID)
                        .collection(Constants.Firestore.CollectionName.locations)
                        .document(dataForLocation!)
                        .updateData(["\(fieldKey)": FieldValue.delete()])
                }
                
                if phoneListPressed == true {
                    phoneNumbersList = []
                } else if emailListPressed == true {
                    emailAddressList = []
                } else {
                    websiteList = []
                }
                delegate?.keyForContactData(key: fieldKey)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        
        alert.addAction(actionDELETE)
        alert.addAction(actionBACK)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Get Multiple Places Contact Data
    
    func getMPContactData() {
        
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
                            
                            self.phoneNumbersList = []
                            
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
    
    // MARK: - Get Single Place Contact Data
    
    func getSPContactData() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .getDocument { document, error in
                
                if let e = error {
                    print ("Error getting Multiple Places Info. \(e)")
                } else {
                    
                    if document != nil && document!.exists {
                        
                        let data = document!.data()
                        
                        if self.phoneListPressed == true {
                            
                            self.phoneNumbersList = []
                            
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
    
}
