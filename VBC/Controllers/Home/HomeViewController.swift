//
//  ViewController.swift
//  VBC
//
//  Created by VELJKO on 23.10.21..
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Storage
    let storage = Storage.storage().reference()
    // Current Auth User ID
    let user = Auth.auth().currentUser?.uid
    // Card ID
    var cardID : String = ""
    // List of All Cards in Database
    var allCardsList : [ShowVBC] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.Nib.homeViewCell, bundle: nil), forCellReuseIdentifier: Constants.Cell.homeCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        
        allCardsList = []
        getCMPCards()
        getCSPCards()
        getPersonalCards()
    }
    
    
    @IBAction func languageButtonPressed(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: - Get Company Multiple Places Cards
    
    func getCMPCards() {
        
        // Getting Company Users ID
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(Constants.Firestore.CollectionName.users)
            .getDocuments { snapshot, error in
                
                if let e = error {
                    print ("Error getting Users UID. \(e)")
                } else {
                    
                    snapshot?.documentChanges.forEach({ diff in
                        
                        let data = diff.document.data()
                        
                        if diff.type == .added {
                            
                            if let userID = data[Constants.Firestore.Key.userID] as? String {
                                
                                // Getting Company Multiple Places Card
                                self.db.collection(Constants.Firestore.CollectionName.VBC)
                                    .document(Constants.Firestore.CollectionName.companyCards)
                                    .collection(Constants.Firestore.CollectionName.users)
                                    .document(userID)
                                    .collection(Constants.Firestore.CollectionName.multiplePlaces)
                                    .getDocuments { snapshot, error in
                                        
                                        if let e = error {
                                            print ("Error getting Company Multiple Places Card. \(e)")
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
                                                                                    
                                                                                    
                                                                                    self.allCardsList.append(card)
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
    
    // MARK: - Get Company Single Place Cards
    
    func getCSPCards() {
        
        // Getting Company User ID
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(Constants.Firestore.CollectionName.users)
            .getDocuments { snapshot, error in
                
                if let e = error {
                    print ("Error getting Users UID. \(e)")
                } else {
                    
                    snapshot?.documentChanges.forEach({ diff in
                        
                        let data = diff.document.data()
                        
                        if diff.type == .added {
                            
                            if let userID = data[Constants.Firestore.Key.userID] as? String {
                                
                                // Getting Company Single Place Card
                                self.db.collection(Constants.Firestore.CollectionName.VBC)
                                    .document(Constants.Firestore.CollectionName.companyCards)
                                    .collection(Constants.Firestore.CollectionName.users)
                                    .document(userID)
                                    .collection(Constants.Firestore.CollectionName.singlePlace)
                                    .getDocuments { snapshot, error in
                                        
                                        if let e = error {
                                            print ("Error getting Company Single Place Card. \(e)")
                                        } else {
                                            
                                            snapshot?.documentChanges.forEach({ diff in
                                                
                                                let data = diff.document.data()
                                                
                                                if diff.type == .added {
                                                    
                                                    if let personalName = data[Constants.Firestore.Key.Name] as? String {
                                                        if let personalSector = data[Constants.Firestore.Key.sector] as? String {
                                                            if let personalProductType = data[Constants.Firestore.Key.type] as? String {
                                                                if let personalCountry = data[Constants.Firestore.Key.country] as? String {
                                                                    if let personalCardID = data[Constants.Firestore.Key.cardID] as? String {
                                                                        if let personalSinglePlace = data[Constants.Firestore.Key.singlePlace] as? Bool {
                                                                            if let companyCard = data[Constants.Firestore.Key.companyCard] as? Bool {
                                                                                if let userID = data[Constants.Firestore.Key.userID] as? String {
                                                                                    
                                                                                    let card = ShowVBC(name: personalName, sector: personalSector, type: personalProductType, country: personalCountry, cardID: personalCardID, singlePlace: personalSinglePlace, companyCard: companyCard, userID: userID)
                                                                                    
                                                                                    self.allCardsList.append(card)
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
    
    // MARK: - PERSONAL CARDS
    
    func getPersonalCards() {
        
        // Getting Personal Card User ID
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.personalCards)
            .collection(Constants.Firestore.CollectionName.users)
            .getDocuments { snapshot, error in
                
                if let e = error {
                    print ("Error getting Users ID. \(e)")
                } else {
                    
                    snapshot?.documentChanges.forEach({ diff in
                        
                        let data = diff.document.data()
                        
                        if diff.type == .added {
                            
                            if let userID = data[Constants.Firestore.Key.userID] as? String {
                                
                                // Getting Personal Card Basic Info
                                self.db.collection(Constants.Firestore.CollectionName.VBC)
                                    .document(Constants.Firestore.CollectionName.personalCards)
                                    .collection(Constants.Firestore.CollectionName.users)
                                    .document(userID)
                                    .collection(Constants.Firestore.CollectionName.cardID)
                                    .getDocuments { snapshot, error in
                                        
                                        if let e = error {
                                            print ("Error getting Personal Card. \(e)")
                                        } else {
                                            
                                            snapshot?.documentChanges.forEach({ diff in
                                                
                                                let data = diff.document.data()
                                                
                                                if diff.type == .added {
                                                    
                                                    if let personalName = data[Constants.Firestore.Key.Name] as? String {
                                                        if let personalSector = data[Constants.Firestore.Key.sector] as? String {
                                                            if let personalProductType = data[Constants.Firestore.Key.type] as? String {
                                                                if let personalCountry = data[Constants.Firestore.Key.country] as? String {
                                                                    if let personalCardID = data[Constants.Firestore.Key.cardID] as? String {
                                                                            if let companyCard = data[Constants.Firestore.Key.companyCard] as? Bool {
                                                                                if let userID = data[Constants.Firestore.Key.userID] as? String {
                                                                                    
                                                                                    let card = ShowVBC(name: personalName, sector: personalSector, type: personalProductType, country: personalCountry, cardID: personalCardID, singlePlace: true, companyCard: companyCard, userID: userID)
                                                                                    
                                                                                    self.allCardsList.append(card)
                                                                                    self.tableView.reloadData()
                                                                                    
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
}

// MARK: - TableView

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCardsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.homeCell, for: indexPath) as! HomeViewCell
        
        let cardsRow = allCardsList[indexPath.row]
        
        cell.nameLabel.text = cardsRow.name
        cell.sectorLabel.text = cardsRow.sector
        cell.productTypeLabel.text = cardsRow.type
        cell.countryLabel.text = cardsRow.country
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: Constants.Segue.homeToCard, sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.homeToCard {
            
            let destinationVC = segue.destination as! CardViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                destinationVC.userID = allCardsList[indexPath.row].userID
                destinationVC.cardID = allCardsList[indexPath.row].cardID
                destinationVC.singlePlace = allCardsList[indexPath.row].singlePlace
                destinationVC.companyCard = allCardsList[indexPath.row].companyCard
                
            }
        }
    }
    
}

