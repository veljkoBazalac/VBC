//
//  myVBCViewController.swift
//  VBC
//
//  Created by VELJKO on 9.11.21..
//

import UIKit
import Firebase
import FirebaseStorage

class MyCardsVC: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Storage
    let storage = Storage.storage().reference()
    // Firebase Auth Current User
    let user = Auth.auth().currentUser?.uid
    // Company Cards Dictionary
    var companyCards : [ShowVBC] = []
    var companyCard : Bool = true
    // Personal Cards Dictionary
    var personalCards : [ShowVBC] = []
    
    var editedCardID : String = ""
    var editedCardRow : Int?
    var cardIsEdited : Bool = false
    var cardRowEdited : Int = 0
    
    var singlePlace : [Bool] = []
    var currentSegment0 : Bool = true
    
    // Notification Name
    let NotNameEditedCard = Notification.Name(rawValue: Constants.NotificationKey.cardEdited)
    let NotNameDeletedCard = Notification.Name(rawValue: Constants.NotificationKey.cardDeleted)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.Nib.homeViewCell, bundle: nil), forCellReuseIdentifier: Constants.Cell.homeCell)
        
        getCards()
        createObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: false)
        tableView.reloadData()
    }
    
    // MARK: - Observers for Edit and Delete
    func createObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyCardsVC.editedCard(notification:)), name: NotNameEditedCard, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyCardsVC.deletedCard(notification:)), name: NotNameDeletedCard, object: nil)
        
    }
    
    // MARK: - Edit Card Function
    @objc func editedCard(notification: NSNotification) {
        
        if notification.name == NotNameEditedCard {
            
            if let editedCardID = notification.object as? String {
                
                if let index = companyCards.firstIndex(where: {$0.cardID == editedCardID}) {
                    
                    cardIsEdited = true
                    cardRowEdited = index
                    
                    companyCards.remove(at: index)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
                if let index = personalCards.firstIndex(where: {$0.cardID == editedCardID}) {
                    
                    cardIsEdited = true
                    cardRowEdited = index
                    
                    personalCards.remove(at: index)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - Delete Card Function
    @objc func deletedCard(notification: NSNotification) {
        
        if notification.name == NotNameDeletedCard {
            
            if let deletedCardID = notification.object as? String {
                
                if let index = companyCards.firstIndex(where: {$0.cardID == deletedCardID}) {
                    
                    companyCards.remove(at: index)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
                if let index = personalCards.firstIndex(where: {$0.cardID == deletedCardID}) {
                    
                    personalCards.remove(at: index)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
    }
    
    // MARK: - Get Cards
    func getCards() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.cardID)
            .addSnapshotListener { snapshot, error in
                
                if let e = error {
                    print ("Error getting Cards Data. \(e)")
                } else {
                    
                    snapshot?.documentChanges.forEach({ diff in
                        
                        let data = diff.document.data()
                        
                        if diff.type == .added  {
                            
                            if let name = data[Constants.Firestore.Key.companyName] as? String {
                                if let sector = data[Constants.Firestore.Key.sector] as? String {
                                    if let productType = data[Constants.Firestore.Key.type] as? String {
                                        if let country = data[Constants.Firestore.Key.country] as? String {
                                            if let cardID = data[Constants.Firestore.Key.cardID] as? String {
                                                if let singlePlace = data[Constants.Firestore.Key.singlePlace] as? Bool {
                                                    if let companyCard = data[Constants.Firestore.Key.companyCard] as? Bool {
                                                        if let userID = data[Constants.Firestore.Key.userID] as? String {
                                                            if let imageURL = data[Constants.Firestore.Key.imageURL] as? String {
                                                                
                                                                if companyCard == false {
                                                                    if let personalName = data[Constants.Firestore.Key.personalName] as? String {
                                                                        
                                                                        let card = ShowVBC(personalName: personalName, companyName: name, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID, imageURL: imageURL)
                                                                        
                                                                        self.personalCards.append(card)
                                                                        
                                                                        DispatchQueue.main.async {
                                                                            self.tableView.reloadData()
                                                                        }
                                                                    }
                                                                } else {
                                                                    
                                                                    let card = ShowVBC(companyName: name, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID, imageURL: imageURL)
                                                                    
                                                                    self.companyCards.append(card)
                                                                    
                                                                    DispatchQueue.main.async {
                                                                        self.tableView.reloadData()
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
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                        
                        if diff.type == .modified {
                           
                            if self.cardIsEdited == true {
                  
                                if let name = data[Constants.Firestore.Key.companyName] as? String {
                                    if let sector = data[Constants.Firestore.Key.sector] as? String {
                                        if let productType = data[Constants.Firestore.Key.type] as? String {
                                            if let country = data[Constants.Firestore.Key.country] as? String {
                                                if let cardID = data[Constants.Firestore.Key.cardID] as? String {
                                                    if let singlePlace = data[Constants.Firestore.Key.singlePlace] as? Bool {
                                                        if let companyCard = data[Constants.Firestore.Key.companyCard] as? Bool {
                                                            if let userID = data[Constants.Firestore.Key.userID] as? String {
                                                                if let imageURL = data[Constants.Firestore.Key.imageURL] as? String {
                                                                    
                                                                    if companyCard == false {
                                                                        if let personalName = data[Constants.Firestore.Key.personalName] as? String {
                                                                            
                                                                            let card = ShowVBC(personalName: personalName, companyName: name, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID, imageURL: imageURL)
                                                                            
                                                                            self.personalCards.insert(card, at: self.cardRowEdited)
                                                                            
                                                                            DispatchQueue.main.async {
                                                                                self.tableView.reloadData()
                                                                            }
                                                                        }
                                                                    } else {
                                                                        
                                                                        let card = ShowVBC(companyName: name, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID, imageURL: imageURL)
                                                                        
                                                                        self.companyCards.insert(card, at: self.cardRowEdited)
                                                                        
                                                                        DispatchQueue.main.async {
                                                                            self.tableView.reloadData()
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
                                self.cardIsEdited = false
                                self.cardRowEdited = 0
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                        
                        if diff.type == .removed {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        
    }
    
    // MARK: - Add New Card Button Pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.Segue.addVBC, sender: self)
    }
    
    // MARK: - Segment Company or Personal
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        if segmentControl.selectedSegmentIndex == 0 {
            currentSegment0 = true
            tableView.reloadData()
        } else {
            currentSegment0 = false
            tableView.reloadData()
        }
    }
}

// MARK: - TableView
extension MyCardsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if currentSegment0 == true {
            return companyCards.count
        } else {
            return personalCards.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.homeCell, for: indexPath) as! HomeViewCell
        
        if currentSegment0 == true {
            
            let companyCardRow = companyCards[indexPath.row]
            
            DispatchQueue.main.async {
                if companyCardRow.imageURL != "" {
                    cell.logoImageView.sd_setImage(with: URL(string: companyCardRow.imageURL), completed: nil)
                } else {
                    cell.logoImageView.image = UIImage(named: "LogoImage")
                }
            }
            
            cell.personalName.isHidden = true
            cell.companyNameLabel.text = companyCardRow.companyName
            cell.sectorLabel.text = companyCardRow.sector
            cell.productTypeLabel.text = companyCardRow.type
            cell.countryFlag.image = UIImage(named: companyCardRow.country)
            cell.companyOrPersonalIcon.image = UIImage(named: "Company")
            
        } else {
            
            let personalCardRow = personalCards[indexPath.row]
            
            DispatchQueue.main.async {
                if personalCardRow.imageURL != "" {
                    cell.logoImageView.sd_setImage(with: URL(string: personalCardRow.imageURL), completed: nil)
                } else {
                    cell.logoImageView.image = UIImage(named: "LogoImage")
                }
            }
            
            cell.personalName.isHidden = false
            cell.personalName.text = personalCardRow.personalName
            cell.companyNameLabel.text = personalCardRow.companyName
            cell.sectorLabel.text = personalCardRow.sector
            cell.productTypeLabel.text = personalCardRow.type
            cell.countryFlag.image = UIImage(named: personalCardRow.country)
            cell.companyOrPersonalIcon.image = UIImage(named: "Personal")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Segue.viewCard, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.viewCard {
            
            let destinationVC = segue.destination as! CardVC
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                if currentSegment0 == true {
                    destinationVC.cardRowForEdit = indexPath.row
                    destinationVC.userID = companyCards[indexPath.row].userID
                    destinationVC.cardID = companyCards[indexPath.row].cardID
                    destinationVC.singlePlace = companyCards[indexPath.row].singlePlace
                    destinationVC.companyCard = companyCards[indexPath.row].companyCard
                } else {
                    destinationVC.cardRowForEdit = indexPath.row
                    destinationVC.userID = personalCards[indexPath.row].userID
                    destinationVC.cardID = personalCards[indexPath.row].cardID
                    destinationVC.singlePlace = personalCards[indexPath.row].singlePlace
                    destinationVC.companyCard = personalCards[indexPath.row].companyCard
                }
            }
        }
    }
    
}
