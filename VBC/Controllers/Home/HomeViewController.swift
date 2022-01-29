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
    
    // MARK: - Search Button
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        
        allCardsList = []
        getCards()
    }
    
    // MARK: - Language Button
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
    
    // MARK: - Get Cards Function
    
    func getCards() {
        
        // Getting Company Users ID
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
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
                                    .document(Constants.Firestore.CollectionName.data)
                                    .collection(Constants.Firestore.CollectionName.users)
                                    .document(userID)
                                    .collection(Constants.Firestore.CollectionName.cardID)
                                    .getDocuments { snapshot, error in
                                        
                                        if let e = error {
                                            print ("Error getting Company Multiple Places Card. \(e)")
                                        } else {
                                            
                                            snapshot?.documentChanges.forEach({ diff in
                                                
                                                let data = diff.document.data()
                                                
                                                if diff.type == .added {
                                                    
                                                    if let name = data[Constants.Firestore.Key.Name] as? String {
                                                        if let sector = data[Constants.Firestore.Key.sector] as? String {
                                                            if let productType = data[Constants.Firestore.Key.type] as? String {
                                                                if let country = data[Constants.Firestore.Key.country] as? String {
                                                                    if let cardID = data[Constants.Firestore.Key.cardID] as? String {
                                                                        if let singlePlace = data[Constants.Firestore.Key.singlePlace] as? Bool {
                                                                            if let companyCard = data[Constants.Firestore.Key.companyCard] as? Bool {
                                                                                if let userID = data[Constants.Firestore.Key.userID] as? String {
                                                                                    
                                                                                    let card = ShowVBC(name: name, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID)
                                                                                    
                                                                                    
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

