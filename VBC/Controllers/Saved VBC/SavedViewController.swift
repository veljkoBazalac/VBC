//
//  SavedViewController.swift
//  VBC
//
//  Created by VELJKO on 27.1.22..
//

import UIKit
import Firebase

class SavedViewController: UIViewController, UISearchResultsUpdating {
    
    // Outlets for TableView and SearchBar
    @IBOutlet weak var tableView: UITableView!
    
    // Search Controller
    let searchController = UISearchController()
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Storage
    let storage = Storage.storage().reference()
    // Firebase Auth Current User
    let user = Auth.auth().currentUser?.uid
    // Card ID
    var cardID : String = ""
    // Card is Edited or Not
    var cardIsEdited : Bool = false
    // List of All Cards in Database
    var allSavedCardsList : [ShowVBC] = []
    // List of Searched Cards
    var filteredCardsList : [ShowVBC] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        
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
    
    // MARK: - Update Search Result Function
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {return}
        
        filteredCardsList.removeAll()
        
        let searchArray = self.allSavedCardsList.filter {
            return $0.companyName.lowercased().range(of: searchText) != nil ||
            $0.personalName.lowercased().range(of: searchText) != nil ||
            $0.sector.lowercased().range(of: searchText) != nil ||
            $0.type.lowercased().range(of: searchText) != nil ||
            $0.country.lowercased().range(of: searchText) != nil
            
        }
        
        filteredCardsList = searchArray
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - Get Data from Firestore

extension SavedViewController {
    
