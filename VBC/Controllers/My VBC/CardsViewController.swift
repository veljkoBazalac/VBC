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
    
    var cardID : [String] = []
    var singlePlace : [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSinglePlaceCard()
        getMPCard()
        
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
    
    func getSinglePlaceCard() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(user!)
            .document(Constants.Firestore.CollectionName.singlePlace)
            .collection(Constants.Firestore.CollectionName.cardID)
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
                                                    
                                                    let card = ShowVBC(name: companyName, sector: companySector, type: companyProductType, country: companyCountry, cardID: companyCardID, singlePlace: companySinglePlace)
                                                    
                                                    self.singlePlace.append(companySinglePlace)
                                                    self.cardID.append(companyCardID)
                                                    self.companyCards.append(card)
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
    
    // MARK: - Get Company Cards with Multiple Places
    
    func getMPCard() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(user!)
            .document(Constants.Firestore.CollectionName.multiplePlaces)
            .collection(Constants.Firestore.CollectionName.cardID)
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
                                                    
                                                    let card = ShowVBC(name: companyName, sector: companySector, type: companyProductType, country: companyCountry, cardID: companyCardID, singlePlace: companySinglePlace)
                                                    
                                                    self.singlePlace.append(companySinglePlace)
                                                    self.cardID.append(companyCardID)
                                                    self.companyCards.append(card)
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
        
        
        
        print(companyCards)
        
    }
    
    
    
    
}

extension CardsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companyCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.homeCell, for: indexPath) as! HomeViewCell
        
        let cardRow = companyCards[indexPath.row]
        
        cell.nameLabel.text = cardRow.name
        cell.sectorLabel.text = cardRow.sector
        cell.productTypeLabel.text = cardRow.type
        cell.countryLabel.text = cardRow.country
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: Constants.Segue.viewCard, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.viewCard {
            
            let destinationVC = segue.destination as! CardViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.cardID = cardID[indexPath.row]
                destinationVC.singlePlace = singlePlace[indexPath.row]
            }
        }
    }
    
}
