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
    // List of All Cards in Database
    var allSavedCardsList : [ShowVBC] = []
    // List of Searched Cards
    var filteredCardsList : [ShowVBC] = []
    // Notification Name
    let NotNameRemovedCard = Notification.Name(rawValue: Constants.NotificationKey.cardRemoved)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.Nib.homeViewCell, bundle: nil), forCellReuseIdentifier: Constants.Cell.homeCell)
        
        getSavedVBC()
        createObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Notification Observer from Card View Controller for Removed from Saved
    func createObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(SavedViewController.deleteCard(notification:)), name: NotNameRemovedCard, object: nil)
    }
    
    @objc func deleteCard(notification: NSNotification) {
        
        if notification.name == NotNameRemovedCard {
            
            if let removedCardID = notification.object as? String {
                
                if let index = allSavedCardsList.firstIndex(where: { $0.cardID == removedCardID }) {
                    allSavedCardsList.remove(at: index)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
                    print("Error Getting Saved VBC. \(e)")
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
                                                    
                                                    if let companyName = data![Constants.Firestore.Key.companyName] as? String {
                                                        if let sector = data![Constants.Firestore.Key.sector] as? String {
                                                            if let productType = data![Constants.Firestore.Key.type] as? String {
                                                                if let country = data![Constants.Firestore.Key.country] as? String {
                                                                    if let cardID = data![Constants.Firestore.Key.cardID] as? String {
                                                                        if let singlePlace = data![Constants.Firestore.Key.singlePlace] as? Bool {
                                                                            if let companyCard = data![Constants.Firestore.Key.companyCard] as? Bool {
                                                                                if let userID = data![Constants.Firestore.Key.userID] as? String {
                                                                                    if let personalName = data![Constants.Firestore.Key.personalName] as? String {
                                                                                        
                                                                                        let card = ShowVBC(personalName: personalName, companyName: companyName, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID)
                                                                                        
                                                                                        self.allSavedCardsList.append(card)
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
                                                
                                            }
                                        }
                                }
                            }
                            
                        }
                        
                        if diff.type == .removed {
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
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
