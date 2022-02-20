//
//  SearchViewController.swift
//  VBC
//
//  Created by VELJKO on 18.2.22..
//

import UIKit
import Firebase

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectSearchBy: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    // Firebase Firestore Database
    let db = Firestore.firestore()
    // Firebase Storage
    let storage = Storage.storage().reference()
    // Current Auth User ID
    let user = Auth.auth().currentUser?.uid
    // Picker View
    var pickerView = UIPickerView()
    // Card ID
    var cardID : String = ""
    // Search Results
    var searchResult : [ShowVBC] = []
    // Search By
    var searchBy : [SearchBy] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSearchBy()
        
        tableView.register(UINib(nibName: Constants.Nib.homeViewCell, bundle: nil), forCellReuseIdentifier: Constants.Cell.homeCell)
        
        selectSearchBy.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    // MARK: - Pop Up With Ok
    
    func popUpWithOk(newTitle: String, newMessage: String) {
        
        let alert = UIAlertController(title: newTitle, message: newMessage, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(actionOK)
        present(alert, animated: true, completion: nil)
    }
    

    @IBAction func searchButtonPressed(_ sender: UIButton) {
        
        searchTextField.resignFirstResponder()
        searchResult.removeAll()
        
        if selectSearchBy.text == "Card ID" {
        getSearchResult(parameter: Constants.Firestore.Key.cardID, search: searchTextField.text!)
        } else if selectSearchBy.text == "Company Name" {
            getSearchResult(parameter: Constants.Firestore.Key.companyName, search: searchTextField.text!)
        } else if selectSearchBy.text == "Personal Name" {
            getSearchResult(parameter: Constants.Firestore.Key.personalName, search: searchTextField.text!)
        } else if selectSearchBy.text == "Country Name" {
            getSearchResult(parameter: Constants.Firestore.Key.country, search: searchTextField.text!)
        } else if selectSearchBy.text == "City Name" {
            getSearchResult(parameter: Constants.Firestore.Key.city, search: searchTextField.text!)
        } else if selectSearchBy.text == "Sector" {
            getSearchResult(parameter: Constants.Firestore.Key.sector, search: searchTextField.text!)
        } else if selectSearchBy.text == "Product Type" {
            getSearchResult(parameter: Constants.Firestore.Key.type, search: searchTextField.text!)
        }
    }
}

// MARK: - Get Search Results

extension SearchViewController {
    
    func getSearchResult(parameter: String, search: String) {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .getDocuments { snapshot, error in
                
                if let e = error {
                    print ("Error getting Multiple Places List. \(e)")
                } else {
                    
                    if let snapshotDocuments = snapshot?.documents {
                        
                        for documents in snapshotDocuments {
                            
                            let data = documents.data()
                            
                            if let userID = data[Constants.Firestore.Key.userID] as? String {
                                
                                // Getting Searched Card
                                self.db.collection(Constants.Firestore.CollectionName.VBC)
                                    .document(Constants.Firestore.CollectionName.data)
                                    .collection(Constants.Firestore.CollectionName.users)
                                    .document(userID)
                                    .collection(Constants.Firestore.CollectionName.cardID)
                                    .getDocuments { snapshot, error in
                                        
                                        if let e = error {
                                            print ("Error getting Multiple Places List. \(e)")
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
                                                                                            
                                                                                            let card = ShowVBC(personalName: personalName, companyName: companyName, sector: sector, type: productType, country: country, cardID: cardID, singlePlace: singlePlace, companyCard: companyCard, userID: userID, cardSaved: cardSaved)
                                                                                            
                                                                                            if parameter == Constants.Firestore.Key.cardID {
                                                                                                if  cardID.uppercased().contains(search.uppercased()) {
                                                                                                    self.searchResult.append(card)
                                                                                                }
                                                                                            }
                                                                                            
                                                                                            if parameter == Constants.Firestore.Key.companyName {
                                                                                                if companyName.lowercased().contains(search.lowercased()) {
                                                                                                    self.searchResult.append(card)
                                                                                                }
                                                                                                
                                                                                            }
                                                                                            
                                                                                            if parameter == Constants.Firestore.Key.personalName {
                                                                                                if personalName.lowercased().contains(search.lowercased()) {
                                                                                                    self.searchResult.append(card)
                                                                                                }
                                                                                                
                                                                                            }
                                                                                            
                                                                                            if parameter == Constants.Firestore.Key.country {
                                                                                                if country.lowercased().contains(search.lowercased()){
                                                                                                    self.searchResult.append(card)
                                                                                                }
                                                                                                
                                                                                            }
                                                                                            
                                                                                            if parameter == Constants.Firestore.Key.sector {
                                                                                                if sector.lowercased().contains(search.lowercased()) {
                                                                                                    self.searchResult.append(card)
                                                                                                }
                                                                                                
                                                                                            }
                                                                                            
                                                                                            if parameter == Constants.Firestore.Key.type {
                                                                                                if productType.lowercased().contains(search.lowercased()) {
                                                                                                    self.searchResult.append(card)
                                                                                                }
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


// MARK: - Get Search Parameters List

extension SearchViewController {
    
    func getSearchBy() {
        
        db.collection(Constants.Firestore.CollectionName.searchBy).getDocuments { snapshot, error in
            
            if let e = error {
                self.popUpWithOk(newTitle: "Error!", newMessage: "Error Getting data from Database. Please Check your Internet connection and try again. \(e.localizedDescription)")
            } else {
                
                if let snapshotDocuments = snapshot?.documents {
                    
                    for documents in snapshotDocuments {
                        
                        let data = documents.data()
                        
                        if let searchParameter = data[Constants.Firestore.Key.parameter] as? String {
                            
                            let parameter = SearchBy(parameter: searchParameter)
                            
                            self.searchBy.append(parameter)
                            
                            self.selectSearchBy.text = self.searchBy.first?.parameter
                        }
                    }
                }
            }
        }
    }
    
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.homeCell, for: indexPath) as! HomeViewCell
        
        let cardsRow = searchResult[indexPath.row]
        
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
        
        performSegue(withIdentifier: Constants.Segue.searchToCard, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.searchToCard {
            
            let destinationVC = segue.destination as! CardViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                destinationVC.userID = searchResult[indexPath.row].userID
                destinationVC.cardID = searchResult[indexPath.row].cardID
                destinationVC.singlePlace = searchResult[indexPath.row].singlePlace
                destinationVC.companyCard = searchResult[indexPath.row].companyCard
                destinationVC.cardSaved = searchResult[indexPath.row].cardSaved
            }
        }
    }
    
    
}


// MARK: - UIPickerView for Location

extension SearchViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return searchBy.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return searchBy[row].parameter
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectSearchBy.text = searchBy[row].parameter
    }
}
