//
//  ViewController.swift
//  VBC
//
//  Created by VELJKO on 23.10.21..
//

import UIKit
import Firebase

class FindVC: UIViewController {
    
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
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.Nib.homeViewCell, bundle: nil), forCellReuseIdentifier: Constants.Cell.homeCell)
        
        refreshControl.addTarget(self, action: #selector(refreshData(send:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        getCards()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Pull To Refresh
    
    @objc func refreshData(send: UIRefreshControl) {
        DispatchQueue.main.async {
            self.getCards()
        }
    }
    
    // MARK: - Search Button
    
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Constants.Segue.homeToSearch, sender: self)
    }
    
    // MARK: - Language Button
    @IBAction func languageButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Get Cards Function
    
    func getCards() {
        
        allCardsList.removeAll()
        self.tableView.reloadData()
        
        // Getting Users ID
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .getDocuments { snapshot, error in
                
                if let e = error {
                    print ("Error getting User UID. \(e)")
                } else {
                    
                    if let snapshotDocuments = snapshot?.documents {
                        
                        for documents in snapshotDocuments {
                            
                            let data = documents.data()
                            
                            if let userID = data[Constants.Firestore.Key.userID] as? String {
                                
                                // Getting Cards for this User ID
                                self.db.collection(Constants.Firestore.CollectionName.VBC)
                                    .document(Constants.Firestore.CollectionName.data)
                                    .collection(Constants.Firestore.CollectionName.users)
                                    .document(userID)
                                    .collection(Constants.Firestore.CollectionName.cardID)
                                    .getDocuments { snapshot, error in
                                        
                                        if let e = error {
                                            print ("Error getting Card for this UserID. \(e)")
                                        } else {
                                            
                                            if let snapshotDocuments = snapshot?.documents {
                                                
                                                for documents in snapshotDocuments {
                                                    
                                                    let data = documents.data()
                                                    
                                                    if let personalName = data[Constants.Firestore.Key.personalName] as? String {
                                                        if let companyName = data[Constants.Firestore.Key.companyName] as? String {
                                                            if let sector = data[Constants.Firestore.Key.sector] as? String {
                                                                if let productType = data[Constants.Firestore.Key.type] as? String {
                                                                    if let country = data[Constants.Firestore.Key.country] as? String {
                                                                        if let cardID = data[Constants.Firestore.Key.cardID] as? String {
                                                                            if let singlePlace = data[Constants.Firestore.Key.singlePlace] as? Bool {
                                                                                if let companyCard = data[Constants.Firestore.Key.companyCard] as? Bool {
                                                                                    if let userID = data[Constants.Firestore.Key.userID] as? String {
                                                                                        if let cardSaved = data[Constants.Firestore.Key.cardSaved] as? Bool {
                                                                                            if let imageURL = data[Constants.Firestore.Key.imageURL] as? String {
                                                                                                
                                                                                                let card = ShowVBC(personalName: personalName, companyName: companyName, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID, cardSaved: cardSaved, imageURL: imageURL)
                                                                                                
                                                                                                self.allCardsList.append(card)
                                                                                                
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
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        if refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
    }
    
} //

// MARK: - TableView

extension FindVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCardsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.homeCell, for: indexPath) as! HomeViewCell
        
        let cardsRow = allCardsList[indexPath.row]
        
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
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: Constants.Segue.homeToCard, sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.homeToCard {
            
            let destinationVC = segue.destination as! CardVC
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                destinationVC.userID = allCardsList[indexPath.row].userID
                destinationVC.cardID = allCardsList[indexPath.row].cardID
                destinationVC.singlePlace = allCardsList[indexPath.row].singlePlace
                destinationVC.companyCard = allCardsList[indexPath.row].companyCard
                destinationVC.cardSaved = allCardsList[indexPath.row].cardSaved
            }
        }
    }
    
}