    func getSavedVBC() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.savedVBC)
            .addSnapshotListener { snapshot, error in
                
                if let e = error {
                    print("Error Getting User and Card ID for Saved Card. \(e)")
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
                                        .whereField(Constants.Firestore.Key.cardID, isEqualTo: savedCardID)
                                        .addSnapshotListener { snapshot, error in
                                            
                                            if let e = error {
                                                print("Error Getting Saved VBC. \(e)")
                                            } else {
                                                
                                                snapshot?.documentChanges.forEach({ diff in
                                                    
                                                    let data = diff.document.data()
                                                    
                                                    if diff.type == .added {
                                                        
                                                        if let companyName = data[Constants.Firestore.Key.companyName] as? String {
                                                            if let sector = data[Constants.Firestore.Key.sector] as? String {
                                                                if let productType = data[Constants.Firestore.Key.type] as? String {
                                                                    if let country = data[Constants.Firestore.Key.country] as? String {
                                                                        if let cardID = data[Constants.Firestore.Key.cardID] as? String {
                                                                            if let singlePlace = data[Constants.Firestore.Key.singlePlace] as? Bool {
                                                                                if let companyCard = data[Constants.Firestore.Key.companyCard] as? Bool {
                                                                                    if let userID = data[Constants.Firestore.Key.userID] as? String {
                                                                                        if let personalName = data[Constants.Firestore.Key.personalName] as? String {
                                                                                            
                                                                                            if let imageURL = data[Constants.Firestore.Key.imageURL] as? String {
                                                                                                
                                                                                                let card = ShowVBC(personalName: personalName, companyName: companyName, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID, imageURL: imageURL)
                                                                                                
                                                                                                self.allSavedCardsList.append(card)
                                                                                                
                                                                                                DispatchQueue.main.async {
                                                                                                    self.tableView.reloadData()
                                                                                                }
                                                                                                
                                                                                                
                                                                                            } else {
                                                                                                
                                                                                                let card = ShowVBC(personalName: personalName, companyName: companyName, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID)
                                                                                                
                                                                                                self.allSavedCardsList.append(card)
                                                                                                
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
                                                    }
                                                    
                                                    if diff.type == .modified {
                                                        
                                                        if let removeCardID = data[Constants.Firestore.Key.cardID] as? String {
                                                            
                                                            if let index = self.allSavedCardsList.firstIndex(where: { $0.cardID == removeCardID }) {
                                                                self.allSavedCardsList.remove(at: index)
                                                                
                                                                
                                                                if let companyName = data[Constants.Firestore.Key.companyName] as? String {
                                                                    if let sector = data[Constants.Firestore.Key.sector] as? String {
                                                                        if let productType = data[Constants.Firestore.Key.type] as? String {
                                                                            if let country = data[Constants.Firestore.Key.country] as? String {
                                                                                if let cardID = data[Constants.Firestore.Key.cardID] as? String {
                                                                                    if let singlePlace = data[Constants.Firestore.Key.singlePlace] as? Bool {
                                                                                        if let companyCard = data[Constants.Firestore.Key.companyCard] as? Bool {
                                                                                            if let userID = data[Constants.Firestore.Key.userID] as? String {
                                                                                                if let personalName = data[Constants.Firestore.Key.personalName] as? String {
                                                                                                    
                                                                                                    if let imageURL = data[Constants.Firestore.Key.imageURL] as? String {
                                                                                                        
                                                                                                        let card = ShowVBC(personalName: personalName, companyName: companyName, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID, imageURL: imageURL)
                                                                                                        
                                                                                                        self.allSavedCardsList.insert(card, at: index)
                                                                                                        
                                                                                                        DispatchQueue.main.async {
                                                                                                            self.tableView.reloadData()
                                                                                                        }
                                                                                                        
                                                                                                        
                                                                                                    } else {
                                                                                                        
                                                                                                        let card = ShowVBC(personalName: personalName, companyName: companyName, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID)
                                                                                                        
                                                                                                        self.allSavedCardsList.insert(card, at: index)
                                                                                                        
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
                                                            }
                                                        }
                                                    }
                                                    
                                                    if diff.type == .removed {
                                                       
                                                        if let removeCardID = data[Constants.Firestore.Key.cardID] as? String {
                                                            
                                                            if let index = self.allSavedCardsList.firstIndex(where: { $0.cardID == removeCardID }) {
                                                                self.allSavedCardsList.remove(at: index)
                                                            }
                                                        }
                                                        
                                                        DispatchQueue.main.async {
                                                            self.tableView.reloadData()
                                                        }
                                                    }
                                                })
                                            }
                                        }
                                }
                            }
                        }
                        
                        if diff.type == .removed {
                            
                            if let removeCardID = data[Constants.Firestore.Key.cardID] as? String {
                                
                                if let index = self.allSavedCardsList.firstIndex(where: { $0.cardID == removeCardID }) {
                                    self.allSavedCardsList.remove(at: index)
                                }
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            }
    }
    
} //

// MARK: - TableView

extension SavedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive == true {
            return filteredCardsList.count
        } else {
            return allSavedCardsList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.homeCell, for: indexPath) as! HomeViewCell
        
        if searchController.isActive == true {
            
            let cardsRow = filteredCardsList[indexPath.row]
            
            DispatchQueue.main.async {
                if cardsRow.imageURL != "" {
                    cell.logoImageView.sd_setImage(with: URL(string: cardsRow.imageURL), completed: nil)
                } else {
                    cell.logoImageView.image = UIImage(named: "LogoImage")
                }
            }
            
            if cardsRow.companyCard == false {
                cell.personalName.isHidden = false
                cell.personalName.text = cardsRow.personalName
                cell.companyOrPersonalIcon.image = UIImage(named: "Personal")
            } else {
                cell.personalName.isHidden = true
                cell.companyOrPersonalIcon.image = UIImage(named: "Company")
            }
            
            cell.companyNameLabel.text = cardsRow.companyName
            cell.sectorLabel.text = cardsRow.sector
            cell.productTypeLabel.text = cardsRow.type
            cell.countryFlag.image = UIImage(named: cardsRow.country)
            
        } else {
            let cardsRow = allSavedCardsList[indexPath.row]
            
            DispatchQueue.main.async {
                if cardsRow.imageURL != "" {
                    cell.logoImageView.sd_setImage(with: URL(string: cardsRow.imageURL), completed: nil)
                } else {
                    cell.logoImageView.image = UIImage(named: "LogoImage")
                }
            }
            
            if cardsRow.companyCard == false {
                cell.personalName.isHidden = false
                cell.personalName.text = cardsRow.personalName
                cell.companyOrPersonalIcon.image = UIImage(named: "Personal")
            } else {
                cell.personalName.isHidden = true
                cell.companyOrPersonalIcon.image = UIImage(named: "Company")
            }
            
            cell.companyNameLabel.text = cardsRow.companyName
            cell.sectorLabel.text = cardsRow.sector
            cell.productTypeLabel.text = cardsRow.type
            cell.countryFlag.image = UIImage(named: cardsRow.country)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Segue.savedToCard, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.savedToCard {
            
            let destinationVC = segue.destination as! CardViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                destinationVC.cardRowForRemove = indexPath.row
                destinationVC.userID = allSavedCardsList[indexPath.row].userID
                destinationVC.cardID = allSavedCardsList[indexPath.row].cardID
                destinationVC.singlePlace = allSavedCardsList[indexPath.row].singlePlace
                destinationVC.companyCard = allSavedCardsList[indexPath.row].companyCard
                destinationVC.cardSaved = allSavedCardsList[indexPath.row].cardSaved
            }
        }
    }
    
}
