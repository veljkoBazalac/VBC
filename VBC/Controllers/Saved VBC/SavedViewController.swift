//
//  SavedViewController.swift
//  VBC
//
//  Created by VELJKO on 27.1.22..
//

import UIKit
import Firebase

class SavedViewController: UIViewController {
    
    // Outlets for TableView and SearchBar
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Storage
    let storage = Storage.storage().reference()
    // Firebase Auth Current User
    let user = Auth.auth().currentUser?.uid
    // Card ID
    var cardID : String = ""
    // List of All Cards in Database
    var allSavedCardsList : [ShowVBC] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.Nib.homeViewCell, bundle: nil), forCellReuseIdentifier: Constants.Cell.homeCell)
        
        getSavedVBC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    // MARK: - Search Bar
    
    @IBOutlet weak var searchPressed: UISearchBar!
    // TODO: Zavrsi Search i da se refresuje kad povuces na dole.
}

// MARK: - Get Data from Firestore

extension SavedViewController {
    
    func getSavedVBC() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.savedVBC)
            .getDocuments { snapshot, error in
                
                if let e = error {
                    print("Error Getting Company Saved VBC. \(e)")
                } else {
                    
                    snapshot?.documentChanges.forEach({ diff in
                        
                        let data = diff.document.data()
                        
                        if diff.type == .added {
                            
                            if let savedUserID = data[Constants.Firestore.Key.userID] as? String {
                                if let savedCardID = data[Constants.Firestore.Key.cardID] as? String {
                                    
                                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                                        .document(Constants.Firestore.CollectionName.data)
                                        .collection(Constants.Firestore.CollectionName.users)
                                        .document(savedUserID)
                                        .collection(Constants.Firestore.CollectionName.cardID)
                                        .document(savedCardID)
                                        .getDocument { document, error in
                                            
                                            if let e = error {
                                                print("Error Getting Saved VBC. \(e)")
                                            } else {
                                                
                                                if document != nil && document!.exists {
                                                    
                                                    let data = document!.data()
                                                    
                                                    if let name = data![Constants.Firestore.Key.companyName] as? String {
                                                        if let sector = data![Constants.Firestore.Key.sector] as? String {
                                                            if let productType = data![Constants.Firestore.Key.type] as? String {
                                                                if let country = data![Constants.Firestore.Key.country] as? String {
                                                                    if let cardID = data![Constants.Firestore.Key.cardID] as? String {
                                                                        if let singlePlace = data![Constants.Firestore.Key.singlePlace] as? Bool {
                                                                            if let companyCard = data![Constants.Firestore.Key.companyCard] as? Bool {
                                                                                if let userID = data![Constants.Firestore.Key.userID] as? String {
                                                                                    if let savedCard = data![Constants.Firestore.Key.cardSaved] as? Bool {
                                                                                    
                                                                                        let card = ShowVBC(name: name, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID, cardSaved: savedCard)
                                                                                        
                                                                                        self.allSavedCardsList.append(card)
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

extension SavedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSavedCardsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.homeCell, for: indexPath) as! HomeViewCell
        
        let cardsRow = allSavedCardsList[indexPath.row]
        
        cell.nameLabel.text = cardsRow.name
        cell.sectorLabel.text = cardsRow.sector
        cell.productTypeLabel.text = cardsRow.type
        cell.countryLabel.text = cardsRow.country
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Segue.savedToCard, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.savedToCard {
            
            let destinationVC = segue.destination as! CardViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                destinationVC.userID = allSavedCardsList[indexPath.row].userID
                destinationVC.cardID = allSavedCardsList[indexPath.row].cardID
                destinationVC.singlePlace = allSavedCardsList[indexPath.row].singlePlace
                destinationVC.companyCard = allSavedCardsList[indexPath.row].companyCard
                destinationVC.cardSaved = allSavedCardsList[indexPath.row].cardSaved
            }
        }
    }
    
    
}
