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
    func getOnlyLocation(city: String, street: String, map: String)
}

protocol EditSelectedLocation: AnyObject {
    func getEditLocation(city: String, street: String, map: String)
}

class LocationListVC: UIViewController, DeleteCellDelegate {
    
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
        if getLocationList.count == 1 {
            delegate?.getOnlyLocation(city: getLocationList[0].city,
                                          street: getLocationList[0].street,
                                          map: getLocationList[0].gMapsLink)
        }
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
        let alert = UIAlertController(title: "Delete this location?", message: "Are you sure that you want to delete \(title) ?", preferredStyle: .alert)
        let actionBACK = UIAlertAction(title: "Back", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        }
        let actionDELETE = UIAlertAction(title: "Delete", style: .destructive) { [self] action in
            
            let documentName = title
            
//            if getLocationList.count > 1 {
                DispatchQueue.main.async {
                // Get Location Social Media Data
                    self.db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(self.user!)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(self.cardID)
                    .collection(Constants.Firestore.CollectionName.locations)
                    .document(documentName)
                    .collection(Constants.Firestore.CollectionName.social)
                    .getDocuments { snapshot, err in
                        if let e = err {
                            PopUp().popUpWithOk(newTitle: "Error", newMessage: "\(e)", vc: self)
                        } else {
                            
                            if let snapshotDocuments = snapshot?.documents {
                                
                                for documents in snapshotDocuments {
                                    
                                    let data = documents.data()
                                    // Delete Social Media Data for Location
                                    if let socialName = data[Constants.Firestore.Key.name] as? String {
                                        self.db.collection(Constants.Firestore.CollectionName.VBC)
                                            .document(Constants.Firestore.CollectionName.data)
                                            .collection(Constants.Firestore.CollectionName.users)
                                            .document(self.user!)
                                            .collection(Constants.Firestore.CollectionName.cardID)
                                            .document(self.cardID)
                                            .collection(Constants.Firestore.CollectionName.locations)
                                            .document(documentName)
                                            .collection(Constants.Firestore.CollectionName.social)
                                            .document(socialName)
                                            .delete() { err in
                                                if let e = err {
                                                    PopUp().popUpWithOk(newTitle: "Error",
                                                                        newMessage: "Error Deleting Location Social Media Data.",
                                                                        vc: self)
                                                    print("\(e)")
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
                // Delete Location
                db.collection(Constants.Firestore.CollectionName.VBC)
                    .document(Constants.Firestore.CollectionName.data)
                    .collection(Constants.Firestore.CollectionName.users)
                    .document(user!)
                    .collection(Constants.Firestore.CollectionName.cardID)
                    .document(cardID)
                    .collection(Constants.Firestore.CollectionName.locations)
                    .document(documentName)
                    .delete()
            
            if getLocationList.count == 1 {
                getLocationList.removeAll()
                self.dismiss(animated: true, completion: nil)
            } else {
                getLocationList.removeAll()
                getLocations()
            }
        }
        
        alert.addAction(actionDELETE)
        alert.addAction(actionBACK)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Table View

extension LocationListVC: UITableViewDelegate, UITableViewDataSource {
    
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

extension LocationListVC: EditCellDelegate {
    
    func editButtonPressed(city: String, street: String, map: String) {
        
        cityName = city
        streetName = street
        mapLink = map
        
        delegateEdit?.getEditLocation(city: cityName, street: streetName, map: mapLink)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
