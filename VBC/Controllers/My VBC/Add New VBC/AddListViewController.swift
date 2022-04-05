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

protocol EditSelectedLocation: AnyObject {
    func getEditLocation(city: String, street: String, map: String)
}

class AddListViewController: UIViewController, DeleteCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: MultiplePlacesDelegate?
    weak var delegateEdit: EditSelectedLocation?
    
    let db = Firestore.firestore()
    
    let user = Auth.auth().currentUser?.uid
    
    var getLocationList : [Location] = []
    
    var cardID : String = ""
    
    var cityName: String = ""
    var streetName: String = ""
    var mapLink: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocations()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.Nib.addLocList, bundle: nil), forCellReuseIdentifier: Constants.Cell.addLocListCell)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        delegate?.getNumberOfPlaces(places: getLocationList.count)
    }
    
    // MARK: - Get Locations from Firestore
    
    func getLocations() {
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
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
                                    if let map = data[Constants.Firestore.Key.gMaps] as? String {
                                        
                                        let places = Location(city: cityName, street: cityStreet, gMapsLink: map)
                                        
                                        self.getLocationList.append(places)
                                        self.tableView.reloadData()
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    // MARK: - Delete Cell Button
    
    func deleteButtonPressed(with title: String, row: Int) {
        
        // Pop Up with Yes and No
        let alert = UIAlertController(title: "Delete this location?", message: "Are you sure that you want to delete this location?", preferredStyle: .alert)
        let actionBACK = UIAlertAction(title: "Back", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        let actionDELETE = UIAlertAction(title: "Delete", style: .destructive) { [self] action in
            
            let documentName = title
            
            if getLocationList.count > 1 {
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(user!)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(cardID)
                    .collection(Constants.Firestore.CollectionName.locations)
                    .document(documentName)
                    .delete()
                
                getLocationList.removeAll()
                getLocations()
                
            } else {
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(user!)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(cardID)
                    .collection(Constants.Firestore.CollectionName.locations)
                    .document(documentName)
                    .delete()
                
                getLocationList.removeAll()
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        
        alert.addAction(actionDELETE)
        alert.addAction(actionBACK)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Table View

extension AddListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getLocationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.addLocListCell, for: indexPath) as! AddLocListTableViewCell
        
        let placeRow = getLocationList[indexPath.row]
        
        cell.configure(city: placeRow.city, street: placeRow.street, map: placeRow.gMapsLink, row: indexPath.row)
        cell.delegate = self
        cell.delegate2 = self
        
        return cell
    }
}


// MARK: - Edit Location Function

extension AddListViewController: EditCellDelegate {
    
    func editButtonPressed(city: String, street: String, map: String) {
        
        cityName = city
        streetName = street
        mapLink = map
        
        db.collection(Constants.Firestore.CollectionName.VBC)
            .document(Constants.Firestore.CollectionName.data)
            .collection(Constants.Firestore.CollectionName.users)
            .document(user!)
            .collection(Constants.Firestore.CollectionName.cardID)
            .document(cardID)
            .collection(Constants.Firestore.CollectionName.locations)
            .document("\(cityName) - \(streetName)")
            .delete()
        
        delegateEdit?.getEditLocation(city: cityName, street: streetName, map: mapLink)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
