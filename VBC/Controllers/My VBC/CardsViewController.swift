//
//  myVBCViewController.swift
//  VBC
//
//  Created by VELJKO on 9.11.21..
//

import UIKit
import Firebase
import FirebaseStorage

class CardsViewController: UIViewController {
    
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
    
    var singlePlace : [Bool] = []
    var currentSegment0 : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.Nib.homeViewCell, bundle: nil), forCellReuseIdentifier: Constants.Cell.homeCell)
        
        getCards()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Get Company Cards with Single Place
    
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
                                                            
                                                            if companyCard == false {
                                                                if let personalName = data[Constants.Firestore.Key.personalName] as? String {
                                                                    
                                                                    let card = ShowVBC(personalName: personalName, companyName: name, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID)
                                                                    
                                                                    self.personalCards.append(card)
                                                                }
                                                            } else {
                                                                
                                                                let card = ShowVBC(companyName: name, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID)
                                                                
                                                                self.companyCards.append(card)
                                                            }
                                                            
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
                        
                        if diff.type == .modified {
                            
                            if let name = data[Constants.Firestore.Key.companyName] as? String {
                                if let sector = data[Constants.Firestore.Key.sector] as? String {
                                    if let productType = data[Constants.Firestore.Key.type] as? String {
                                        if let country = data[Constants.Firestore.Key.country] as? String {
                                            if let cardID = data[Constants.Firestore.Key.cardID] as? String {
                                                if let singlePlace = data[Constants.Firestore.Key.singlePlace] as? Bool {
                                                    if let companyCard = data[Constants.Firestore.Key.companyCard] as? Bool {
                                                        if let userID = data[Constants.Firestore.Key.userID] as? String {
                                                            
                                                            if companyCard == false {
                                                                if let personalName = data[Constants.Firestore.Key.personalName] as? String {
                                                                    
                                                                    let card = ShowVBC(personalName: personalName, companyName: name, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID)
                                                                    
                                                                    if self.editedCardRow != nil {
                                                                        self.personalCards.insert(card, at: self.editedCardRow!)
                                                                    }
                                                                }
                                                            } else {
                                                                
                                                                let card = ShowVBC(companyName: name, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID)
                                                                
                                                                if self.editedCardRow != nil {
                                                                    self.companyCards.insert(card, at: self.editedCardRow!)
                                                                }
                                                            }
                                                            
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
                        
                        if diff.type == .removed {
                            
                            //print("Removed")
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

// MARK: - Edit Card Delegate from Card View Controller

extension CardsViewController: EditedCardDelegate {
    
    func getEditedCardID(cardRow: Int, companyCard: Bool) {
        
        editedCardRow = cardRow
        if companyCard == true {
            self.companyCards.remove(at: cardRow)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            self.personalCards.remove(at: cardRow)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
}

// MARK: - TableView
extension CardsViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            
            cell.personalName.isHidden = true
            cell.companyNameLabel.text = companyCardRow.companyName
            cell.sectorLabel.text = companyCardRow.sector
            cell.productTypeLabel.text = companyCardRow.type
            cell.countryFlag.image = UIImage(named: companyCardRow.country)
            cell.companyOrPersonalIcon.image = UIImage(named: "Company")
            
        } else {
            
            let personalCardRow = personalCards[indexPath.row]
            
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
    
    // MARK: - Prepare for Segue function
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.viewCard {
            
            let destinationVC = segue.destination as! CardViewController
            
            destinationVC.delegate = self
            
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
