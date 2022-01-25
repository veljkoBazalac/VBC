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
    
    var singlePlace : [Bool] = []
    var currentSegment0 : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getComapnySPCard()
        getCompanyMPCard()
        getPersonalCards()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.Nib.homeViewCell, bundle: nil), forCellReuseIdentifier: Constants.Cell.homeCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    
    // MARK: - Get Company Cards with Single Place
    
    func getComapnySPCard() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.singlePlace)
            .addSnapshotListener { snapshot, error in
                
                if let e = error {
                    print ("Error getting Single Places Data. \(e)")
                } else {
                    
                    snapshot?.documentChanges.forEach({ diff in
                        
                        let data = diff.document.data()
                        
                        if diff.type == .added  {
                            
                            if let companyName = data[Constants.Firestore.Key.Name] as? String {
                                if let companySector = data[Constants.Firestore.Key.sector] as? String {
                                    if let companyProductType = data[Constants.Firestore.Key.type] as? String {
                                        if let companyCountry = data[Constants.Firestore.Key.country] as? String {
                                            if let companyCardID = data[Constants.Firestore.Key.cardID] as? String {
                                                if let companySinglePlace = data[Constants.Firestore.Key.singlePlace] as? Bool {
                                                    if let companyCard = data[Constants.Firestore.Key.companyCard] as? Bool {
                                                        if let userID = data[Constants.Firestore.Key.userID] as? String {
                                                    
                                                    let card = ShowVBC(name: companyName, sector: companySector, type: companyProductType, country: companyCountry, cardID: companyCardID, singlePlace: companySinglePlace,companyCard: companyCard, userID: userID)
                                                    
                                            
                                                    self.companyCards.append(card)
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
                            //print("Modified")
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
    
    // MARK: - Get Company Cards with Multiple Places
    
    func getCompanyMPCard() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.multiplePlaces)
            .addSnapshotListener { snapshot, error in
                
                if let e = error {
                    print ("Error getting Multiple Places Data. \(e)")
                } else {
                    
                    
                    snapshot?.documentChanges.forEach({ diff in
                        
                        let data = diff.document.data()
                        
                        if diff.type == .added {
                            
                            if let companyName = data[Constants.Firestore.Key.Name] as? String {
                                if let companySector = data[Constants.Firestore.Key.sector] as? String {
                                    if let companyProductType = data[Constants.Firestore.Key.type] as? String {
                                        if let companyCountry = data[Constants.Firestore.Key.country] as? String {
                                            if let companyCardID = data[Constants.Firestore.Key.cardID] as? String {
                                                if let companySinglePlace = data[Constants.Firestore.Key.singlePlace] as? Bool {
                                                    if let companyCard = data[Constants.Firestore.Key.companyCard] as? Bool {
                                                        if let userID = data[Constants.Firestore.Key.userID] as? String {
                                    
                                                    let card = ShowVBC(name: companyName, sector: companySector, type: companyProductType, country: companyCountry, cardID: companyCardID, singlePlace: companySinglePlace, companyCard: companyCard, userID: userID)
                                                    
                                                    self.companyCards.append(card)
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
                            //print("Modified")
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
    
    
    
    // MARK: - Get Personal Cards
    
    func getPersonalCards() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.personalCards)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.cardID)
            .addSnapshotListener { snapshot, error in
                
                if let e = error {
                    print ("Error getting Personal Card Data. \(e)")
                } else {
                    
                    
                    snapshot?.documentChanges.forEach({ diff in
                        
                        let data = diff.document.data()
                        
                        if diff.type == .added {
                            
                            if let pName = data[Constants.Firestore.Key.Name] as? String {
                                if let pSector = data[Constants.Firestore.Key.sector] as? String {
                                    if let pProductType = data[Constants.Firestore.Key.type] as? String {
                                        if let pCountry = data[Constants.Firestore.Key.country] as? String {
                                            if let pCardID = data[Constants.Firestore.Key.cardID] as? String {
                                                if let userID = data[Constants.Firestore.Key.userID] as? String {
                                                
                                                
                                                let card = ShowVBC(name: pName, sector: pSector, type: pProductType, country: pCountry, cardID: pCardID, singlePlace: true, userID: userID)
                                        
                                                self.personalCards.append(card)
                                                self.tableView.reloadData()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if diff.type == .modified {
                            //print("Modified")
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
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.Segue.addVBC, sender: self)
        
    }
    
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
            
            cell.nameLabel.text = companyCardRow.name
            cell.sectorLabel.text = companyCardRow.sector
            cell.productTypeLabel.text = companyCardRow.type
            cell.countryLabel.text = companyCardRow.country
            
        } else {
            
            let personalCardRow = personalCards[indexPath.row]
            
            cell.nameLabel.text = personalCardRow.name
            cell.sectorLabel.text = personalCardRow.sector
            cell.productTypeLabel.text = personalCardRow.type
            cell.countryLabel.text = personalCardRow.country
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: Constants.Segue.viewCard, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.viewCard {
            
            let destinationVC = segue.destination as! CardViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                if currentSegment0 == true {
                    destinationVC.userID = companyCards[indexPath.row].userID
                    destinationVC.cardID = companyCards[indexPath.row].cardID
                    destinationVC.singlePlace = companyCards[indexPath.row].singlePlace
                    destinationVC.companyCard = companyCards[indexPath.row].companyCard
                } else {
                    destinationVC.userID = personalCards[indexPath.row].userID
                    destinationVC.cardID = personalCards[indexPath.row].cardID
                    destinationVC.singlePlace = true
                    destinationVC.companyCard = false
                }
            }
        }
    }
    
}
