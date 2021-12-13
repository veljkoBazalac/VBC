//
//  AddListViewController.swift
//  VBC
//
//  Created by VELJKO on 15.11.21..
//

import UIKit
import Firebase

protocol MultiplePlacesDelegate: AnyObject {
    func getNumberOfPlaces(places: Int)
}

class AddListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddListCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: MultiplePlacesDelegate?
    
    let db = Firestore.firestore()
    
    let user = Auth.auth().currentUser?.uid
    
    var getMultiplePlacesList : [MultiplePlaces] = []
    
    var cardID : String = ""
    var newSector : String = ""
    var selectCountry : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getMultiplePlaces()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.Nib.addLocList, bundle: nil), forCellReuseIdentifier: Constants.Cell.addLocListCell)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        delegate?.getNumberOfPlaces(places: getMultiplePlacesList.count)
    }
            
    
// MARK: - Get Multiple Places List
    
    func getMultiplePlaces() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.companyCards)
            .collection(user!)
            .document(Constants.Firestore.CollectionName.multiplePlaces)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(Constants.Firestore.CollectionName.basicInfo)
            .collection(Constants.Firestore.CollectionName.locations)
            .getDocuments { snapshot, error in
            
            if let e = error {
                print ("Error getting Multiple Places List. \(e)")
            } else {
                
                if let snapshotDocuments = snapshot?.documents {
                    
                    for documents in snapshotDocuments {
                       
                        let data = documents.data()
                        
                        if let cityName = data[Constants.Firestore.Key.city] as? String {
                            if let cityStreet = data[Constants.Firestore.Key.street] as? String {
                                if let cityMap = data[Constants.Firestore.Key.gMaps] as? String {
                                    
                                    let places = MultiplePlaces(city: cityName, street: cityStreet, gMapsLink: cityMap)
                                 
                                    self.getMultiplePlacesList.append(places)
                                    self.tableView.reloadData()
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }

// MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getMultiplePlacesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.addLocListCell, for: indexPath) as! AddLocListTableViewCell
        
        let placeRow = getMultiplePlacesList[indexPath.row]
        
        cell.configure(with: "\(placeRow.city) - \(placeRow.street)")
        cell.delegate = self
        
        return cell
    }
    
// MARK: - Delete Cell Button
    
        func deleteButtonPressed(with title: String) {
            
            // Pop Up with Yes and No
            let alert = UIAlertController(title: "Delete this location?", message: "Are you sure that you want to delete this location?", preferredStyle: .alert)
            let actionBACK = UIAlertAction(title: "Back", style: .default) { action in
                alert.dismiss(animated: true, completion: nil)
            }
            let actionDELETE = UIAlertAction(title: "Delete", style: .destructive) { [self] action in

                let documentName = title

                if getMultiplePlacesList.count > 1 {
                    db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.companyCards)
                        .collection(user!)
                        .document(Constants.Firestore.CollectionName.multiplePlaces)
                        .collection(Constants.Firestore.CollectionName.cardID)
                        .document(Constants.Firestore.CollectionName.basicInfo)
                        .collection(Constants.Firestore.CollectionName.locations)
                        .document(documentName)
                        .delete()

                getMultiplePlacesList = []
                getMultiplePlaces()
                    
                } else {
                    db.collection(Constants.Firestore.CollectionName.VBC)
                        .document(Constants.Firestore.CollectionName.companyCards)
                        .collection(user!)
                        .document(Constants.Firestore.CollectionName.multiplePlaces)
                        .collection(Constants.Firestore.CollectionName.cardID)
                        .document(Constants.Firestore.CollectionName.basicInfo)
                        .collection(Constants.Firestore.CollectionName.locations)
                        .document(documentName)
                        .delete()
                
                getMultiplePlacesList = []
                self.dismiss(animated: true, completion: nil)
                }
                
            }

            alert.addAction(actionDELETE)
            alert.addAction(actionBACK)
            
            self.present(alert, animated: true, completion: nil)
        }
}
